# 🚀 Strapi on AWS ECS Fargate - Production Ready

> **Complete Infrastructure as Code deployment with CI/CD, monitoring, and auto-healing**

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-ECS%20Fargate-FF9900?logo=amazon-aws)](https://aws.amazon.com/ecs/)
[![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions)](https://github.com/features/actions)

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start Guide](#quick-start-guide)
- [Infrastructure Components](#infrastructure-components)
- [Monitoring & Alerting](#monitoring--alerting)
- [CI/CD Pipelines](#cicd-pipelines)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Cost Estimation](#cost-estimation)

---

## 🏗️ Architecture Overview

### Complete Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              CI/CD PIPELINE                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   ┌──────────────┐      ┌──────────────┐      ┌──────────────┐                 │
│   │   DEVELOPER  │      │    GITHUB    │      │   GITHUB     │                 │
│   │              │ push │              │ trigger │  ACTIONS   │                 │
│   │   git push   │─────►│    REPO      │────────►│            │                 │
│   │              │      │   (main)     │         │ Workflows  │                 │
│   └──────────────┘      └──────────────┘         └─────┬──────┘                 │
│                                                        │                        │
│                         ┌──────────────────────────────┼────────────────────┐   │
│                         │                              │                    │   │
│                         ▼                              ▼                    │   │
│              ┌──────────────────┐          ┌──────────────────┐             │   │
│              │   deploy.yml     │          │  terraform.yml   │             │   │
│              │                  │          │                  │             │   │
│              │ • Build Docker   │          │ • terraform init │             │   │
│              │ • Push to ECR    │          │ • terraform plan │             │   │
│              │ • Update ECS     │          │ • terraform apply│             │   │
│              └────────┬─────────┘          └────────┬─────────┘             │   │
│                       │                             │                       │   │
└───────────────────────┼─────────────────────────────┼───────────────────────┘   │
                        │                             │                           │
                        ▼                             ▼                           │
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    AWS Cloud                                     │
│                                                                                  │
│    ┌─────────────────────────────────────────────────────────────────────────┐  │
│    │                          VPC (10.0.0.0/16)                               │  │
│    │                                                                          │  │
│    │                        ┌──────────────────┐                              │  │
│    │                        │   Internet GW    │                              │  │
│    │                        └────────┬─────────┘                              │  │
│    │                                 │                                        │  │
│    │         ┌───────────────────────┴───────────────────────┐               │  │
│    │         │                                               │               │  │
│    │         ▼                                               ▼               │  │
│    │  ┌─────────────────┐                         ┌─────────────────┐        │  │
│    │  │ Public Subnet A │                         │ Public Subnet B │        │  │
│    │  │   (10.0.1.0/24) │                         │   (10.0.2.0/24) │        │  │
│    │  │    AZ: ap-1a    │                         │    AZ: ap-1b    │        │  │
│    │  │                 │                         │                 │        │  │
│    │  │  ┌───────────┐  │                         │  ┌───────────┐  │        │  │
│    │  │  │    ALB    │◄─┼─────────────────────────┼─►│    ALB    │  │        │  │
│    │  │  │ Port 80   │  │    (Multi-AZ Active)    │  │ Port 80   │  │        │  │
│    │  │  └─────┬─────┘  │                         │  └─────┬─────┘  │        │  │
│    │  │        │        │                         │        │        │        │  │
│    │  │        │        │    Target Group         │        │        │        │  │
│    │  │        └────────┼────(Health: /_health)───┼────────┘        │        │  │
│    │  │                 │    Interval: 30s        │                 │        │  │
│    │  │                 │    Threshold: 2/5       │                 │        │  │
│    │  │                 │                         │                 │        │  │
│    │  │        ┌────────┴─────────────────────────┴────────┐        │        │  │
│    │  │        │                                           │        │        │  │
│    │  │        ▼                                           │        │        │  │
│    │  │  ┌───────────┐                         ┌──────────────┐    │        │  │
│    │  │  │    ECS    │                         │              │    │        │  │
│    │  │  │  Fargate  │                         │   (Standby   │    │        │  │
│    │  │  │ (Strapi)  │                         │    Ready)    │    │        │  │
│    │  │  │  Task 1   │                         │              │    │        │  │
│    │  │  │:1337      │                         │   No Tasks   │    │        │  │
│    │  │  │           │                         │              │    │        │  │
│    │  │  │ FIXED: 1  │                         │              │    │        │  │
│    │  │  └─────┬─────┘                         └──────────────┘    │        │  │
│    │  └────────┼──────────────────────────────────────────────────┘        │  │
│    │           │                                                            │  │
│    │           └─────────────────┬──────────────────────────────            │  │
│    │                             ▼                                          │  │
│    │                  ┌─────────────────────┐                               │  │
│    │                  │   RDS PostgreSQL    │                               │  │
│    │                  │     (Private)       │                               │  │
│    │                  │   Multi-AZ Ready    │                               │  │
│    │                  └─────────────────────┘                               │  │
│    └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│    ┌─────────────────────────────────────────────────────────────────────────┐  │
│    │                        CloudWatch Monitoring                             │  │
│    │                                                                          │  │
│    │  ┌─────────────┐  ┌──────────────────┐  ┌────────────────────────────┐  │  │
│    │  │  Log Group  │  │    Dashboard     │  │    Container Insights      │  │  │
│    │  │ /ecs/strapi │  │  "Strapi-Monitor"│  │                            │  │  │
│    │  │             │  │                  │  │  • CPU Utilization         │  │  │
│    │  │ • App Logs  │  │  ┌────────────┐  │  │  • Memory Utilization      │  │  │
│    │  │ • Errors    │  │  │ ECS Metrics│  │  │  • ALB Request Count       │  │  │
│    │  │ • Requests  │  │  │ ALB Metrics│  │  │  • Target Response Time    │  │  │
│    │  │             │  │  │ RDS Metrics│  │  │  • Healthy/Unhealthy Hosts │  │  │
│    │  └─────────────┘  │  └────────────┘  │  └────────────────────────────┘  │  │
│    │                   └──────────────────┘                                   │  │
│    │                                                                          │  │
│    │  ┌──────────────────────────────────────────────────────────────────┐   │  │
│    │  │                      CloudWatch Alarms                            │   │  │
│    │  │                                                                   │   │  │
│    │  │  ┌──────────────┐ ┌───────────────┐ ┌──────────────────────┐    │   │  │
│    │  │  │ ECS High CPU │ │ ECS High Mem  │ │ Unhealthy Targets    │    │   │  │
│    │  │  │   >70%       │ │   >80%        │ │ Count > 0            │    │   │  │
│    │  │  └──────┬───────┘ └──────┬────────┘ └──────────┬───────────┘    │   │  │
│    │  │         │                │                     │                │   │  │
│    │  │  ┌──────┴────────────────┴─────────────────────┴───────────┐    │   │  │
│    │  │  │               ALB 5xx Errors > 10                        │    │   │  │
│    │  │  │               ALB Response Time > 2s                     │    │   │  │
│    │  │  └──────────────────────────┬───────────────────────────────┘    │   │  │
│    │  └─────────────────────────────┼────────────────────────────────────┘   │  │
│    │                                │                                         │  │
│    │                                ▼                                         │  │
│    │                         ┌─────────────┐                                  │  │
│    │                         │  SNS Topic  │──► Email: your@email.com         │  │
│    │                         │ "strapi-    │                                  │  │
│    │                         │  alerts"    │                                  │  │
│    │                         └─────────────┘                                  │  │
│    └─────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│    ┌──────────┐                                                                 │
│    │   ECR    │ ◄── Docker Images (strapi:latest)                               │
│    └──────────┘                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

                                     ▲
                                     │ HTTP (80) → ALB
                                     │
                              ┌──────┴──────┐
                              │   Users     │
                              │  Internet   │
                              └─────────────┘
```

---

## ✨ Features

### Infrastructure
- ✅ **Fully Automated IaC** - 100% Terraform managed
- ✅ **Multi-AZ Deployment** - High availability across availability zones
- ✅ **Application Load Balancer** - Intelligent traffic distribution
- ✅ **Auto-Healing** - Unhealthy tasks automatically replaced
- ✅ **Serverless Compute** - ECS Fargate (no EC2 management)
- ✅ **Managed Database** - RDS PostgreSQL with automated backups

### Security
- 🔒 **Private RDS** - Database not exposed to internet
- 🔒 **Security Groups** - Least privilege network access
- 🔒 **IAM Roles** - Fine-grained permissions
- 🔒 **SSL Ready** - HTTPS support (ALB configured)
- 🔒 **Secret Management** - GitHub Secrets for sensitive data

### Monitoring & Observability
- 📊 **CloudWatch Dashboard** - Real-time metrics visualization
- 📊 **5 CloudWatch Alarms** - Proactive issue detection
- 📊 **Email Alerts** - SNS notifications for critical events
- 📊 **Centralized Logging** - `/ecs/strapi` log group
- 📊 **Container Insights** - Deep ECS metrics

### CI/CD
- 🚀 **GitHub Actions** - Automated deployments
- 🚀 **Docker Build** - Containerized application
- 🚀 **ECR Integration** - Secure image storage
- 🚀 **Zero-Downtime Deployments** - Rolling updates
- 🚀 **Infrastructure as Code** - Reproducible environments

---

## 📁 Project Structure

```
strapi/
├── .github/
│   └── workflows/
│       ├── deploy.yml           # Application deployment workflow
│       └── terraform.yml        # Infrastructure deployment workflow
│
├── terraform/
│   ├── alb.tf                   # Application Load Balancer + Target Group
│   ├── autoscaling.tf           # [REMOVED] Auto-scaling (dev optimization)
│   ├── backend.tf               # S3 state backend + DynamoDB locking
│   ├── ecr.tf                   # Elastic Container Registry
│   ├── ecs.tf                   # ECS Cluster + Service + Task Definition
│   ├── iam.tf                   # IAM roles (execution + task)
│   ├── monitoring.tf            # CloudWatch Dashboard + Alarms + SNS
│   ├── output.tf                # Terraform outputs (ALB URL, etc.)
│   ├── provider.tf              # AWS provider configuration
│   ├── rds.tf                   # PostgreSQL RDS instance
│   ├── security-groups.tf       # VPC + Subnets + Security Groups
│   ├── variable.tf              # Input variables
│   ├── terraform.tfvars         # [GITIGNORED] Variable values
│   └── terraform.tfvars.example # Example configuration
│
├── config/                      # Strapi configuration files
│   ├── admin.js
│   ├── api.js
│   ├── database.js
│   ├── middlewares.js
│   └── server.js
│
├── src/                         # Strapi application code
│   ├── admin/
│   ├── api/
│   ├── extensions/
│   └── index.js
│
├── dockerfile                   # Multi-stage Docker build
├── docker-compose.yml           # Local development environment
├── package.json                 # Node.js dependencies
└── README.md                    # This file
```

---

## 🎯 Prerequisites

Before you begin, ensure you have:

### Required Tools
- ✅ **AWS CLI** v2+ ([Install](https://aws.amazon.com/cli/))
- ✅ **Terraform** v1.0+ ([Install](https://www.terraform.io/downloads))
- ✅ **Docker** v20+ ([Install](https://docs.docker.com/get-docker/))
- ✅ **Git** ([Install](https://git-scm.com/downloads))
- ✅ **Node.js** v18+ (for local development)

### AWS Account Setup
- AWS account with admin access
- AWS Access Key ID and Secret Access Key
- Configured AWS CLI profile

### GitHub Repository
- GitHub repository created
- GitHub Actions enabled

---

## 🚀 Quick Start Guide

### Step 1: Clone Repository
```bash
git clone https://github.com/sairamanuja/ecs.git
cd ecs
```

### Step 2: Configure Terraform Variables
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Edit with your values
```

**Required Variables:**
```hcl
# Database Configuration
db_password = "YourSecurePassword123!"

# Strapi Secrets (generate with: openssl rand -base64 32)
app_keys           = "key1,key2,key3,key4"
jwt_secret         = "your-jwt-secret-here"
admin_jwt_secret   = "your-admin-jwt-secret"
api_token_salt     = "your-api-token-salt"
transfer_token_salt = "your-transfer-token-salt"

# Monitoring
alert_email = "your-email@example.com"
```

### Step 3: Deploy Infrastructure
```bash
# Create the Terraform backend resources once per AWS account/region
aws s3api create-bucket \
  --bucket strapi-terraform-state-839547328448-ap-south-1 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket strapi-terraform-state-839547328448-ap-south-1 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket strapi-terraform-state-839547328448-ap-south-1 \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name strapi-terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply infrastructure
terraform apply
# Type 'yes' to confirm
```

**Expected Output:**
```
Apply complete! Resources: 25 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name = "strapi-alb-1234567890.ap-south-1.elb.amazonaws.com"
application_url = "http://strapi-alb-1234567890.ap-south-1.elb.amazonaws.com"
cloudwatch_dashboard_name = "strapi-dashboard"
```

### Step 4: Confirm SNS Email Subscription
Check your email for AWS SNS subscription confirmation and click the link.

### Step 5: Setup GitHub Secrets
Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

| Secret Name | Value |`
|------------|-------|
| `AWS_ACCESS_KEY_ID` | Your AWS access key |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret key |
| `TF_VAR_DB_PASSWORD` | Same as terraform.tfvars |
| `TF_VAR_APP_KEYS` | Same as terraform.tfvars |
| `TF_VAR_JWT_SECRET` | Same as terraform.tfvars |
| `TF_VAR_ADMIN_JWT_SECRET` | Same as terraform.tfvars |
| `TF_VAR_API_TOKEN_SALT` | Same as terraform.tfvars |
| `TF_VAR_TRANSFER_TOKEN_SALT` | Same as terraform.tfvars |
| `TF_VAR_ALERT_EMAIL` | Your email for alerts |

### Step 6: Deploy Application
```bash
cd ..  # Back to project root
git add .
git commit -m "Initial deployment"
git push origin main
```

GitHub Actions will automatically:
1. Build Docker image
2. Push to ECR
3. Update ECS task definition
4. Deploy new version

### Step 7: Access Your Application
```bash
# Get ALB URL from Terraform output
terraform output application_url

# Or visit
http://<alb-dns-name>/admin
```

---

## 🏗️ Infrastructure Components

### Networking
| Resource | Configuration | Purpose |
|----------|--------------|---------|
| **VPC** | 10.0.0.0/16 | Isolated network |
| **Public Subnet A** | 10.0.1.0/24 (ap-south-1a) | Multi-AZ deployment |
| **Public Subnet B** | 10.0.2.0/24 (ap-south-1b) | High availability |
| **Internet Gateway** | Attached to VPC | Internet access |
| **Route Table** | Public routes | Traffic routing |

### Compute
| Resource | Configuration | Purpose |
|----------|--------------|---------|
| **ECS Cluster** | strapi-cluster | Container orchestration |
| **ECS Service** | 1 task (fixed) | Run Strapi container |
| **Task Definition** | 512 CPU, 1024 MB | Container specs |
| **Launch Type** | Fargate | Serverless compute |

### Load Balancing
| Resource | Configuration | Purpose |
|----------|--------------|---------|
| **Application Load Balancer** | Multi-AZ | Traffic distribution |
| **Target Group** | HTTP:1337 | ECS task targets |
| **Health Check** | /_health (30s) | Auto-healing |
| **Listener** | HTTP:80 | Incoming traffic |

### Database
| Resource | Configuration | Purpose |
|----------|--------------|---------|
| **RDS PostgreSQL** | db.t3.micro | Managed database |
| **Storage** | 20 GB GP2 | Data persistence |
| **Multi-AZ** | Ready (not enabled for dev) | HA option |
| **Backups** | 7 days retention | Data recovery |

### Container Registry
| Resource | Configuration | Purpose |
|----------|--------------|---------|
| **ECR Repository** | strapi | Docker image storage |
| **Image Scanning** | On push | Vulnerability detection |

### Security
| Resource | Configuration | Purpose |
|----------|--------------|---------|
| **ALB Security Group** | Port 80, 443 | Allow HTTP/HTTPS |
| **ECS Security Group** | Port 1337 (from ALB) | Container access |
| **RDS Security Group** | Port 5432 (from ECS) | Database access |
| **IAM Execution Role** | ECR + CloudWatch | Task startup |
| **IAM Task Role** | Application permissions | Runtime access |

---

## 📊 Monitoring & Alerting

### CloudWatch Dashboard: `strapi-dashboard`

#### Widgets
1. **ECS CPU & Memory** - Resource utilization metrics
2. **ALB Performance** - Response time and request count
3. **ALB Response Codes** - HTTP 2xx, 4xx, 5xx tracking
4. **Target Health** - Healthy vs unhealthy host count

### CloudWatch Alarms (5 total)

| Alarm | Threshold | Action |
|-------|-----------|--------|
| **ecs-high-cpu** | CPU > 70% for 10 min | Send email alert |
| **ecs-high-memory** | Memory > 80% for 10 min | Send email alert |
| **unhealthy-targets** | Unhealthy count > 0 | Send email alert |
| **alb-5xx-errors** | 5xx errors > 10 in 5 min | Send email alert |
| **alb-response-time** | Response time > 2s | Send email alert |

### Log Groups
- **Name**: `/ecs/strapi`
- **Retention**: 30 days
- **Stream Prefix**: `strapi`

### Access Logs
```bash
# View recent logs
aws logs tail /ecs/strapi --follow --region ap-south-1

# Search for errors
aws logs filter-log-events \
  --log-group-name /ecs/strapi \
  --filter-pattern "ERROR" \
  --region ap-south-1
```

---

---

## 🔄 CI/CD Pipelines

### Workflow 1: Application Deployment (`deploy.yml`)

**Trigger**: Push to `main` branch (excluding terraform/ and *.md files)

**Steps**:
1. **Checkout Code** - Clone repository
2. **Configure AWS** - Authenticate with AWS
3. **Login to ECR** - Access container registry
4. **Build Docker Image** - Create container image
5. **Push to ECR** - Upload image with git SHA tag
6. **Update Task Definition** - Register new version
7. **Deploy to ECS** - Force new deployment

**Runtime**: ~5-7 minutes

```yaml
# Triggers on app code changes only
paths-ignore:
  - terraform/**
  - "**.md"
```

### Workflow 2: Infrastructure Deployment (`terraform.yml`)

**Trigger**: Push to `main` branch (changes in terraform/ directory)

**Steps**:
1. **Checkout Code** - Clone repository
2. **Configure AWS** - Authenticate
3. **Setup Terraform** - Install Terraform CLI
4. **Terraform Init** - Initialize backend
5. **Terraform Plan** - Preview changes
6. **Terraform Apply** - Apply infrastructure changes (auto-approve on main)

**Runtime**: ~3-5 minutes (first run: 10-15 min)

```yaml
# Triggers on infrastructure changes only
paths: ['terraform/**']
```

---

## ⚙️ Configuration

### Environment Variables (ECS Task)

| Variable | Value | Purpose |
|----------|-------|---------|
| `NODE_ENV` | production | Run mode |
| `HOST` | 0.0.0.0 | Bind address |
| `PORT` | 1337 | Application port |
| `DATABASE_CLIENT` | postgres | Database type |
| `DATABASE_HOST` | RDS endpoint | DB connection |
| `DATABASE_PORT` | 5432 | DB port |
| `DATABASE_NAME` | strapidb | Database name |
| `DATABASE_USERNAME` | strapi | DB user |
| `DATABASE_PASSWORD` | From secrets | DB password |
| `DATABASE_SSL` | true | Secure connection |
| `APP_KEYS` | From secrets | Session encryption |
| `JWT_SECRET` | From secrets | Token signing |
| `ADMIN_JWT_SECRET` | From secrets | Admin auth |
| `API_TOKEN_SALT` | From secrets | API tokens |
| `TRANSFER_TOKEN_SALT` | From secrets | Transfer tokens |

### Terraform Variables

**Core Settings** (`variable.tf`):
```hcl
variable "region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "strapi"
}

variable "cpu" {
  default = 512  # 0.5 vCPU
}

variable "memory" {
  default = 1024  # 1 GB
}
```

**Customization** (`terraform.tfvars`):
```hcl
# Optional: Override defaults
region       = "us-east-1"
project_name = "my-strapi"
cpu          = 1024
memory       = 2048
```

---

## 🚢 Deployment

### Manual Deployment

#### Deploy Infrastructure Only
```bash
cd terraform
terraform apply
```

#### Deploy Application Only
```bash
# Build and push manually
AWS_REGION=ap-south-1
ECR_REPO=$(terraform output -raw ecr_repository_url)

# Build
docker build -t strapi:latest .

# Tag
docker tag strapi:latest $ECR_REPO:latest

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_REPO

# Push
docker push $ECR_REPO:latest

# Force ECS deployment
aws ecs update-service \
  --cluster strapi-cluster \
  --service strapi-service \
  --force-new-deployment \
  --region $AWS_REGION
```

### Automated Deployment (Recommended)

Simply push to GitHub:
```bash
# Infrastructure changes
git add terraform/
git commit -m "Update infrastructure"
git push origin main
# → Triggers terraform.yml

# Application changes
git add src/ config/
git commit -m "Update app code"
git push origin main
# → Triggers deploy.yml
```

### Rollback

#### Rollback Application
```bash
# List task definitions
aws ecs list-task-definitions \
  --family-prefix strapi-task \
  --region ap-south-1

# Update to previous version
aws ecs update-service \
  --cluster strapi-cluster \
  --service strapi-service \
  --task-definition strapi-task:PREVIOUS_REVISION \
  --region ap-south-1
```

#### Rollback Infrastructure
```bash
cd terraform
terraform state list
terraform state show <resource>
# Make changes and re-apply
terraform apply
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. **ECS Tasks Not Starting**

**Symptoms**: Tasks immediately stop after starting

**Check**:
```bash
# Get task ARN
aws ecs list-tasks --cluster strapi-cluster --region ap-south-1

# Describe task
aws ecs describe-tasks \
  --cluster strapi-cluster \
  --tasks <TASK_ARN> \
  --region ap-south-1

# Check logs
aws logs tail /ecs/strapi --follow --region ap-south-1
```

**Common Causes**:
- Database connection failure (check RDS endpoint)
- Missing environment variables
- Invalid secrets
- Image pull failure (check ECR permissions)

#### 2. **ALB Health Checks Failing**

**Symptoms**: Targets showing unhealthy in ALB console

**Solution**:
```bash
# Add health check endpoint to Strapi
# In config/server.js or create custom route
module.exports = {
  routes: [
    {
      method: 'GET',
      path: '/_health',
      handler: (ctx) => {
        ctx.body = { status: 'ok' };
      },
    },
  ],
};
```

#### 3. **Terraform State Lock**

**Symptoms**: "Error acquiring state lock"

**Solution**:
```bash
# List locks
aws dynamodb scan \
  --table-name strapi-terraform-state-lock \
  --region ap-south-1

# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

#### 4. **Terraform Backend Bucket Missing**

**Symptoms**: "S3 bucket ... does not exist"

**Solution**:
```bash
# Create the backend resources, then rerun terraform init
aws s3api create-bucket \
  --bucket strapi-terraform-state-839547328448-ap-south-1 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

aws s3api put-bucket-versioning \
  --bucket strapi-terraform-state-839547328448-ap-south-1 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
  --bucket strapi-terraform-state-839547328448-ap-south-1 \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name strapi-terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-south-1

terraform init
```

#### 5. **GitHub Actions Failing**

**Check**:
- GitHub Secrets are set correctly
- AWS credentials have proper permissions
- ECR repository exists
- ECS cluster and service exist

**View Logs**: GitHub → Actions tab → Click failed workflow

#### 6. **High CPU/Memory Alerts**

**Immediate**:
```bash
# Check current metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=strapi-cluster \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average \
  --region ap-south-1
```

**Long-term**: Increase task resources in `variable.tf`:
```hcl
cpu    = 1024  # 1 vCPU
memory = 2048  # 2 GB
```

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services \
  --cluster strapi-cluster \
  --services strapi-service \
  --region ap-south-1

# View recent deployments
aws ecs describe-services \
  --cluster strapi-cluster \
  --services strapi-service \
  --query 'services[0].deployments' \
  --region ap-south-1

# Check ALB targets
aws elbv2 describe-target-health \
  --target-group-arn <TG_ARN> \
  --region ap-south-1

# View CloudWatch metrics
aws cloudwatch list-metrics \
  --namespace AWS/ECS \
  --dimensions Name=ClusterName,Value=strapi-cluster \
  --region ap-south-1

# Export logs
aws logs get-log-events \
  --log-group-name /ecs/strapi \
  --log-stream-name <STREAM_NAME> \
  --region ap-south-1 > logs.txt
```

---

## 💰 Cost Estimation

### Monthly AWS Costs (Development Setup)

| Service | Configuration | Estimated Cost |
|---------|--------------|----------------|
| **ECS Fargate** | 1 task, 0.5 vCPU, 1 GB | ~$15-20 |
| **ALB** | 1 ALB, low traffic | ~$20-25 |
| **RDS PostgreSQL** | db.t3.micro, 20 GB | ~$15-20 |
| **ECR** | <1 GB storage | ~$1-2 |
| **CloudWatch** | Logs, Dashboard, Alarms | ~$5-10 |
| **Data Transfer** | <10 GB/month | ~$1-5 |
| **S3** | Terraform state | <$1 |
| **DynamoDB** | State locking | <$1 |
| **SNS** | Email notifications | <$1 |

**Total: $58-85/month**

### Production Setup (with scaling)
- **ECS Fargate**: 2-10 tasks = $30-150
- **RDS**: Multi-AZ db.t3.small = $50-70
- **Total**: ~$150-300/month

### Cost Optimization Tips
```bash
# Stop services when not needed
aws ecs update-service \
  --cluster strapi-cluster \
  --service strapi-service \
  --desired-count 0 \
  --region ap-south-1

# Delete infrastructure completely
cd terraform
terraform destroy
```

---

## 📚 Additional Resources

### Documentation
- [AWS ECS Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Strapi Documentation](https://docs.strapi.io/)
- [GitHub Actions](https://docs.github.com/en/actions)

### Monitoring
- CloudWatch Dashboard: `https://console.aws.amazon.com/cloudwatch/dashboards/strapi-dashboard`
- ECS Console: `https://console.aws.amazon.com/ecs/home?region=ap-south-1#/clusters/strapi-cluster`
- ECR Console: `https://console.aws.amazon.com/ecr/repositories/strapi`

### Commands Cheat Sheet
```bash
# Terraform
terraform init              # Initialize
terraform plan              # Preview changes
terraform apply             # Apply changes
terraform destroy           # Destroy all
terraform output            # Show outputs
terraform state list        # List resources

# Docker
docker build -t strapi .    # Build image
docker ps                   # List containers
docker logs <id>            # View logs

# AWS CLI
aws ecs list-clusters       # List ECS clusters
aws ecs list-services       # List services
aws ecs describe-tasks      # Task details
aws logs tail <group>       # Tail logs
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License.

---

## 👤 Author

**Sai Ramanuja**
- GitHub: [@sairamanuja](https://github.com/sairamanuja)
- Repository: [ecs](https://github.com/sairamanuja/ecs)

---

## 🙏 Acknowledgments

- AWS for ECS Fargate
- HashiCorp for Terraform
- Strapi for the amazing headless CMS
- GitHub for Actions CI/CD

---

**⭐ If you find this project helpful, please give it a star!**
# Ecs-cloudwatch
