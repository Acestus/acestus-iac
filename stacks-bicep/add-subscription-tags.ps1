Get-ChildItem -Path "<your-repo-path>\bicep\rg-*" -Directory | ForEach-Object {
  $paramFile = Join-Path $_.FullName "main.bicepparam"
  if (Test-Path $paramFile) {
    $content = Get-Content $paramFile -Raw
    if ($content -notmatch "Subscription:") {
      $rgName = $_.Name
      $subscription = 'Management'  # default
      
      # Determine subscription based on naming pattern
      if ($rgName -like '*ana*') { $subscription = 'Corp-710-Analytics' }
      elseif ($rgName -like '*edm*') { $subscription = 'Corp-530-EnterpriseDataManagement' }
      elseif ($rgName -like '*apd*') { $subscription = 'Corp-520-ApplicationDevelopment' }
      
      # Find the closing brace of the tags block and add subscription before it
      if ($content -match "param tags = \{([^}]+)\}") {
        $tagsContent = $matches[1].TrimEnd()
        $newTagsContent = $tagsContent + "`n  Subscription: '$subscription'"
        $newContent = $content -replace "param tags = \{[^}]+\}", "param tags = {$newTagsContent`n}"
        Set-Content -Path $paramFile -Value $newContent
        Write-Host "Added $subscription to $rgName" -ForegroundColor Green
      }
    }
  }
}

Write-Host "Completed adding subscription tags to all bicepparam files" -ForegroundColor Cyan