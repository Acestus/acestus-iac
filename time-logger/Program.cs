using Azure.Storage.Blobs;
using System.Text.Json;

var connectionString = Environment.GetEnvironmentVariable("AZURE_STORAGE_CONNECTION_STRING");

if (string.IsNullOrEmpty(connectionString))
{
    Console.WriteLine("Error: AZURE_STORAGE_CONNECTION_STRING environment variable not set");
    Environment.Exit(1);
}

var blobServiceClient = new BlobServiceClient(connectionString);

// Define the containers and their messages
var containers = new[]
{
    (containerName: "container-development", message: "time-logger-data-development"),
    (containerName: "container-staging", message: "time-logger-data-staging"),
    (containerName: "container-production", message: "time-logger-data-production")
};

// Create all containers if they don't exist
foreach (var (containerName, _) in containers)
{
    var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
    await containerClient.CreateIfNotExistsAsync();
}

Console.WriteLine($"Writing to {containers.Length} containers every minute. Press Ctrl+C to stop.");

while (true)
{
    try
    {
        var timestamp = DateTimeOffset.UtcNow;
        var blobName = $"time-log-{timestamp:yyyy-MM-dd-HHmmss}.json";

        foreach (var (containerName, message) in containers)
        {
            var logEntry = new
            {
                message = message,
                utcTimestamp = timestamp.UtcDateTime,
                machineName = Environment.MachineName,
                runId = Guid.NewGuid()
            };

            var jsonContent = JsonSerializer.Serialize(logEntry, new JsonSerializerOptions
            {
                WriteIndented = true
            });

            var containerClient = blobServiceClient.GetBlobContainerClient(containerName);
            var blobClient = containerClient.GetBlobClient(blobName);
            using var stream = new MemoryStream(System.Text.Encoding.UTF8.GetBytes(jsonContent));
            await blobClient.UploadAsync(stream, overwrite: true);

            Console.WriteLine($"[{timestamp:HH:mm:ss}] Uploaded to {containerName}: {blobName}");
        }

        await Task.Delay(TimeSpan.FromMinutes(1));
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error: {ex.Message}");
        await Task.Delay(TimeSpan.FromSeconds(10)); // Wait before retrying on error
    }
}
