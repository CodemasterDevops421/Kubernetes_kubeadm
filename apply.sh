#!/bin/bash

# Script to set up AWS infrastructure using Terraform

# Check if Terraform is installed
if ! [ -x "$(command -v terraform)" ]; then
  echo "Terraform is not installed. Please install Terraform before running this script."
  exit 1
fi

# Print welcome message and explanation of the script
echo "Welcome to the AWS Infrastructure Setup Script!"
echo "This script will use Terraform to create the following resources on AWS:"
echo "- VPC"
echo "- Subnet"
echo "- Internet Gateway"
echo "- Route Table"
echo "- Security Group"
echo "- EC2 Instances for Kubernetes Control Plane and Worker Nodes"

# Prompt the user to confirm before proceeding
read -p "Do you want to proceed with the setup? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
  echo "Setup canceled. Exiting..."
  exit 0
fi

# Initialize Terraform in the current directory
terraform init

# Provide an explanation of Terraform's initialization process
echo "Terraform initialization is complete. It downloads the required providers and modules."

# Apply the Terraform configuration to create the resources
terraform apply -auto-approve

# Provide an explanation of Terraform's apply process and the resources it creates
echo "Terraform apply is complete. The following resources have been created:"
echo "- VPC"
echo "- Subnet"
echo "- Internet Gateway"
echo "- Route Table"
echo "- Security Group"
echo "- EC2 Instances for Kubernetes Control Plane and Worker Nodes"

# Prompt the user to confirm the destruction of resources after usage
read -p "Do you want to destroy the resources after usage? (yes/no): " destroy_confirm
if [ "$destroy_confirm" == "yes" ]; then
  # Destroy the resources using Terraform
  terraform destroy -auto-approve

  # Provide an explanation of the Terraform destroy process
  echo "Terraform destroy is complete. All the created resources have been destroyed."
fi

# Print a goodbye message
echo "Thank you for using the AWS Infrastructure Setup Script. Goodbye!"
