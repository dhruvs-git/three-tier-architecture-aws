# Three-Tier AWS Architecture with Terraform & CI/CD Pipeline

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)

A production-style 3-tier AWS architecture fully provisioned using modular Terraform — with a complete CI/CD pipeline built on GitHub Actions, OIDC-based authentication, and remote state management via S3. Infrastructure changes flow through a branch → PR → merge process where every merge to `main` automatically deploys to AWS. No manual `terraform apply` from a local machine.

---

## Architecture Overview

```
                         Internet
                             |
                        [ALB :80]
                   (Public Subnet - 2 AZs)
                             |
                   [EC2 - Node.js :3000]
                   (Private Subnet - 2 AZs)
                    SSM Session Manager Access
                             |
                     [RDS MySQL :3306]
                   (Private Subnet - 2 AZs)
                        No Public Access
```

### Network Layout

```
VPC: 10.0.0.0/16
├── Public Subnet 1   10.0.1.0/24   ca-central-1a   → ALB, NAT Gateway
├── Public Subnet 2   10.0.2.0/24   ca-central-1b   → ALB
├── Private Subnet 1  10.0.3.0/24   ca-central-1a   → EC2, RDS
└── Private Subnet 2  10.0.4.0/24   ca-central-1b   → EC2, RDS
```

---

## Tech Stack

| Layer          | Service             | Details                                      |
|----------------|---------------------|----------------------------------------------|
| Network        | AWS VPC             | Custom VPC, subnets, IGW, NAT GW             |
| Web Tier       | AWS ALB             | External, HTTP:80, 2 AZs                     |
| App Tier       | AWS EC2             | t3.micro, Amazon Linux 2023                  |
| Runtime        | Node.js / Express   | Port 3000, deployed via user_data            |
| Database       | AWS RDS MySQL       | db.t3.micro, single-AZ, private subnet       |
| Access         | AWS SSM             | Session Manager, no SSH keys                 |
| IaC            | Terraform           | Modular structure, v6 provider               |
| CI/CD          | GitHub Actions      | Plan on PR, Apply on merge                   |
| Auth           | AWS OIDC            | Keyless authentication via federation        |
| Remote State   | AWS S3              | Shared state with native S3 locking          |

---

## CI/CD Pipeline

Infrastructure changes never go directly to `main`. Every change follows this flow:

```
Developer pushes to dev branch
            ↓
Opens Pull Request → GitHub Actions triggers terraform plan
            ↓
Team reviews the plan output inside the PR
            ↓
PR merges to main → GitHub Actions triggers terraform apply
            ↓
Infrastructure deployed to AWS automatically
```

### Workflows

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `terraform.yml` | PR to main / Push to main | Runs plan on PR, apply on merge |
| `terraform-destroy.yml` | Manual only | Destroys all infrastructure (requires typing DESTROY to confirm) |

### Pipeline Stages

**On Pull Request:**
- Terraform Init
- Terraform Format Check
- Terraform Validate
- Terraform Plan (output visible inside PR)

**On Merge to main:**
- Terraform Init
- Terraform Apply (auto-approve)

### Branch Protection

The `main` branch is protected via a GitHub ruleset — direct pushes are blocked. Every infrastructure change must go through a Pull Request. This means:

- No one can push directly to `main` — not even the repo owner
- Every change is reviewed via a PR before it touches AWS
- Force pushes and branch deletions are blocked
- The pipeline plan output acts as the review gate before merge

---

## Security Design

### OIDC Authentication

This project uses OpenID Connect (OIDC) federation instead of long-lived AWS access keys. When the pipeline runs, GitHub requests a short-lived token from AWS directly — no credentials are stored anywhere.

```
GitHub Actions runner starts
        ↓
Requests OIDC token from GitHub
        ↓
AWS verifies token against trusted identity provider
        ↓
AWS issues temporary credentials scoped to this repo only
        ↓
Terraform uses credentials — they expire when the job ends
```

The IAM role trust policy is locked to this specific repository:
```json
"repo:dhruvs-git/three-tier-architecture-aws:*"
```

Any other GitHub repo attempting to assume this role will be denied.

### Network Security

Each tier only accepts traffic from the tier directly above it — enforced through security group rules:

```
Internet  → ALB  (port 80,   source: 0.0.0.0/0)
ALB       → EC2  (port 3000, source: ALB security group)
EC2       → RDS  (port 3306, source: EC2 security group)
```

- EC2 has no public IP and is not reachable from the internet directly
- RDS has no public access and only accepts connections from EC2
- EC2 accessed exclusively via AWS SSM Session Manager — no SSH, no bastion host
- NAT Gateway enables outbound-only internet access from private subnets

### Remote State

Terraform state is stored in S3 with native state locking enabled. This ensures:

- Every pipeline run reads and writes to the same shared state file
- Concurrent pipeline runs cannot corrupt the state
- State file is encrypted at rest
- S3 versioning enabled — previous state versions recoverable if needed

```
S3 Bucket: three-tier-tfstate-[account-id]
  └── three-tier-app/
      └── terraform.tfstate
```

---

## Project Structure

```
three-tier-architecture-aws/
├── .github/
│   └── workflows/
│       ├── terraform.yml            # CI/CD pipeline — plan and apply
│       └── terraform-destroy.yml   # Manual destroy workflow
├── modules/
│   ├── vpc/
│   │   ├── main.tf                 # VPC, subnets, IGW, NAT GW, route tables
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/
│   │   ├── main.tf                 # Security group, ALB, target group, listener
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── scripts/
│   │   │   └── user_data.sh        # Bootstrap script — installs Node.js, starts Express app
│   │   ├── main.tf                 # Security group, IAM role, EC2 instance, TG attachment
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── rds/
│       ├── main.tf                 # Security group, subnet group, RDS instance
│       ├── variables.tf
│       └── outputs.tf
├── main.tf                         # Root module — wires all modules together
├── variables.tf                    # Input variable declarations
├── outputs.tf                      # ALB DNS name, VPC ID, RDS endpoint
├── providers.tf                    # AWS provider configuration
├── versions.tf                     # Terraform version + S3 backend config
├── terraform.tfvars                # Variable values (non-sensitive only)
├── terraform.tfvars.example        # Template for required variables
└── .gitignore
```

---

## Prerequisites

Before using this project you need:

- AWS account with permissions for VPC, EC2, RDS, IAM, ELB, S3
- GitHub repository with Actions enabled
- An S3 bucket for remote state storage
- OIDC identity provider configured in AWS IAM (see Setup below)
- Terraform >= 1.14.6

---

## Setup

### 1. Bootstrap Remote State (one time only)

Create the S3 bucket for state storage manually in AWS:

- Bucket name: `three-tier-tfstate-YOUR_ACCOUNT_ID`
- Region: `ca-central-1`
- Enable versioning
- Block all public access

Update `versions.tf` with your bucket name:
```hcl
backend "s3" {
  bucket       = "three-tier-tfstate-YOUR_ACCOUNT_ID"
  key          = "three-tier-app/terraform.tfstate"
  region       = "ca-central-1"
  use_lockfile = true
  encrypt      = true
}
```

### 2. Configure OIDC in AWS (one time only)

**Add GitHub as a trusted identity provider:**

Go to IAM → Identity providers → Add provider:
- Provider type: OpenID Connect
- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

**Create the IAM role:**

Go to IAM → Roles → Create role:
- Trusted entity: Web identity
- Identity provider: `token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`
- Permissions: `AdministratorAccess`
- Role name: `github-actions-OIDC-role`

**Update the trust policy** to lock it to this repo only:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/three-tier-architecture-aws:*"
        }
      }
    }
  ]
}
```

### 3. Add GitHub Secrets

Go to repo → Settings → Secrets and variables → Actions:

| Secret Name | Value |
|-------------|-------|
| `AWS_ROLE_ARN` | `arn:aws:iam::YOUR_ACCOUNT_ID:role/github-actions-OIDC-role` |
| `TF_VAR_db_password` | Your database password |

### 4. Create your terraform.tfvars

```hcl
project_name         = "three-tier-app"
region               = "ca-central-1"
cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zone    = ["ca-central-1a", "ca-central-1b"]
db_name              = "appdb"
db_username          = "admin"
```

> `db_password` is intentionally excluded — it is passed securely via the `TF_VAR_db_password` GitHub Secret.

---

## Deployment

All deployments happen automatically through the pipeline. Manual deployment is not needed.

**To deploy infrastructure:**
1. Create a branch from `main`
2. Make your Terraform changes
3. Push and open a Pull Request — `terraform plan` runs automatically
4. Review the plan output inside the PR
5. Merge — `terraform apply` runs automatically

**To destroy infrastructure:**
1. Go to Actions tab → Terraform Destroy
2. Click Run workflow
3. Type `DESTROY` in the confirmation field
4. Click Run workflow

> NAT Gateway and RDS incur hourly charges. Always destroy after testing.

---

## Module Breakdown

### VPC Module
Provisions the entire network layer — VPC, public and private subnets across 2 AZs, Internet Gateway for public traffic, NAT Gateway for private subnet outbound access, and route tables for both tiers.

### ALB Module
Provisions the external Application Load Balancer in public subnets. Includes a security group, target group pointing to EC2 port 3000, and an HTTP listener on port 80 that forwards traffic to the target group.

### EC2 Module
Provisions the application server in a private subnet. Includes an IAM role with `AmazonSSMManagedInstanceCore` for SSM access, an instance profile, the EC2 instance running Amazon Linux 2023, and target group registration. The Node.js/Express app is bootstrapped via user_data on first boot.

### RDS Module
Provisions the MySQL database in private subnets. Includes a DB subnet group across both private subnets, a security group allowing port 3306 only from EC2, and a single-AZ RDS instance with no public access.

---

## Production Considerations

| Area | Current State | Production Standard |
|------|---------------|---------------------|
| HTTPS/TLS | HTTP only on ALB | ACM certificate + HTTPS listener |
| Secrets Management | DB password via GitHub Secret | AWS Secrets Manager + IAM-based retrieval |
| RDS Encryption | Not enabled | `storage_encrypted = true` on RDS instance |
| RDS Backups | `skip_final_snapshot = true` | Backup retention policy + final snapshot |
| SSM VPC Endpoints | SSM traffic routes via NAT Gateway | VPC Interface Endpoints for SSM |
| Monitoring | No alarms configured | CloudWatch alarms for CPU, RDS, ALB metrics |
| Multi-AZ RDS | Single-AZ | `multi_az = true` for high availability |
| WAF | No web application firewall | AWS WAF attached to ALB |

---

![Architecture Diagram](./aws_website.png)

## Author

**Dhruv Barot**
[GitHub](https://github.com/dhruvs-git) · [LinkedIn](https://www.linkedin.com/in/dhruv-barot-bb71a3268/)