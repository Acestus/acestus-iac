namespace FabricSync.Models;

// Fabric API response types
public record FabricItem(string Id, string DisplayName, string Type, string? Description);

internal record FabricItemsResponse(List<FabricItemDto> Value, string? ContinuationToken);
internal record FabricItemDto(string Id, string DisplayName, string Type, string? Description);

internal record ItemDefinitionDto
{
    public List<DefinitionPartDto>? Parts { get; init; }
}

internal record DefinitionPartDto
{
    public string? Path { get; init; }
    public string? Payload { get; init; }
    public string? PayloadType { get; init; }
}

internal record UpdateDefinitionRequest(ItemDefinitionDto Definition);

// Sync request/response
public record SyncRequest
{
    public string Branch { get; init; } = "dev";

    /// <summary>
    /// Files from ws-fabric/ directory. Key is relative path (e.g., "ws-fabric/nb_example.Notebook/notebook-content.py")
    /// Value is the file content.
    /// </summary>
    public Dictionary<string, string>? Files { get; init; }

    /// <summary>
    /// Token mappings for this environment (e.g., {"WORKSPACE_ID": "xxx", "LH_API_BRZ": "yyy"})
    /// </summary>
    public Dictionary<string, string>? Mappings { get; init; }
}

public record SyncResult(string Item, bool Success, string Message);
