using System.Diagnostics;
using System.Globalization;

var options = DeployOptions.Parse(args);
var repoRoot = FindRepoRoot(Directory.GetCurrentDirectory());
var stackPath = Path.GetFullPath(options.StackPath ?? Path.Combine(repoRoot, "stacks-bicep", "rg-crm-dev"));
var templateFile = Path.GetFullPath(options.TemplateFile ?? Path.Combine(stackPath, "main.bicep"));
var parameterFile = Path.GetFullPath(options.ParameterFile ?? Path.Combine(stackPath, "main.bicepparam"));
var resourceGroup = options.ResourceGroup ?? new DirectoryInfo(stackPath).Name;
var deploymentName = options.DeploymentName ?? $"{resourceGroup}-{DateTimeOffset.UtcNow:yyyyMMdd-HHmmss}";
var tempParamsFile = Path.Combine(Path.GetTempPath(), $"acestus-iac-params-{Guid.NewGuid():N}.json");

ValidatePath(stackPath, "stack path");
ValidatePath(templateFile, "template file");
ValidatePath(parameterFile, "parameter file");

try
{
    Console.WriteLine($"Repo root:        {repoRoot}");
    Console.WriteLine($"Stack path:       {stackPath}");
    Console.WriteLine($"Template file:    {templateFile}");
    Console.WriteLine($"Parameters file:  {parameterFile}");
    Console.WriteLine($"Resource group:   {resourceGroup}");
    Console.WriteLine($"Deployment name:  {deploymentName}");
    Console.WriteLine($"What-if:          {options.WhatIf}");
    Console.WriteLine();

    RunAz(
        "bicep",
        "build-params",
        "--file",
        parameterFile,
        "--outfile",
        tempParamsFile,
        "--only-show-errors");

    var azArgs = new List<string>
    {
        "deployment",
        "group",
        options.WhatIf ? "what-if" : "create",
        "--resource-group",
        resourceGroup,
        "--name",
        deploymentName,
        "--template-file",
        templateFile,
        "--parameters",
        $"@{tempParamsFile}"
    };

    if (options.WhatIf)
    {
        azArgs.Add("--no-pretty-print");
    }

    var deploymentResult = RunAz(azArgs.ToArray());

    if (!options.WhatIf)
    {
        Console.WriteLine();
        Console.WriteLine("Deployment outputs:");
        RunAz(
            "deployment",
            "group",
            "show",
            "--resource-group",
            resourceGroup,
            "--name",
            deploymentName,
            "--query",
            "properties.outputs",
            "-o",
            "json");
    }
    else
    {
        Console.WriteLine();
        Console.WriteLine(deploymentResult);
    }
}
finally
{
    TryDelete(tempParamsFile);
}

static string FindRepoRoot(string startDirectory)
{
    var current = new DirectoryInfo(startDirectory);
    while (current is not null)
    {
        if (Directory.Exists(Path.Combine(current.FullName, "stacks-bicep")) &&
            Directory.Exists(Path.Combine(current.FullName, ".git")))
        {
            return current.FullName;
        }

        current = current.Parent;
    }

    throw new InvalidOperationException("Could not find the repository root. Run the command from inside the acestus-iac repo.");
}

static void ValidatePath(string path, string label)
{
    if (!File.Exists(path) && !Directory.Exists(path))
    {
        throw new FileNotFoundException($"Could not find {label}: {path}", path);
    }
}

static string RunAz(params string[] arguments)
{
    var startInfo = new ProcessStartInfo
    {
        FileName = "az",
        RedirectStandardError = true,
        RedirectStandardOutput = true,
        UseShellExecute = false
    };

    foreach (var argument in arguments)
    {
        startInfo.ArgumentList.Add(argument);
    }

    using var process = Process.Start(startInfo) ?? throw new InvalidOperationException("Failed to start az.");

    var stdout = process.StandardOutput.ReadToEnd();
    var stderr = process.StandardError.ReadToEnd();
    process.WaitForExit();

    if (!string.IsNullOrWhiteSpace(stdout))
    {
        Console.WriteLine(stdout.TrimEnd());
    }

    if (process.ExitCode != 0)
    {
        if (!string.IsNullOrWhiteSpace(stderr))
        {
            Console.Error.WriteLine(stderr.TrimEnd());
        }

        throw new InvalidOperationException($"az {string.Join(' ', arguments)} failed with exit code {process.ExitCode}.");
    }

    return stdout;
}

static void TryDelete(string path)
{
    try
    {
        if (File.Exists(path))
        {
            File.Delete(path);
        }
    }
    catch
    {
        // Best-effort temp cleanup.
    }
}

sealed record DeployOptions(string? StackPath, string? TemplateFile, string? ParameterFile, string? ResourceGroup, string? DeploymentName, bool WhatIf)
{
    public static DeployOptions Parse(string[] args)
    {
        string? stackPath = null;
        string? templateFile = null;
        string? parameterFile = null;
        string? resourceGroup = null;
        string? deploymentName = null;
        var whatIf = false;

        for (var i = 0; i < args.Length; i++)
        {
            var arg = args[i];

            switch (arg)
            {
                case "--stack-path":
                    stackPath = RequireValue(args, ref i, arg);
                    break;
                case "--template-file":
                    templateFile = RequireValue(args, ref i, arg);
                    break;
                case "--parameter-file":
                    parameterFile = RequireValue(args, ref i, arg);
                    break;
                case "--resource-group":
                    resourceGroup = RequireValue(args, ref i, arg);
                    break;
                case "--deployment-name":
                    deploymentName = RequireValue(args, ref i, arg);
                    break;
                case "--what-if":
                    whatIf = true;
                    break;
                case "--help":
                case "-h":
                    PrintHelp();
                    Environment.Exit(0);
                    break;
                default:
                    if (arg.StartsWith("--", StringComparison.Ordinal))
                    {
                        throw new ArgumentException($"Unknown argument: {arg}");
                    }

                    stackPath ??= arg;
                    break;
            }
        }

        return new DeployOptions(stackPath, templateFile, parameterFile, resourceGroup, deploymentName, whatIf);
    }

    private static string RequireValue(string[] args, ref int index, string name)
    {
        if (index + 1 >= args.Length)
        {
            throw new ArgumentException($"Missing value for {name}.");
        }

        index++;
        return args[index];
    }

    private static void PrintHelp()
    {
        Console.WriteLine("""
Usage:
  dotnet run --project scripts/deploy-bicep-stack -- [stack-path] [options]

Options:
  --stack-path <path>       Stack folder containing main.bicep and main.bicepparam
  --template-file <path>    Override template file path
  --parameter-file <path>   Override parameter file path
  --resource-group <name>   Override Azure resource group
  --deployment-name <name>  Override deployment name
  --what-if                 Run az deployment group what-if instead of create
  --help                    Show this help
""");
    }
}
