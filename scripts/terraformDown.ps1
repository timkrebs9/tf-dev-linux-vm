# Copyright (c) Tim Krebs
# SPDX-License-Identifier: MPL-2.0

Write-Host "Cleaning up resources..."
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
