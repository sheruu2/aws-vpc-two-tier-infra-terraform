# AWS VPC Two-Tier Infrastructure — Terraform

A highly available two-tier AWS architecture provisioned entirely with Terraform. The web tier (EC2 + ALB) lives in public subnets; the database tier (RDS MySQL) is isolated in private subnets with no public access. Security group chaining ensures the database only accepts connections from the web layer.

---

## Architecture

```
                          Internet
                             │
                        ┌────▼─────┐
                        │   IGW    │
                        └────┬─────┘
                             │
           ┌─────────────────▼──────────────────┐
           │           VPC  10.0.0.0/16          │
           │                                     │
           │   ┌─────────────┬─────────────┐     │
           │   │ Public      │ Public      │     │
           │   │ Subnet AZ-a │ Subnet AZ-b │     │  ← ALB + EC2
           │   └──────┬──────┴──────┬──────┘     │
           │          │     ALB     │             │
           │   ┌──────▼─────────────▼──────┐     │
           │   │      EC2 Web Servers       │     │
           │   └──────────────┬────────────┘     │
           │                  │ port 3306         │
           │   ┌──────────────▼────────────┐     │
           │   │ Private      │ Private    │     │
           │   │ Subnet AZ-a  │ Subnet AZ-b│     │  ← RDS only
           │   │  RDS Primary │  Standby   │     │
           │   └──────────────┴────────────┘     │
           └─────────────────────────────────────┘
```

**Traffic flow:** Internet → IGW → ALB → EC2 (Web SG) → RDS (DB SG, port 3306 only)

---

## File Structure

```
.
├── provider.tf        # AWS provider, Terraform version constraints
├── variables.tf       # All input variable declarations
├── vpc.tf             # VPC with DNS support enabled
├── subnet.tf          # 2 public + 2 private subnets across AZs
├── igw.tf             # Internet Gateway
├── route.tf           # Route tables and subnet associations
├── security.tf        # Web SG (80/443/22) and DB SG (3306 from web SG)
├── ec2.tf             # EC2 launch template and Auto Scaling Group
├── alb.tf             # Application Load Balancer, target group, listener
├── rds.tf             # RDS MySQL in private DB subnet group
├── outputs.tf         # ALB DNS, RDS endpoint, subnet IDs
├── terraform.tfvars   # Variable values (never commit passwords)
└── README.md
```

---

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI installed and configured
- IAM user or role with EC2, RDS, and VPC permissions

---

## Deployment

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/aws-vpc-two-tier-infra-terraform.git
cd aws-vpc-two-tier-infra-terraform

# 2. Set the DB password via environment variable — never hardcode it
export TF_VAR_db_password="YourStrongPassword123!"

# 3. Initialise — downloads the AWS provider
terraform init

# 4. Validate the configuration
terraform validate

# 5. Preview what will be created
terraform plan

# 6. Deploy (takes ~5–10 min; RDS is the slowest resource)
terraform apply

# 7. Get the ALB endpoint after apply completes
terraform output alb_dns_name
```

### Tear Down

```bash
terraform destroy
```

---

## Security Group Design

The key pattern in this project — the DB security group references the web SG as its source rather than a CIDR block:

```
Web Security Group
  Inbound  →  0.0.0.0/0       port 80   (HTTP)
  Inbound  →  0.0.0.0/0       port 443  (HTTPS)
  Inbound  →  0.0.0.0/0       port 22   (SSH)
  Outbound →  0.0.0.0/0       all

DB Security Group
  Inbound  →  web_sg_id       port 3306  (MySQL)
  Outbound →  0.0.0.0/0       all
```

Referencing the SG ID instead of a CIDR means only instances explicitly assigned the web SG can reach the database — regardless of their IP address.

---

## Key Design Decisions

**Why private subnets for RDS?**
Private subnets have no route to the Internet Gateway, so the database has no inbound path from the public internet. It is only reachable from within the VPC.

**Why Multi-AZ for RDS?**
AWS keeps a synchronous standby replica in a second AZ. On failure, DNS automatically redirects to the standby with no manual steps. Typical failover completes in under two minutes.

**Why reference the security group instead of a CIDR in the DB SG rule?**
A CIDR-based rule would allow any resource in that IP range to connect. Referencing the SG ID restricts access to only the resources that have that specific SG attached — a more precise and maintainable approach.

---

## Infrastructure Summary

| Resource | Detail |
|---|---|
| VPC | 10.0.0.0/16, DNS enabled |
| Public Subnets | 10.0.1.0/24, 10.0.2.0/24 (AZ-a, AZ-b) |
| Private Subnets | 10.0.3.0/24, 10.0.4.0/24 (AZ-a, AZ-b) |
| EC2 | Auto Scaling Group, min 2 / max 5 |
| ALB | Internet-facing, HTTP listener, /health check |
| RDS | MySQL 8.0, db.t3.micro, Multi-AZ, encrypted |
| Security | SG chaining, no public RDS access, IAM roles |

---

## Security Considerations

- RDS has `publicly_accessible = false` — no direct internet route
- DB password passed via `TF_VAR_db_password` environment variable, not stored in code
- EC2 instances use IAM roles — no static access keys
- `terraform.tfstate` excluded from version control via `.gitignore`
- S3 backend with DynamoDB state locking recommended for team use

---

## What I Learned

Working through this project gave me hands-on experience with:

- Terraform resource dependencies and how the dependency graph is resolved
- VPC design — subnet sizing, AZ spread, and route table isolation
- Security group chaining as a network access control pattern
- RDS deployment in private subnets with Multi-AZ failover
- Application Load Balancer setup with health checks
- IAM role-based access for EC2 (no hardcoded credentials)
- Why state files must be kept out of version control
