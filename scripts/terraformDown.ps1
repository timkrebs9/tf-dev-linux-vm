Write-Host "Cleaning up resources..."
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
