namespace FabricSync.Services;

public interface ITokenReplacementService
{
    string ReplaceTokens(string content, Dictionary<string, string> mappings);
}
