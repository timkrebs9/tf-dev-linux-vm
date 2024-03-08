Write-Host "Initializing Terraform..."
terraform init -upgrade

Write-Host "Creating Terraform execution plan..."
terraform plan -out main.tfplan

Write-Host "Applying Terraform execution plan..."
terraform apply main.tfplan
