

The project structure is :

```
~/terraform-project/
   backend/
   infra/
```

---

#  PHASE 1: Git Setup (Clean repo)

## 1️⃣ Go to root folder

```bash
cd ~/terraform-project
```

## 2️⃣ Initialize git

```bash
git init
```

## 3️⃣ Create `.gitignore` (VERY FIRST THING)

```bash
nano .gitignore
```

Paste this:

```gitignore
# Terraform
**/.terraform/
**/.terraform.lock.hcl

# State files
**/*.tfstate
**/*.tfstate.*
**/*.tfstate.backup

# Crash logs
**/crash.log
**/crash.*.log

# tfvars (may contain secrets)
**/*.tfvars
**/*.tfvars.json

# Keys
**/*.pem
**/*.key
**/*.pub

# Plans
**/*.tfplan

# Extra junk
infra/aws/
infra/x.txt
infra/y.txt
backend/remote-backend
```

Save.

---

## 4️⃣ Add only safe terraform code

```bash
git add .gitignore
git add backend/*.tf
git add infra/*.tf
```

## 5️⃣ Commit on master

```bash
git commit -m "initial terraform backend and infra code"
```

If branch is not master, rename:

```bash
git branch -m master
```

---

#  PHASE 2: Terraform Backend Setup (backend folder)

## 6️⃣ Go to backend folder

```bash
cd ~/terraform-project/backend
```

## 7️⃣ Initialize terraform (local state for backend)

```bash
terraform init
```

## 8️⃣ Apply backend infra (creates S3 + DynamoDB)

```bash
terraform apply
```

Now backend infra exists in AWS.

---

#  PHASE 3: Configure Remote Backend in Infra Folder

## 9️⃣ Go to infra folder

```bash
cd ~/terraform-project/infra
```

## 🔟 Run init to connect infra to backend

If backend block already exists in `infra/terraform.tf`, run:

```bash
terraform init -reconfigure
```

If you already had local state and want to move it:

```bash
terraform init -migrate-state
```

Now infra state is stored in S3 and locking works with DynamoDB.

---

#  PHASE 4: Terraform Workspace Setup

## 1️⃣1️⃣ Confirm current workspace

```bash
terraform workspace show
```

Should show:

```
default
```

## 1️⃣2️⃣ Create dev workspace (only once)

```bash
terraform workspace new dev
```

Check:

```bash
terraform workspace list
```

---

#  PHASE 5: Create Git dev branch + change env

## 1️⃣3️⃣ Go to project root

```bash
cd ~/terraform-project
```

## 1️⃣4️⃣ Create dev branch

```bash
git checkout -b dev
```

Now you're on dev branch.

## 1️⃣5️⃣ Modify env in infra variables file

Edit:

```bash
nano infra/variable.tf
```

Change env:

```hcl
variable "env" {
  default = "dev"
}
```

Commit:

```bash
git add infra/variable.tf
git commit -m "dev: set env to dev"
```

---

#  PHASE 6: Apply DEV infra (dev branch + dev workspace)

## 1️⃣6️⃣ Go infra folder

```bash
cd ~/terraform-project/infra
```

## 1️⃣7️⃣ Select dev workspace

```bash
terraform workspace select dev
```

## 1️⃣8️⃣ Apply

```bash
terraform apply
```

Now DEV infra is created.

---

#  PHASE 7: Switch back to PROD (master + default)

## 1️⃣9️⃣ Switch Git branch to master

```bash
cd ~/terraform-project
git checkout master
```

## 2️⃣0️⃣ Ensure master has env=prod

Edit:

```bash
nano infra/variable.tf
```

Set:

```hcl
variable "env" {
  default = "prod"
}
```

Commit:

```bash
git add infra/variable.tf
git commit -m "master: set env to prod"
```

---

## 2️⃣1️⃣ Switch terraform workspace to default

```bash
cd ~/terraform-project/infra
terraform workspace select default
```

## 2️⃣2️⃣ Apply PROD infra

```bash
terraform apply
```

Now PROD infra is created.

---

#  DAILY USAGE 

## For DEV

```bash
cd ~/terraform-project
git checkout dev
cd infra
terraform workspace select dev
terraform apply
```

## For PROD

```bash
cd ~/terraform-project
git checkout master
cd infra
terraform workspace select default
terraform apply
```

---

# SAFETY CHECK BEFORE APPLY (MUST DO)

Before any apply, run:

```bash
git branch --show-current
terraform workspace show
```

Expected combinations:

| Branch | Workspace | Meaning |
| ------ | --------- | ------- |
| master | default   | PROD    |
| dev    | dev       | DEV     |

---

# What this setup gives you

* Same Terraform code structure
* Two different environments
* Two different remote state files in S3
* Locking prevents multiple apply at same time

---

