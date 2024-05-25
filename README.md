# k8s-fluxcd
FluxCD in K8s cluster

## Setting Up AWS Credentials

Before you begin, ensure you have your AWS credentials configured. You can do this by setting up the AWS CLI:

```sh
aws configure
```

Follow the prompts to enter your AWS Access Key ID, Secret Access Key, region, and output format.

## Initializing and Applying Terraform Configuration

### Step 1: Initialize Terraform

Navigate to the `terraform/state/` directory and initialize Terraform:

```sh
cd terraform/state/
terraform init
```

This command will initialize the directory and set up the backend configuration.

### Step 2: Apply Terraform Configuration

Apply the Terraform configuration to create the S3 bucket and configure it as specified:

```sh
terraform apply
```

Follow the prompts to confirm the changes.

## Directory Structure and Purpose

- `main.tf`: Contains the main configuration for creating the S3 bucket.
- `provider.tf`: Specifies the AWS provider configuration.
- `variables.tf`: Defines the variables used in the Terraform configuration.
- `backend.tf`: Configures the backend to use the S3 bucket for storing the Terraform state.

## Verifying IAM Permissions

Ensure the appropriate IAM roles and policies are set up in AWS to allow Terraform to access and manage the S3 bucket. Verify the AWS credentials and permissions used by Terraform.

## Summary

By following these steps, the Terraform setup for the S3 bucket will be correctly configured, documented, and applied, ensuring the remote state storage is properly established.