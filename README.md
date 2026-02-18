
# Terraform Project: Backend + Infra with Git Branches and Workspaces

## Overview

This project demonstrates a real-world Terraform setup using:

* Remote backend (S3 + DynamoDB)
* Separate backend and infrastructure folders
* Git branches for code separation (prod / dev)
* Terraform workspaces for state separation
* Environment-based resource naming and tagging

The goal is to safely manage **multiple environments (dev, prod)** using the **same Terraform codebase**, without state conflicts.

---

## Project Structure

```
terraform-project/
├── backend/
│   ├── provider.tf
│   ├── s3bucket.tf
│   ├── dynamodb.tf
│   └── terraform.tf
│
├── infra/
│   ├── main.tf
│   ├── ec2.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tf
│
├── .gitignore
└── README.md
```

---

## Backend Folder (Remote State Infrastructure)

### Purpose

The `backend/` folder is used **only once** to create:

* S3 bucket (Terraform state storage)
* DynamoDB table (state locking)

These resources must exist **before** Terraform infra can use a remote backend.

### Important Notes

* Backend resources should never be destroyed casually.
* Backend uses **local state**, not remote state.
* This folder is intentionally separated to avoid accidental deletion.

### Commands

```bash
cd backend
terraform init
terraform apply
```

---

## Infra Folder (Actual AWS Infrastructure)

### Purpose

The `infra/` folder contains all AWS infrastructure such as:

* Key pair
* Security groups
* EC2 instances
* Imported resources
* Environment-based tagging

This folder uses the **remote backend** created earlier.

---

## Remote Backend Configuration

In `infra/terraform.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "<your-s3-bucket>"
    key            = "terraform.tfstate"
    region         = "<region>"
    dynamodb_table = "<your-dynamodb-table>"
  }
}
```

### Initialize Infra with Backend

```bash
cd infra
terraform init -migrate-state
```

---

## Git Workflow

### Branch Strategy

| Branch | Purpose                 |
| ------ | ----------------------- |
| master | Production environment  |
| dev    | Development environment |

Git branches control **which Terraform code** is active.

---

## Terraform Workspaces

### Purpose

Terraform workspaces control **state isolation**, not code.

Each workspace has its own state file stored in the same S3 bucket.

### Workspace Mapping

| Git Branch | Terraform Workspace | Environment |
| ---------- | ------------------- | ----------- |
| master     | default             | prod        |
| dev        | dev                 | dev         |

### Create Workspace (one time)

```bash
cd infra
terraform workspace new dev
```

---

## Environment Variable Usage

Environment is controlled using a variable:

```hcl
variable "env" {
  default = "prod"
}
```

This variable is used in:

* Resource names
* Tags
* Key names

Example:

```hcl
Name = "${var.env}-ec2-instance"
Env  = var.env
```

---

## Applying Infrastructure

### Apply DEV Environment

```bash
git checkout dev
cd infra
terraform workspace select dev
terraform apply
```

### Apply PROD Environment

```bash
git checkout master
cd infra
terraform workspace select default
terraform apply
```

---

## Safety Checklist (MANDATORY before apply)

Always run these two commands before `terraform apply`:

```bash
git branch --show-current
terraform workspace show
```

Expected combinations:

* `master + default` → PROD
* `dev + dev` → DEV

If these do not match, **do not run apply**.

---

## Terraform State Behavior with Workspaces

Even though backend config specifies:

```hcl
key = "terraform.tfstate"
```

Terraform automatically stores state separately:

* Default workspace:

  ```
  terraform.tfstate
  ```

* Dev workspace:

  ```
  env:/dev/terraform.tfstate
  ```

This is handled automatically by Terraform.

---

## Git Ignore Strategy

Sensitive and generated files are excluded via `.gitignore`, including:

* `.terraform/`
* `terraform.tfstate*`
* private keys
* provider binaries
* local plugin folders

Only `.tf` files and documentation are committed.

---

## Key Design Decisions

* Backend and infra separated to avoid state loss
* Workspaces used only for state isolation
* Git branches used for code changes
* Environment variable used for naming and tagging
* Remote backend with locking prevents state conflicts

---

## Summary

This setup ensures:

* No state conflicts
* Safe multi-environment deployments
* Clean Git history
* Industry-standard Terraform workflow


