using System.Text.RegularExpressions;

namespace FabricSync.Services;

public class TokenReplacementService : ITokenReplacementService
{
    private readonly ILogger<TokenReplacementService> _logger;

    public TokenReplacementService(ILogger<TokenReplacementService> logger)
    {
        _logger = logger;
    }

    public string ReplaceTokens(string content, Dictionary<string, string> mappings)
    {
        if (string.IsNullOrEmpty(content) || mappings.Count == 0)
        {
            return content;
        }

        var result = content;
        var replacementCount = 0;

        foreach (var mapping in mappings)
        {
            var token = $"{{{{{mapping.Key}}}}}"; // e.g., {{LH_API_BRZ}}
            if (result.Contains(token))
            {
                result = result.Replace(token, mapping.Value);
                replacementCount++;
                _logger.LogDebug("Replaced token {Token} with {Value}", token, mapping.Value);
            }
        }

        // Check for any remaining unreplaced tokens
        var remainingTokens = Regex.Matches(result, @"\{\{([^}]+)\}\}");
        if (remainingTokens.Count > 0)
        {
            var tokenNames = string.Join(", ", remainingTokens.Select(m => m.Value));
            _logger.LogWarning("Unreplaced tokens found: {Tokens}", tokenNames);
        }

        _logger.LogInformation("Replaced {Count} tokens", replacementCount);
        return result;
    }
}
