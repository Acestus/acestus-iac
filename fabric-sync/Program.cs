using System.Text.Json;
using Azure.Core;
using Azure.Identity;
using FabricSync.Models;
using FabricSync.Services;
using Microsoft.Extensions.Http.Resilience;
using Polly;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks();

// Configure Azure credential for Fabric API
builder.Services.AddSingleton<TokenCredential>(sp =>
{
    // Use DefaultAzureCredential which supports:
    // - Managed Identity (in AKS)
    // - Azure CLI (local development)
    // - Environment variables
    return new DefaultAzureCredential();
});

// Configure HttpClient for Fabric API with resilience
builder.Services.AddHttpClient<IFabricApiService, FabricApiService>(client =>
{
    client.BaseAddress = new Uri("https://api.fabric.microsoft.com/v1/");
})
.AddResilienceHandler("FabricApi", builder =>
{
    // Retry: exponential backoff for transient failures and 429 (rate limiting)
    builder.AddRetry(new HttpRetryStrategyOptions
    {
        MaxRetryAttempts = 3,
        Delay = TimeSpan.FromSeconds(2),
        BackoffType = DelayBackoffType.Exponential,
        UseJitter = true,
        ShouldHandle = args => ValueTask.FromResult(
            args.Outcome.Result?.StatusCode == System.Net.HttpStatusCode.TooManyRequests ||
            args.Outcome.Result?.StatusCode >= System.Net.HttpStatusCode.InternalServerError ||
            args.Outcome.Exception is HttpRequestException)
    });

    // Circuit breaker: fail fast when Fabric API is unhealthy
    builder.AddCircuitBreaker(new HttpCircuitBreakerStrategyOptions
    {
        SamplingDuration = TimeSpan.FromSeconds(30),
        FailureRatio = 0.5,
        MinimumThroughput = 5,
        BreakDuration = TimeSpan.FromSeconds(30)
    });

    // Timeout: prevent hanging requests
    builder.AddTimeout(TimeSpan.FromSeconds(30));
});

builder.Services.AddSingleton<ITokenReplacementService, TokenReplacementService>();

var app = builder.Build();

// Health endpoints for Kubernetes
app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");

// Sync endpoint - triggered by GitHub Actions with files included in payload
app.MapPost("/sync/{environment}", async (
    string environment,
    SyncRequest request,
    IFabricApiService fabricApi,
    ITokenReplacementService tokenService,
    IConfiguration config,
    ILogger<Program> logger) =>
{
    logger.LogInformation("Starting sync for environment: {Environment}, branch: {Branch}", environment, request.Branch);

    // Validate that files were provided
    if (request.Files == null || request.Files.Count == 0)
    {
        return Results.BadRequest(new { error = "No files provided. Include 'files' dictionary in request body." });
    }

    if (request.Mappings == null || request.Mappings.Count == 0)
    {
        return Results.BadRequest(new { error = "No mappings provided. Include 'mappings' dictionary in request body." });
    }

    // Validate environment
    var workspaceId = environment.ToLower() switch
    {
        "dev" => config["Fabric:Workspaces:Dev"],
        "stg" => config["Fabric:Workspaces:Stg"],
        "prd" => config["Fabric:Workspaces:Prd"],
        _ => null
    };

    if (string.IsNullOrEmpty(workspaceId))
    {
        return Results.BadRequest(new { error = $"Unknown environment: {environment}" });
    }

    try
    {
        var mappings = request.Mappings;
        logger.LogInformation("Using {Count} token mappings for {Environment}", mappings.Count, environment);

        // Map folder suffixes to Fabric item types and content files
        var typeMapping = new Dictionary<string, (string FabricType, string ContentFile)>
        {
            { "DataPipeline", ("DataPipeline", "pipeline-content.json") },
            { "CopyJob", ("CopyJob", "copyjob-content.json") },
            { "Notebook", ("Notebook", "notebook-content.py") },
            { "SemanticModel", ("SemanticModel", "definition.pbism") },
            { "Lakehouse", ("Lakehouse", "lakehouse.metadata.json") },
            { "SparkJobDefinition", ("SparkJobDefinition", "SparkJobDefinitionV1.json") },
            { "Eventstream", ("Eventstream", "eventstream.json") },
            { "UserDataFunction", ("UserDataFunction", "definition.json") },
        };

        // Skip items that can't be synced via API or are managed separately
        var skipTypes = new HashSet<string> { "Reflex", "Lakehouse", "Warehouse", ".deployment", "DataAgent", "SemanticModel" };

        // Discover items from provided files
        // Group files by their parent folder (e.g., "ws-fabric/nb_example.Notebook")
        var itemFolders = request.Files.Keys
            .Select(path =>
            {
                var parts = path.Split('/');
                if (parts.Length >= 2)
                {
                    // Return folder path like "ws-fabric/nb_example.Notebook"
                    return string.Join("/", parts.Take(parts.Length - 1));
                }
                return null;
            })
            .Where(f => f != null && f.StartsWith("ws-"))
            .Distinct()
            .ToList();

        var itemsToSync = itemFolders
            .Where(folder => !skipTypes.Any(s => folder!.EndsWith($".{s}")))
            .Select(folder =>
            {
                var folderName = folder!.Split('/').Last();
                var suffix = folderName.Contains('.') ? folderName.Split('.').Last() : "";
                if (typeMapping.TryGetValue(suffix, out var mapping))
                {
                    return new { Type = mapping.FabricType, Path = folder, ContentFile = mapping.ContentFile, Valid = true };
                }
                return new { Type = "", Path = folder, ContentFile = "", Valid = false };
            })
            .Where(x => x.Valid)
            .ToList();

        logger.LogInformation("Discovered {Count} items to sync from {FileCount} files", itemsToSync.Count, request.Files.Count);

        var results = new List<SyncResult>();

        foreach (var item in itemsToSync)
        {
            try
            {
                // Extract display name from folder path (e.g., "ws-fabric/nb_example.Notebook" → "nb_example")
                var folderName = item.Path.Split('/').Last();
                var displayName = folderName.Contains('.')
                    ? folderName.Substring(0, folderName.LastIndexOf('.'))
                    : folderName;

                // Get item content from provided files
                var contentPath = $"{item.Path}/{item.ContentFile}";
                if (!request.Files.TryGetValue(contentPath, out var rawContent))
                {
                    results.Add(new SyncResult(item.Path, false, $"Content file not found: {contentPath}"));
                    continue;
                }

                // Replace tokens with environment-specific values
                var resolvedContent = tokenService.ReplaceTokens(rawContent, mappings);

                // Build parts dictionary - always include content file
                var parts = new Dictionary<string, string> { { item.ContentFile, resolvedContent } };

                // Try to get .platform file (most items have one)
                var platformPath = $"{item.Path}/.platform";
                if (request.Files.TryGetValue(platformPath, out var platformContent))
                {
                    parts[".platform"] = platformContent;
                }

                // Find the item in Fabric by display name and type
                var fabricItem = await fabricApi.GetItemByNameAsync(workspaceId, displayName, item.Type);

                if (fabricItem == null)
                {
                    results.Add(new SyncResult(item.Path, false, $"Item not found in Fabric workspace (name: '{displayName}', type: '{item.Type}')"));
                    continue;
                }

                // Update the item definition in Fabric
                await fabricApi.UpdateItemDefinitionAsync(workspaceId, fabricItem.Id, parts);
                results.Add(new SyncResult(item.Path, true, $"Updated successfully (itemId: {fabricItem.Id})"));
                logger.LogInformation("Successfully synced {Item} to Fabric", item.Path);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Failed to sync {Item}", item.Path);
                results.Add(new SyncResult(item.Path, false, ex.Message));
            }
        }

        var successCount = results.Count(r => r.Success);
        logger.LogInformation("Sync complete: {Success}/{Total} items synced successfully", successCount, results.Count);

        return Results.Ok(new
        {
            environment,
            workspaceId,
            branch = request.Branch,
            results,
            summary = new { total = results.Count, success = successCount, failed = results.Count - successCount }
        });
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "Sync failed for environment {Environment}", environment);
        return Results.Problem(ex.Message);
    }
});

// Health check endpoint for simple testing
app.MapGet("/", () => Results.Ok(new { status = "healthy", service = "fabric-sync", version = "2.0" }));

app.Run();
