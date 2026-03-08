# MyInfrastructure

Infrastructure as Code (IaC) repository using Terraform to provision Azure resources.

## Structure

```
MyInfrastructure/
├── terraform/
│   ├── main.tf        # Azure resources (ADLS Gen2, Functions, AI Foundry)
│   ├── variables.tf   # Input variables
│   └── outputs.tf     # Output values
└── .github/
    └── workflows/
        └── terraform.yml  # CI pipeline for Terraform validate & plan
```

## Resources Provisioned

| Resource | Azure Service | Description |
|----------|--------------|-------------|
| **ADLS Gen2** | Azure Data Lake Storage Gen2 | HNS-enabled storage with `raw`, `processed`, `curated` filesystems |
| **Azure Functions** | Linux Consumption Plan (Y1) | Python 3.11 serverless function app with App Insights |
| **Azure AI Foundry** | AI Foundry Hub + Project | AI hub backed by Key Vault and dedicated storage |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3.0
- Azure CLI authenticated (`az login`) or a Service Principal
- An Azure Subscription ID

## Usage

```bash
cd terraform

# Initialize
terraform init

# Preview changes
terraform plan -var="subscription_id=<YOUR_SUBSCRIPTION_ID>" -var="environment=dev"

# Apply
terraform apply -var="subscription_id=<YOUR_SUBSCRIPTION_ID>" -var="environment=dev"

# Destroy
terraform destroy -var="subscription_id=<YOUR_SUBSCRIPTION_ID>" -var="environment=dev"
```

## Variables

| Name               | Description                           | Default   |
|--------------------|---------------------------------------|-----------|
| subscription_id    | Azure subscription ID (required)      | —         |
| location           | Azure region                          | eastus    |
| project_name       | Short name prefix (max 10 chars)      | myinfra   |
| environment        | Environment (dev / staging / prod)    | dev       |
| func_python_version| Python version for Function App       | 3.11      |
| log_retention_days | Log Analytics retention in days       | 30        |

## CI/CD

GitHub Actions runs `terraform fmt -check` and `terraform validate` on every push, and `terraform plan` on pull requests to `main`.

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Service principal app ID |
| `AZURE_CLIENT_SECRET` | Service principal secret |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `AZURE_TENANT_ID` | Azure tenant ID |
