# Time Logger

A Kubernetes CronJob that sends timestamped messages to Azure Blob Storage every minute.

## Setup

### 1. Storage Account

The storage account and `time-logs` container are created automatically by the infrastructure deployment.

### 2. Get Storage Connection String

```powershell
az storage account show-connection-string `
  --name <your-storage-account-name> `
  --resource-group <your-resource-group> `
  --query connectionString -o tsv
```

### 3. Create Kubernetes Secret

Copy `k8s/time-logger/secret.yaml.template` to `secret.yaml` and update with your connection string:

```powershell
cp k8s/time-logger/secret.yaml.template k8s/time-logger/secret.yaml
# Edit secret.yaml and replace YOUR_STORAGE_ACCOUNT and YOUR_STORAGE_KEY
kubectl apply -f k8s/time-logger/secret.yaml
```

**Important:** Do NOT commit `secret.yaml` to git (it's in .gitignore)

### 4. Build and Push Image

```powershell
docker build -t <your-acr>.azurecr.io/time-logger:latest ./time-logger
docker push <your-acr>.azurecr.io/time-logger:latest
```

### 5. Deploy CronJob

```powershell
kubectl apply -f k8s/time-logger/cronjob.yaml
```

## Verify

Check CronJob status:

```powershell
kubectl get cronjob time-logger
kubectl get jobs
kubectl get pods
```

View logs:

```powershell
kubectl logs -l job-name=<job-name>
```

Check Azure Storage:

```powershell
az storage blob list `
  --account-name <your-storage-account-name> `
  --container-name time-logs `
  --output table
```

## Configuration

- **Schedule**: Every minute (`*/1 * * * *`)
- **Container**: `time-logs`
- **Blob naming**: `time-log-{yyyy-MM-dd-HHmmss}.json`
- **Data format**: JSON with timestamp, message, machine name, and run ID

## Environment Variables

- `AZURE_STORAGE_CONNECTION_STRING` (required) - Azure Storage connection string
- `STORAGE_CONTAINER_NAME` (optional) - Container name, defaults to `time-logs`
