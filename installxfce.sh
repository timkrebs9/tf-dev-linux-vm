# installing xfce 
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install xfce4
sudo apt install xfce4-session

#install server and configure remote rdp
sudo apt-get -y install xrdp
sudo systemctl enable xrdp
echo xfce4-session >~/.xsession
sudo service xrdp restart

sudo passwd adminuser

#Initialize Terraform
terraform init -upgrade
# Create a Terraform execution plan
terraform plan -out main.tfplan
#Apply a Terraform execution plan
terraform apply main.tfplan

#Clean up resources
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan