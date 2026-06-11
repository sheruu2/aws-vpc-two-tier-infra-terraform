# AWS VPC Two-Tier Infrastructure using Terraform

## Project Overview

This project demonstrates the implementation of a highly available two-tier architecture on AWS using Terraform.

The infrastructure follows AWS best practices by separating the application layer and database layer into public and private subnets across multiple Availability Zones.

The objective of this project is to provision cloud infrastructure using Infrastructure as Code (IaC) while implementing secure networking, resource isolation, and high availability.

---

## Architecture

### Components

- VPC (10.0.0.0/16)
- 2 Public Subnets (Application Layer)
- 2 Private Subnets (Database Layer)
- Internet Gateway
- Route Tables and Route Associations
- Security Groups
- EC2 Web Server(s)
- Application Load Balancer (ALB)
- RDS MySQL Database
- DB Subnet Group

### High-Level Architecture

```text
Internet
   │
   ▼
Application Load Balancer
   │
   ▼
EC2 Web Servers
(Public Subnets)
   │
   ▼
RDS MySQL
(Private Subnets)
Key Features
Infrastructure as Code using Terraform
Multi-AZ network design
Public and Private subnet segregation
Application Load Balancer integration
Secure database deployment in private subnets
Security Group-based access control
Scalable and reusable Terraform configuration
Directory Structure
.
├── provider.tf
├── variables.tf
├── vpc.tf
├── subnet.tf
├── igw.tf
├── route.tf
├── security.tf
├── ec2.tf
├── alb.tf
├── rds.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
Infrastructure Components
VPC

Creates a custom VPC with DNS support and DNS hostnames enabled.

Public Subnets

Used for:

Application Load Balancer
EC2 Web Servers
Private Subnets

Used for:

Amazon RDS MySQL Database
Internet Gateway

Provides internet connectivity to public subnets.

Security Groups
Web Security Group

Allows:

HTTP (80)
HTTPS (443)
SSH (22)
Database Security Group

Allows:

MySQL (3306)
Access only from Web Security Group
Application Load Balancer

Distributes incoming traffic across EC2 instances and performs health checks.

RDS MySQL

Hosted within private subnets and not publicly accessible.

Deployment Steps
Initialize Terraform
terraform init
Validate Configuration
terraform validate
Review Execution Plan
terraform plan
Deploy Infrastructure
terraform apply
Destroy Infrastructure
terraform destroy
Security Considerations
Database deployed in private subnets
No public access to RDS
Security Group-based communication between application and database tiers
Principle of least privilege followed wherever applicable
Learning Outcomes

Through this project, I gained hands-on experience with:

Terraform fundamentals
AWS networking
VPC design
Route tables and Internet Gateways
Security Groups
EC2 provisioning
Application Load Balancers
Amazon RDS
Infrastructure as Code best practices
