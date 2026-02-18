using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Azure.Core;
using FabricSync.Models;

namespace FabricSync.Services;

public class FabricApiService : IFabricApiService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };

    private readonly HttpClient _httpClient;
    private readonly TokenCredential _credential;
    private readonly ILogger<FabricApiService> _logger;
    private AccessToken? _cachedToken;

    public FabricApiService(HttpClient httpClient, TokenCredential credential, ILogger<FabricApiService> logger)
    {
        _httpClient = httpClient;
        _credential = credential;
        _logger = logger;
    }

    public async Task<List<FabricItem>> ListWorkspaceItemsAsync(string workspaceId)
    {
        await SetAuthHeaderAsync();

        var items = new List<FabricItem>();
        string? continuationToken = null;

        do
        {
            var url = $"workspaces/{workspaceId}/items";
            if (!string.IsNullOrEmpty(continuationToken))
                url += $"?continuationToken={Uri.EscapeDataString(continuationToken)}";

            var response = await _httpClient.GetAsync(url);
            response.EnsureSuccessStatusCode();

            var result = await DeserializeAsync<FabricItemsResponse>(response);
            if (result?.Value != null)
                items.AddRange(result.Value.Select(i => new FabricItem(i.Id, i.DisplayName, i.Type, i.Description)));

            continuationToken = result?.ContinuationToken;
        } while (!string.IsNullOrEmpty(continuationToken));

        _logger.LogInformation("Found {Count} items in workspace {WorkspaceId}", items.Count, workspaceId);
        return items;
    }

    public async Task<FabricItem?> GetItemByNameAsync(string workspaceId, string displayName, string itemType)
    {
        await SetAuthHeaderAsync();
        var items = await ListWorkspaceItemsAsync(workspaceId);

        var item = items.FirstOrDefault(i =>
            i.DisplayName.Equals(displayName, StringComparison.OrdinalIgnoreCase) &&
            i.Type.Equals(itemType, StringComparison.OrdinalIgnoreCase));

        if (item != null)
            _logger.LogInformation("Found item {ItemId} by name '{Name}' and type '{Type}'", item.Id, displayName, itemType);
        else
            _logger.LogWarning("No item found with name '{Name}' and type '{Type}'", displayName, itemType);

        return item;
    }

    public async Task UpdateItemDefinitionAsync(string workspaceId, string itemId, Dictionary<string, string> parts)
    {
        await SetAuthHeaderAsync();

        var definitionParts = parts.Select(p => new DefinitionPartDto
        {
            Path = p.Key,
            Payload = Convert.ToBase64String(Encoding.UTF8.GetBytes(p.Value)),
            PayloadType = "InlineBase64"
        }).ToList();

        var request = new UpdateDefinitionRequest(new ItemDefinitionDto { Parts = definitionParts });
        var jsonPayload = JsonSerializer.Serialize(request, JsonOptions);

        _logger.LogDebug("Updating item {ItemId} with {Count} parts: {Paths}", itemId, parts.Count, string.Join(", ", parts.Keys));

        var response = await _httpClient.PostAsync(
            $"workspaces/{workspaceId}/items/{itemId}/updateDefinition",
            new StringContent(jsonPayload, Encoding.UTF8, "application/json"));

        if (!response.IsSuccessStatusCode)
        {
            var error = await response.Content.ReadAsStringAsync();
            _logger.LogError("Failed to update item {ItemId}: {Status} - {Error}", itemId, response.StatusCode, error);
            throw new HttpRequestException($"Failed to update item: {response.StatusCode} - {error}");
        }

        _logger.LogInformation("Updated item {ItemId}", itemId);
    }

    private async Task SetAuthHeaderAsync()
    {
        if (!_cachedToken.HasValue || _cachedToken.Value.ExpiresOn <= DateTimeOffset.UtcNow.AddMinutes(5))
        {
            var context = new TokenRequestContext(["https://api.fabric.microsoft.com/.default"]);
            _cachedToken = await _credential.GetTokenAsync(context, CancellationToken.None);
        }
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _cachedToken.Value.Token);
    }

    private static async Task<T?> DeserializeAsync<T>(HttpResponseMessage response) =>
        JsonSerializer.Deserialize<T>(await response.Content.ReadAsStringAsync(), JsonOptions);
}
