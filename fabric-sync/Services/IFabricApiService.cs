using FabricSync.Models;

namespace FabricSync.Services;

public interface IFabricApiService
{
    Task<FabricItem?> GetItemByNameAsync(string workspaceId, string displayName, string itemType);
    Task UpdateItemDefinitionAsync(string workspaceId, string itemId, Dictionary<string, string> parts);
    Task<List<FabricItem>> ListWorkspaceItemsAsync(string workspaceId);
}
