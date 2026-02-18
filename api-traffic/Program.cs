var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddApplicationInsightsTelemetry();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddHealthChecks();

var app = builder.Build();

// Health endpoints for Kubernetes probes
app.MapHealthChecks("/health/live");
app.MapHealthChecks("/health/ready");

// Hello endpoint - GET
app.MapGet("/api/hello", (string? name) =>
{
    var greeting = string.IsNullOrEmpty(name) ? "World" : name;
    return Results.Ok(new { message = $"Hello, {greeting}!" });
});

// Hello endpoint - POST
app.MapPost("/api/hello", (HelloRequest? request) =>
{
    var greeting = string.IsNullOrEmpty(request?.Name) ? "World" : request.Name;
    return Results.Ok(new { message = $"Hello, {greeting}!" });
});

app.Run();

record HelloRequest(string? Name);
