# MyInfrastructure

Infrastructure as Code (IaC) repository using Terraform to provision AWS resources.

## Structure

```
MyInfrastructure/
├── terraform/
│   ├── main.tf        # AWS resources (S3, EC2)
│   ├── variables.tf   # Input variables
│   └── outputs.tf     # Output values
└── .github/
    └── workflows/
        └── terraform.yml  # CI pipeline for Terraform validate & plan
```

## Resources Provisioned

- **S3 Bucket** — versioned storage bucket per environment
- **EC2 Instance** — application server (t3.micro by default)

## Usage

```bash
cd terraform

# Initialize
terraform init

# Preview changes
terraform plan -var="environment=dev"

# Apply
terraform apply -var="environment=dev"

# Destroy
terraform destroy -var="environment=dev"
```

## Variables

| Name           | Description                   | Default          |
|----------------|-------------------------------|------------------|
| aws_region     | AWS region                    | us-east-1        |
| project_name   | Project name prefix           | myinfrastructure |
| environment    | Environment (dev/staging/prod)| dev              |
| instance_type  | EC2 instance type             | t3.micro         |
| ami_id         | AMI ID for EC2                | Amazon Linux 2   |

## CI/CD

GitHub Actions runs `terraform validate` on every push and pull request to `main`.
