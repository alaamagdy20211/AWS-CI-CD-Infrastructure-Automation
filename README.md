# AWS CI/CD Infrastructure Automation

> A production-grade, fully automated cloud infrastructure project built with **Terraform**, **Ansible**, and **Jenkins** — provisioning, configuring, and deploying a Node.js application on AWS from scratch.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Infrastructure Components](#infrastructure-components)
  - [Remote State Backend](#remote-state-backend)
  - [Bootstrap Layer (Jenkins CI/CD)](#bootstrap-layer-jenkins-cicd)
  - [Application Infra Layer](#application-infra-layer)
- [CI/CD Pipeline](#cicd-pipeline)
  - [Infra Pipeline](#infra-pipeline)
  - [Configure Pipeline](#configure-pipeline)
  - [Deploy Pipeline](#deploy-pipeline)
- [Ansible Roles](#ansible-roles)
- [Application](#application)
- [Security Design](#security-design)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
  - [1. Create Remote State Backend](#1-create-remote-state-backend)
  - [2. Provision Jenkins Infrastructure](#2-provision-jenkins-infrastructure)
  - [3. Configure Jenkins Controller](#3-configure-jenkins-controller)
  - [4. Configure Jenkins Agent](#4-configure-jenkins-agent)
  - [5. Set Up Jenkins](#5-set-up-jenkins)
  - [6. Add Jenkins Credentials](#6-add-jenkins-credentials)
  - [7. Create Jenkins Pipeline Jobs](#7-create-jenkins-pipeline-jobs)
  - [8. Run the Pipelines](#8-run-the-pipelines)
- [Environment Variables](#environment-variables)
- [Multi-Environment Support](#multi-environment-support)
- [Credentials Reference](#credentials-reference)

---

## Project Overview

This project demonstrates a complete, real-world DevOps workflow built entirely on AWS. It covers every layer of the stack — from provisioning raw cloud infrastructure with Terraform, to configuring servers with Ansible, to deploying a live Node.js application through an automated Jenkins CI/CD pipeline.

**What makes this production-grade:**

- **Infrastructure as Code** — every AWS resource is defined in Terraform, versioned in Git, and reproducible from scratch
- **Isolated remote state** — Terraform state is stored in S3 with DynamoDB locking, with separate state keys per layer to prevent collisions
- **Modular Terraform** — reusable modules for network, security groups, EC2, RDS, Redis, ALB, SES, and notifications
- **Two-tier networking** — public/private subnet separation with bastion host access; app server never directly exposed to the internet
- **Ansible idempotency** — server configuration and deployments are repeatable; running roles multiple times produces the same clean result
- **Jenkins with Docker** — the Jenkins controller runs as a Docker container with a custom image, state persisted to a mounted volume, upgradeable by bumping an image tag
- **ProxyJump SSH** — Ansible reaches the private app server transparently through the bastion host, with no manual forwarding steps
- **PM2 process management** — the Node.js app is kept alive across crashes and EC2 reboots
- **Multi-environment** — `dev` and `prod` workspaces with separate `.tfvars` files targeting different AWS regions (us-east-1 / eu-central-1)
- **SES + Lambda notifications** — email alerts on every Terraform state file change, wired via S3 event notification

---

## Architecture

```
                          ┌─────────────────────────────────────────────┐
                          │                   AWS Cloud                  │
                          │                                              │
                          │   ┌──────────────────────────────────────┐  │
                          │   │              VPC (10.0.0.0/16)       │  │
                          │   │                                      │  │
                          │   │  ┌─────────────┐  ┌──────────────┐  │  │
                          │   │  │ Public       │  │ Private      │  │  │
                          │   │  │ Subnet       │  │ Subnet       │  │  │
                          │   │  │              │  │              │  │  │
                          │   │  │  ┌────────┐  │  │ ┌─────────┐ │  │  │
          Internet ───────┼───┼──┼─▶│Bastion │  │  │ │  App    │ │  │  │
                          │   │  │  │  EC2   │──┼──┼▶│  EC2    │ │  │  │
                          │   │  │  └────────┘  │  │ │(Node.js)│ │  │  │
                          │   │  │              │  │ └────┬────┘ │  │  │
                          │   │  │  ┌────────┐  │  │      │      │  │  │
                          │   │  │  │  ALB   │  │  │ ┌────▼────┐ │  │  │
          Users ──────────┼───┼──┼─▶│        │  │  │ │   RDS   │ │  │  │
                          │   │  │  └────────┘  │  │ │ (MySQL) │ │  │  │
                          │   │  │              │  │ └─────────┘ │  │  │
                          │   │  └─────────────┘  │              │  │  │
                          │   │                   │ ┌─────────┐  │  │  │
                          │   │                   │ │  Redis  │  │  │  │
                          │   │                   │ │(ElastiC)│  │  │  │
                          │   │                   │ └─────────┘  │  │  │
                          │   │                   └──────────────┘  │  │
                          │   └──────────────────────────────────────┘  │
                          │                                              │
                          │   ┌──────────────────────────────────────┐  │
                          │   │         Jenkins VPC (Bootstrap)       │  │
                          │   │                                      │  │
                          │   │  ┌─────────────┐  ┌──────────────┐  │  │
                          │   │  │  Jenkins    │  │   Jenkins    │  │  │
          Developer ──────┼───┼─▶│ Controller  │─▶│    Agent     │  │  │
                          │   │  │ (Docker)    │  │(Ansible+TF)  │  │  │
                          │   │  └─────────────┘  └──────────────┘  │  │
                          │   └──────────────────────────────────────┘  │
                          │                                              │
                          │   ┌──────────────┐   ┌───────────────────┐  │
                          │   │  S3 Bucket   │   │  DynamoDB Table   │  │
                          │   │ (TF State)   │   │  (State Lock)     │  │
                          │   └──────┬───────┘   └───────────────────┘  │
                          │          │                                   │
                          │   ┌──────▼───────┐   ┌───────────────────┐  │
                          │   │    Lambda    │──▶│       SES         │  │
                          │   │  (notifier)  │   │  (email alerts)   │  │
                          │   └──────────────┘   └───────────────────┘  │
                          └─────────────────────────────────────────────┘
```

---

## Technology Stack

| Tool | Version | Purpose |
|---|---|---|
| **Terraform** | >= 1.5.0 | Infrastructure provisioning |
| **Ansible** | >= 2.15 | Server configuration & deployment |
| **Jenkins** | LTS (jdk17) | CI/CD orchestration |
| **Docker** | Latest | Jenkins controller runtime |
| **AWS** | — | Cloud provider |
| **Node.js** | 20.x LTS | Application runtime |
| **PM2** | Latest | Node.js process management |
| **MySQL (RDS)** | 8.x | Application database |
| **Redis (ElastiCache)** | 7.x | Application cache |
| **Ubuntu** | 22.04 LTS | EC2 OS (all instances) |

---

## Project Structure

```
project-root/
│
├── README.md
├── .gitignore
│
├── terraform/
│   ├── backend-setup/              # One-time: creates S3 state bucket + DynamoDB lock table
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── provider.tf
│   │
│   ├── bootstrap/                  # Jenkins controller + agent infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   ├── backend.tf
│   │   ├── modules/
│   │   │   ├── ec2-controller/
│   │   │   ├── ec2-agent/
│   │   │   ├── network/
│   │   │   └── security/
│   │   └── templates/
│   │       ├── inventory.tpl
│   │       └── ssh_config.tpl
│   │
│   └── infra/                      # Application infrastructure (managed by Jenkins)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── backend.tf
│       ├── modules/
│       │   ├── network/            # VPC, subnets, IGW, route tables
│       │   ├── ec2/                # Bastion + app EC2 instances
│       │   ├── security/           # Security groups
│       │   ├── alb/                # Application Load Balancer
│       │   ├── rds/                # MySQL RDS instance
│       │   ├── redis/              # ElastiCache Redis cluster
│       │   ├── ses/                # SES email identity
│       │   └── notifications/      # Lambda + S3 state-change trigger
│       ├── envs/
│       │   ├── dev.tfvars          # us-east-1
│       │   └── prod.tfvars         # eu-central-1
│       └── templates/
│           ├── inventory.tpl
│           └── ssh_config.tpl
│
├── ansible/
│   ├── ansible.cfg
│   ├── requirements.yml            # community.docker collection
│   ├── inventory/
│   │   ├── ssh_config              # Static Include file (never overwritten)
│   │   ├── ssh_config_bootstrap    # Generated by terraform/bootstrap
│   │   └── ssh_config_infra        # Generated by terraform/infra
│   │
│   ├── playbooks/
│   │   ├── setup_jenkins_controller.yml
│   │   ├── setup_jenkins_agent.yml
│   │   ├── setup_node.yml          # Configures app server (Node.js, PM2)
│   │   └── deploy_app.yml          # Deploys the Node.js application
│   │
│   └── roles/
│       ├── jenkins_controller/     # Installs Docker, builds custom Jenkins image
│       │   ├── tasks/main.yml
│       │   ├── handlers/main.yml
│       │   ├── defaults/main.yml
│       │   └── files/Dockerfile
│       ├── jenkins_agent/          # Java, Terraform CLI, Ansible, EC2 key
│       │   ├── tasks/main.yml
│       │   ├── handlers/main.yml
│       │   └── defaults/main.yml
│       ├── nodejs/                 # Node.js 20.x via NodeSource
│       ├── pm2/                    # PM2 process manager
│       └── app/                    # Clone repo, npm install, PM2 ecosystem config
│           ├── tasks/main.yml
│           ├── defaults/main.yml
│           └── templates/
│               └── ecosystem.config.js.j2
│
└── jenkins/
    ├── Jenkinsfile.infra           # Provisions/updates AWS infrastructure
    ├── Jenkinsfile.configure       # Configures the app EC2 (run once)
    └── Jenkinsfile.deploy          # Deploys the Node.js app (runs on every push)
```

---

## Infrastructure Components

### Remote State Backend

Before any other Terraform layer can run, the state backend must exist. This is a one-time, manual step.

**Resources created:**
- S3 bucket with versioning, AES-256 encryption, and all public access blocked
- DynamoDB table for state locking (`LockID` hash key, `PAY_PER_REQUEST` billing)

**Why isolated:** this root has no remote backend of its own — it's the chicken-and-egg exception. Its local `terraform.tfstate` lives in the `backend-setup/` folder on your laptop and should never be deleted.

**State key layout inside the bucket:**
```
your-bucket-name/
├── bootstrap/terraform.tfstate     ← Jenkins infrastructure
└── infra/<workspace>/terraform.tfstate   ← Application infrastructure (dev/prod)
```

---

### Bootstrap Layer (Jenkins CI/CD)

Provisions the Jenkins controller and agent EC2 instances that run all subsequent automation.

**Resources created:**

| Resource | Details |
|---|---|
| VPC | `10.10.0.0/16`, DNS support enabled |
| Public subnet | `10.10.1.0/24`, `us-east-1a`, public IPs on launch |
| Internet Gateway | Attached to bootstrap VPC |
| Public route table | Default route `0.0.0.0/0` → IGW |
| Jenkins controller EC2 | Ubuntu 22.04, `c7i-flex.large`, public subnet |
| Jenkins agent EC2 | Ubuntu 22.04, `c7i-flex.large`, public subnet |
| Controller security group | SSH (22), Jenkins UI (8080), JNLP (50000 from agent SG only) |
| Agent security group | SSH (22) only |

**Generated outputs (written to `ansible/inventory/` after apply):**
- `ansible/inventory/bootstrap.ini` — Ansible inventory for controller/agent
- `ansible/inventory/ssh_config_bootstrap` — SSH config with controller/agent IPs

---

### Application Infra Layer

The core application infrastructure, managed entirely by the Jenkins `infra-pipeline`. Never applied manually after initial setup.

**Modules and resources:**

**`network/`**
- VPC with DNS support
- 2 public subnets across 2 AZs
- 2 private subnets across 2 AZs
- Internet Gateway
- Public route table (default route → IGW)
- Private route table (local only)
- Route table associations for all subnets

**`security/`**
- `bastion-sg` — inbound SSH from `0.0.0.0/0`, all egress
- `app-sg` — inbound SSH from VPC CIDR, port 3000 from ALB SG, all egress
- `alb-sg` — inbound HTTP (80) from `0.0.0.0/0`, all egress
- `rds-sg` — inbound MySQL (3306) from app SG only
- `redis-sg` — inbound Redis (6379) from app SG only

**`ec2/`**
- Bastion EC2 — Ubuntu 22.04, public subnet, `t3.micro`
- App EC2 — Ubuntu 22.04, private subnet, `t3.micro`
- Dynamic AMI lookup (always latest Ubuntu 22.04, no hardcoded AMI IDs)
- `local-exec` provisioner prints bastion public IP to console on apply

**`alb/`**
- Application Load Balancer (internet-facing, public subnets)
- Target group (HTTP, port 80, `/` health check)
- Listener (HTTP:80 → forward to target group)
- Target group attachment (app EC2)

**`rds/`**
- MySQL 8.x RDS instance
- DB subnet group (private subnets)
- Dedicated security group (port 3306 from app SG only)

**`redis/`**
- ElastiCache Redis cluster
- Cache subnet group (private subnets)
- Dedicated security group (port 6379 from app SG only)

**`ses/`**
- SES email identity verification
- Note: both sender and recipient must be verified in sandbox mode

**`notifications/`**
- Lambda function (Python 3.x) — parses S3 event, calls `ses.send_email()`
- IAM execution role with `ses:SendEmail` + CloudWatch Logs permissions
- S3 bucket notification on the state bucket — triggers on every `terraform apply`
- Lambda permission allowing S3 to invoke the function

---

## CI/CD Pipeline

Three Jenkinsfiles, each with a specific, non-overlapping responsibility.

### Infra Pipeline

**File:** `jenkins/Jenkinsfile.infra`
**Trigger:** manual (or push to `terraform/**`)
**Runs on:** Jenkins agent

```
┌─────────────┐    ┌──────────────────┐    ┌─────────────────────┐
│   Checkout  │───▶│  Terraform Init  │───▶│  Terraform Plan /   │
│             │    │  + Workspace     │    │  Apply              │
└─────────────┘    └──────────────────┘    └─────────────────────┘
```

**Parameters:**
- `WORKSPACE` — `dev` or `prod`
- `ACTION` — `plan` or `apply`

**Credentials used:** `aws-creds` (AWS access key + secret)

---

### Configure Pipeline

**File:** `jenkins/Jenkinsfile.configure`
**Trigger:** manual — run once when a new app server is provisioned
**Runs on:** Jenkins agent

```
┌─────────────┐    ┌──────────────────────────────────────────────────┐
│   Checkout  │───▶│  ansible-playbook setup_node.yml                 │
│             │    │  → nodejs role (Node.js 20.x via NodeSource)     │
│             │    │  → pm2 role (PM2 process manager)                │
└─────────────┘    └──────────────────────────────────────────────────┘
```

**Credentials used:** `ec2-ssh-key`

---

### Deploy Pipeline

**File:** `jenkins/Jenkinsfile.deploy`
**Trigger:** automatic on every push to `main`
**Runs on:** Jenkins agent

```
┌─────────────┐    ┌─────────────────────────────────────────────────────────────┐
│   Checkout  │───▶│  ansible-playbook deploy_app.yml                            │
│             │    │  → app role:                                                │
│             │    │      git clone rds-redis branch                             │
│             │    │      npm install                                             │
│             │    │      generate ecosystem.config.js (env vars injected)       │
│             │    │      pm2 start / restart                                     │
│             │    │      health check /db endpoint                               │
└─────────────┘    └─────────────────────────────────────────────────────────────┘
```

**Credentials used:** `ec2-ssh-key`, `rds-db-creds`, `rds-endpoint`, `redis-endpoint`

---

## Ansible Roles

### `jenkins_controller`
Installs Docker on the controller EC2, builds a minimal custom Jenkins image (extends `jenkins/jenkins:lts-jdk17` with `openssh-client` only — no build tooling, keeping the controller's responsibility to orchestration alone), runs the container with a persistent `jenkins_home` volume, and generates the controller-to-agent SSH keypair. The initial admin password is printed to the Ansible output at the end.

### `jenkins_agent`
Installs Java 17 (hard requirement for `agent.jar`), creates a dedicated unprivileged `jenkins` user and work directory, authorizes the controller's public key (generated by the controller playbook), installs Terraform CLI, installs Ansible, and copies the EC2 keypair onto the agent so it can reach the bastion/app server over SSH during pipeline runs.

**Why Ansible on the agent, not the controller:** the controller's sole responsibility is orchestration (scheduling jobs, managing credentials, talking to agents). Build tooling belongs on the agent, which is where pipeline steps actually execute. This matches real-world production Jenkins architecture.

### `nodejs`
Adds the NodeSource apt repository for Ubuntu 22.04 and installs Node.js 20.x LTS. Configurable via `nodejs_major_version` default variable.

### `pm2`
Installs PM2 globally via npm. PM2 keeps the Node.js application alive across crashes and reboots. Running `pm2 save` + `pm2 startup` ensures the process list is restored automatically after an EC2 restart.

### `app`
The deployment role. Clones the application repository (`mahmoud254/jenkins_nodejs_example`, branch `rds-redis`), runs `npm install`, generates a PM2 ecosystem config file from a Jinja2 template (injecting RDS/Redis connection details as environment variables at render time — never hardcoded), stops any previous PM2 process cleanly, starts the app, and runs a basic health check against `http://localhost:3000/db`.

---

## Application

The deployed application is a Node.js/Express app from [mahmoud254/jenkins_nodejs_example](https://github.com/mahmoud254/jenkins_nodejs_example) (branch: `rds-redis`).

**Endpoints:**

| Endpoint | What it tests |
|---|---|
| `GET /db` | MySQL RDS connection — returns `"db connection successful"` or `"db connection failed"` |
| `GET /redis` | Redis connection — returns `"redis is successfully connected"` or `"redis connection failed"` |

**Connection configuration (all via environment variables, injected by PM2 ecosystem config):**

```
RDS_HOSTNAME    → RDS endpoint
RDS_USERNAME    → RDS master username
RDS_PASSWORD    → RDS master password (from Jenkins credential, never logged)
RDS_PORT        → 3306
REDIS_HOSTNAME  → ElastiCache Redis endpoint
REDIS_PORT      → 6379
```

None of these values are committed to the repository. They flow from **Jenkins Credentials** → `withCredentials()` block → `ansible-playbook -e` flags → Ansible role defaults override → Jinja2 template → `ecosystem.config.js` on the app server at deploy time.

---

## Security Design

### Network Security

- The app server has **no public IP** — only reachable via SSH through the bastion host (ProxyJump), or via HTTP through the ALB on port 80
- RDS and Redis are in **private subnets** and accept traffic only from the app server's security group — not from the VPC CIDR broadly
- Security group rules use **SG-to-SG references** (not CIDR blocks) wherever possible, e.g. ALB SG → app SG, app SG → RDS SG, app SG → Redis SG — tighter and self-documenting
- Egress rules are explicitly defined on all custom security groups (not relying on implicit AWS defaults, which only apply to the default SG)

### Secrets Management

- **No secrets in the repository** — all credentials (AWS keys, DB password, SSH private keys, RDS/Redis endpoints) live in Jenkins Credentials store
- **Private key never touches disk permanently on the agent** — the `ec2-ssh-key` credential is written to a temp file for the duration of one pipeline step and discarded. The static copy at `/home/jenkins/.ssh/pk_project_ec2.pem` (placed by the `jenkins_agent` role) is the only persistent exception, scoped to the `jenkins` user with `0400` permissions
- **Terraform state is encrypted at rest** — S3 server-side encryption (AES-256) enabled on the state bucket
- **State bucket is fully private** — all public access paths blocked explicitly

### SSH Architecture

```
Your laptop ─────────────────────────────────▶ Jenkins controller (SSH, EC2 key)
Your laptop ─────────────────────────────────▶ Jenkins agent (SSH, EC2 key)

Jenkins agent ──ProxyJump through bastion────▶ App EC2 (SSH, EC2 key)
    │
    ├── ssh_config_infra defines:
    │       Host bastion → public IP, IdentityFile, StrictHostKeyChecking no
    │       Host app-server → private IP, ProxyJump bastion, IdentityFile
    │
    └── Ansible uses --ssh-common-args="-F inventory/ssh_config_infra"

Jenkins controller ──────────────────────────▶ Jenkins agent (SSH, generated keypair)
    │
    └── Keypair generated by setup_jenkins_controller.yml
        Public key authorized on agent by setup_jenkins_agent.yml
        Private key stays on controller at /home/ubuntu/.ssh/jenkins_agent_key
```

---

## Prerequisites

Before running anything, ensure you have the following on your local machine:

```bash
# Terraform
terraform -version   # >= 1.5.0

# Ansible
ansible --version    # >= 2.15

# AWS CLI
aws --version
aws configure        # set access key, secret, region

# Ansible Docker collection (for Jenkins controller setup)
ansible-galaxy collection install -r ansible/requirements.yml
```

**AWS resources required before running Terraform:**
- An AWS account with IAM user having programmatic access
- IAM permissions: VPC, EC2, RDS, ElastiCache, S3, DynamoDB, Lambda, SES, IAM
- An EC2 key pair created in AWS → downloaded as `~/.ssh/pk_project_ec2.pem` → `chmod 400 ~/.ssh/pk_project_ec2.pem`

---

## Getting Started

### 1. Create Remote State Backend

```bash
cd terraform/backend-setup
terraform init
terraform apply -var="state_bucket_name=your-unique-name-tfstate"
```

Note the output values — you'll need them in the next step:
```
state_bucket_name = "your-unique-name-tfstate"
lock_table_name   = "terraform-state-lock"
```

---

### 2. Provision Jenkins Infrastructure

Edit `terraform/bootstrap/backend.tf` and replace the placeholder bucket/table names with the values from step 1.

```bash
cd terraform/bootstrap
terraform init
terraform apply -var="key_name=pk_project_ec2"
```

This creates the controller and agent EC2 instances and automatically generates:
- `ansible/inventory/bootstrap.ini`
- `ansible/inventory/ssh_config_bootstrap`

---

### 3. Configure Jenkins Controller

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml

ansible-playbook playbooks/setup_jenkins_controller.yml \
  -e "ec2_private_key_local_path=~/.ssh/pk_project_ec2.pem"
```

**Copy the initial admin password printed at the end of the playbook output.**

---

### 4. Configure Jenkins Agent

```bash
ansible-playbook playbooks/setup_jenkins_agent.yml \
  -e "ec2_private_key_local_path=~/.ssh/pk_project_ec2.pem"
```

> **Order matters:** the controller playbook must run first — it generates the controller→agent SSH keypair and fetches the public key locally, which the agent playbook then authorizes.

---

### 5. Set Up Jenkins

1. Open `http://<controller_public_ip>:8080` in your browser
2. Paste in the initial admin password from step 3
3. Click **Install suggested plugins**
4. Create your admin user
5. Go to **Manage Jenkins → Nodes → New Node**:
   - Name: `jenkins-agent`, label: `jenkins-agent`
   - Remote root directory: `/home/jenkins/agent`
   - Launch method: **Launch agents via SSH**
   - Host: agent's public IP
   - Credentials: add a new SSH credential — username `jenkins`, paste the contents of `/home/ubuntu/.ssh/jenkins_agent_key` from the controller
   - Host Key Verification: **Non verifying**

---

### 6. Add Jenkins Credentials

Go to **Manage Jenkins → Credentials → System → Global credentials → Add Credentials** for each:

| ID | Kind | Value |
|---|---|---|
| `ec2-ssh-key` | SSH Username with private key | contents of `pk_project_ec2.pem`, username `ubuntu` |
| `aws-creds` | Username with password | AWS Access Key ID / Secret Access Key |
| `bastion-ip` | Secret text | bastion EC2 public IP |
| `app-ip` | Secret text | app EC2 private IP |
| `rds-db-creds` | Username with password | RDS master username / password |
| `rds-endpoint` | Secret text | RDS endpoint hostname |
| `redis-endpoint` | Secret text | ElastiCache Redis endpoint hostname |

---

### 7. Create Jenkins Pipeline Jobs

Create three pipeline jobs in Jenkins (**New Item → Pipeline**):

| Job name | Jenkinsfile path | Trigger |
|---|---|---|
| `infra-pipeline` | `jenkins/Jenkinsfile.infra` | Manual |
| `configure-pipeline` | `jenkins/Jenkinsfile.configure` | Manual (once per new server) |
| `deploy-pipeline` | `jenkins/Jenkinsfile.deploy` | Push to `main` branch |

For each: select **Pipeline script from SCM** → Git → your repo URL → branch `main`.

Add a GitHub webhook for `deploy-pipeline`:
- Go to your GitHub repo → **Settings → Webhooks → Add webhook**
- Payload URL: `http://<controller_public_ip>:8080/github-webhook/`
- Content type: `application/json`
- Event: **Just the push event**

---

### 8. Run the Pipelines

**First time, in this order:**

```
1. infra-pipeline     → WORKSPACE=dev, ACTION=apply   (provisions VPC, EC2, RDS, Redis, ALB)
2. configure-pipeline                                  (installs Node.js + PM2 on app server)
3. deploy-pipeline                                     (deploys the app, starts via PM2)
```

**Verify the deployment:**
```
http://<alb_dns_name>/db      → should return "db connection successful"
http://<alb_dns_name>/redis   → should return "redis is successfully connected"
```

---

## Environment Variables

The following environment variables are required by the application at runtime. They are never committed to the repository — they are injected by the `deploy-pipeline` at deploy time via Ansible.

| Variable | Source | Description |
|---|---|---|
| `RDS_HOSTNAME` | `rds-endpoint` Jenkins credential | RDS MySQL endpoint |
| `RDS_USERNAME` | `rds-db-creds` Jenkins credential | RDS master username |
| `RDS_PASSWORD` | `rds-db-creds` Jenkins credential | RDS master password |
| `RDS_PORT` | Ansible role default | `3306` |
| `REDIS_HOSTNAME` | `redis-endpoint` Jenkins credential | ElastiCache Redis endpoint |
| `REDIS_PORT` | Ansible role default | `6379` |

---

## Multi-Environment Support

The project supports two fully isolated environments using Terraform workspaces:

| Workspace | Region | `.tfvars` file |
|---|---|---|
| `dev` | `us-east-1` | `terraform/infra/envs/dev.tfvars` |
| `prod` | `eu-central-1` | `terraform/infra/envs/prod.tfvars` |

Each workspace maintains its own state file at a distinct key path:
```
infra/dev/terraform.tfstate
infra/prod/terraform.tfstate
```

Switch environments in the `infra-pipeline` by selecting the `WORKSPACE` parameter (`dev` or `prod`) when triggering a build.

---

## Credentials Reference

Complete reference of all Jenkins credentials used across the three pipelines:

| Credential ID | Kind | Used by | Purpose |
|---|---|---|---|
| `ec2-ssh-key` | SSH Username with private key | all three pipelines | SSH access to EC2 instances |
| `aws-creds` | Username with password | `infra-pipeline` | Terraform AWS API access |
| `bastion-ip` | Secret text | `configure-pipeline`, `deploy-pipeline` | Bastion host IP for ProxyJump |
| `app-ip` | Secret text | `configure-pipeline`, `deploy-pipeline` | App server private IP |
| `rds-db-creds` | Username with password | `deploy-pipeline` | RDS authentication |
| `rds-endpoint` | Secret text | `deploy-pipeline` | RDS hostname |
| `redis-endpoint` | Secret text | `deploy-pipeline` | Redis hostname |
