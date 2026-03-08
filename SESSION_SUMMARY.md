# Work Session Summary
**Date:** 2026-03-08
**Repo:** [MyInfrastructure](https://github.com/archanakr10/MyInfrastructure)

---

## What Was Done

### 1. GitHub Repository Setup
- Repository `MyInfrastructure` already existed on GitHub (archanakr10)
- Authenticated using a GitHub Personal Access Token (PAT) with `repo` + `workflow` scopes

### 2. Cloned Repository Locally
- Cloned to: `C:/Users/wrkun/OneDrive/Desktop/repos/MyInfrastructure`

### 3. Initial Sample Code (AWS — later replaced)
- Added `terraform/main.tf` with AWS S3 bucket and EC2 instance
- Added `terraform/variables.tf` and `terraform/outputs.tf`
- Added `.github/workflows/terraform.yml` for CI

### 4. Migrated to Azure Infrastructure
Replaced all AWS resources with the following Azure components:

| Resource | Azure Service |
|----------|--------------|
| ADLS Gen2 | Azure Data Lake Storage Gen2 (HNS enabled) with `raw`, `processed`, `curated` filesystems |
| Azure Functions | Linux Consumption Plan (Y1), Python 3.11, App Insights, Log Analytics |
| Azure AI Foundry | AI Foundry Hub + Project, Key Vault, Managed Identity, Role Assignments |

### 5. CI/CD Pipeline Updated
- GitHub Actions workflow updated with Azure credential env vars
- `terraform fmt -check` and `terraform validate` on every push
- `terraform plan` on pull requests to `main`

---

## Commands Used

### GitHub API — Create Repository
```bash
curl -s -X POST https://api.github.com/user/repos \
  -H "Authorization: token <YOUR_PAT>" \
  -H "Content-Type: application/json" \
  -d '{"name":"MyInfrastructure","description":"Infrastructure as Code samples","private":false,"auto_init":true}'
```

### Clone Repository
```bash
git clone "https://<YOUR_PAT>@github.com/archanakr10/MyInfrastructure.git" \
  "C:/Users/wrkun/OneDrive/Desktop/repos/MyInfrastructure"
```

### Stage & Commit Files
```bash
cd "C:/Users/wrkun/OneDrive/Desktop/repos/MyInfrastructure"

git add terraform/main.tf terraform/variables.tf terraform/outputs.tf \
        .github/workflows/terraform.yml README.md

git commit -m "Migrate infrastructure to Azure: ADLS Gen2, Functions, AI Foundry"
```

### Push to GitHub
```bash
git push "https://<YOUR_PAT>@github.com/archanakr10/MyInfrastructure.git" main
```

### Verify Remote is Up to Date
```bash
git fetch "https://<YOUR_PAT>@github.com/archanakr10/MyInfrastructure.git"
git log --oneline -5
```

---

## Terraform Workflow (Azure)

### Prerequisites
- Terraform >= 1.3.0 installed
- Authenticated via `az login` or Service Principal

### Commands
```bash
cd terraform

# Download provider plugins
terraform init

# Check formatting
terraform fmt -check

# Validate configuration
terraform validate

# Preview resources to be created
terraform plan \
  -var="subscription_id=<YOUR_AZURE_SUBSCRIPTION_ID>" \
  -var="environment=dev"

# Deploy resources
terraform apply \
  -var="subscription_id=<YOUR_AZURE_SUBSCRIPTION_ID>" \
  -var="environment=dev"

# Tear down resources
terraform destroy \
  -var="subscription_id=<YOUR_AZURE_SUBSCRIPTION_ID>" \
  -var="environment=dev"
```

---

## Required GitHub Secrets (for CI/CD)

Add these in: **GitHub repo → Settings → Secrets → Actions**

| Secret Name            | Description                  |
|------------------------|------------------------------|
| `AZURE_CLIENT_ID`      | Service principal app ID     |
| `AZURE_CLIENT_SECRET`  | Service principal secret     |
| `AZURE_SUBSCRIPTION_ID`| Azure subscription ID        |
| `AZURE_TENANT_ID`      | Azure tenant ID              |

---

## Final Repo Structure

```
MyInfrastructure/
├── terraform/
│   ├── main.tf          # Resource Group, ADLS Gen2, Functions, AI Foundry
│   ├── variables.tf     # Input variables with validation
│   └── outputs.tf       # Key resource outputs
├── .github/
│   └── workflows/
│       └── terraform.yml  # CI: fmt, validate, plan
├── SESSION_SUMMARY.md   # This file
└── README.md
```
