# Infrastructure Setup with EFS, ECS, and ALB

## **Objective**
This project aims to create a simple AWS infrastructure using **Terraform** to deploy a basic web application. The setup includes:
- **Amazon EFS** for storing HTML content.
- **Amazon ECS (Elastic Container Service)** for running an Nginx container.
- **Application Load Balancer (ALB)** for handling incoming traffic.
- **Security Groups** for controlling network access.

---

## **1. AWS Infrastructure Components**

### **Amazon EFS (Elastic File System)**
- Created an **Amazon EFS file system** named **`tm-devops-trainee-efs`**.
- Ensured that the EFS file system is **mounted on ECS instances** to store HTML content.
- Applied appropriate **security group settings** to restrict unauthorized access.

### **Amazon ECS (Elastic Container Service)**
- Defined an **ECS task definition** that runs an **Nginx container**.
- Used **a public Docker image of Nginx** from Docker Hub.
- Configured **EFS volume mount** inside the ECS container to serve the HTML content.
- Created an **ECS service** with **1 running task**.

### **Application Load Balancer (ALB)**
- Created an **ALB named `tm-devops-trainee-alb`**.
- Configured an **ALB listener on port 80** to forward traffic to the ECS service.
- Implemented **health checks** to monitor the availability of the ECS service.

### **Security Groups**
- Created **separate security groups** for ECS instances and ALB.
- Allowed **incoming traffic on port 80** from ALB to ECS instances.
- Configured appropriate **firewall rules** to enhance security.

### **Web Application**
- Created a **simple HTML page** with content:
  ```html
  Hello, TechMagic!
  ```
- Stored the **HTML page inside Amazon EFS**.
- Configured the **Nginx container** to serve this HTML content.

---

## **2. Terraform Implementation**
Terraform was used to define all the AWS resources in a **modular, reusable, and maintainable** way.

### **Project Structure**
```bash
terraform/
├── alb.tf
├── backend.tf
├── ec2
│    └── ec2.tf
├── ecs.tf
├── efs.tf
├── init_efs.sh
├── main.tf
├── outputs.tf
├── s3.tf
├── security_group.tf
├── target_group.tf
├── terraform.tfvars
├── variable.tf
└── vpc.tf

```

---

## **3. Deployment Instructions**

### **Pre-requisites**
- **Terraform v1.9.8 or later** installed.
- **AWS CLI** installed and configured with IAM credentials.
- **GitHub Actions configured** for CI/CD deployment.

### **Steps to Deploy**
#### **Step 1: Clone the Repository**
```bash
git clone https://github.com/your-repo/terraform-aws-infra.git
cd terraform-aws-infra
```

#### **Step 2: Configure AWS Credentials**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="eu-central-1"
```
Alternatively, use **AWS CLI**:
```bash
aws configure
```

#### **Step 3: Initialize Terraform**
```bash
terraform init
```

#### **Step 4: Validate Configuration**
```bash
terraform validate
```

#### **Step 5: Plan Deployment**
```bash
terraform plan -out=tfplan
```

#### **Step 6: Apply Deployment**
```bash
terraform apply -auto-approve tfplan
```

#### **Step 7: Get ALB Public URL**
```bash
terraform output alb_dns_name
```
Now, open the **ALB DNS name** in your browser to see the **Hello, TechMagic!** page.

---

## **4. CI/CD with GitHub Actions**
GitHub Actions was used to **automate infrastructure deployment**.

### **Workflow Overview**
- **Terraform Plan (`test` job)**: Runs on every `push` or `pull_request` to `main`.
- **Terraform Apply (`production` job)**: Runs **only after manual approval** in `GitHub Environments`.

### **GitHub Actions Workflow**
```yaml
name: Terraform Deployment

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

env:
  AWS_REGION: "eu-central-1"

jobs:
  test:
    name: Terraform Plan (Test)
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: terraform init
        working-directory: terraform

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: terraform

      - name: Upload Terraform Plan
        uses: actions/upload-artifact@v4
        with:
          name: tfplan
          path: terraform/tfplan

  production:
    name: Terraform Apply (Production)
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Download Terraform Plan
        uses: actions/download-artifact@v4
        with:
          name: tfplan
          path: terraform

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: terraform
```

---

## **5. Infrastructure Diagram**
*(Attach Lucidchart, Draw.io, or Excalidraw diagram here)*

---

## **6. Best Practices Followed**
- **Used Terraform modules** for modular infrastructure.
- **Implemented security best practices**.
- **Used ALB health checks** to maintain high availability.
- **Automated deployment with GitHub Actions**.

---

## **7. Conclusion**
This project provisions **EFS, ECS, and ALB** using Terraform and deploys a simple **web application** inside **AWS ECS**. The infrastructure follows **AWS best practices**, and the deployment process is automated using **GitHub Actions**.

🚀 **Now your AWS infrastructure is fully automated!**

