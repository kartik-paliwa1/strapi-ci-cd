# Strapi-ci-cd



Project Structure
```bash

.
├── .github/workflows/
│   ├── ci.yml          # Workflow to build and push the Docker image to ECR.
│   └── terraform.yml   # Workflow to deploy the infrastructure using Terraform.
├── terraform/
│   ├── main.tf         # Defines the AWS EC2 instance, IAM role, and security group.
│   ├── variables.tf    # Defines input variables for the Terraform configuration.
│   └── outputs.tf      # Defines the output values (like the server's public IP).
├── src/                # Strapi source code.
├── Dockerfile          # Instructions to build the Strapi application into a Docker image.
└── .dockerignore       # Specifies files to exclude from the Docker image.

```

## How It Works
The automation is split into two distinct workflows:

### 1. CI Pipeline (Build & Push Image)
This workflow runs automatically whenever code is pushed to the main branch.

Code Push: A developer pushes new commits to the main branch.

Trigger Action: The ci.yml GitHub Action is triggered.

Build Image: The action builds a Docker image of the Strapi application.

Push to Registry: The new image is tagged with the commit SHA and pushed to a private AWS Elastic Container Registry (ECR).

### 2. CD Pipeline (Deploy to EC2)
This workflow must be triggered manually from the GitHub Actions tab.

Manual Trigger: A user navigates to the "Actions" tab and runs the "CD - Terraform Deployment" workflow.

Provide Image URI: The user provides the full URI of the Docker image from the CI pipeline (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com/strapi-deployment:commit-sha).

Run Terraform: The terraform.yml action runs terraform apply.

Create Infrastructure: Terraform creates an EC2 instance and an associated IAM role that allows it to pull images from ECR.

Start Application: The EC2 instance pulls the specified Docker image from ECR and runs the Strapi container.

## Getting Started
Follow these steps to set up the project and the required cloud infrastructure.

### Prerequisites
- An AWS Account with access to create IAM, EC2, and ECR resources.

- A GitHub Account.

- Node.js (v18+) installed locally.

- Terraform CLI installed locally.

#### Configuration Steps
#### 1.Clone the Repository

```bash

git clone https://github.com/your-username/strapi-ci-cd.git
cd strapi-ci-cd
```
#### 2.Create AWS ECR Repository

Log in to your AWS Console.

Navigate to the Elastic Container Registry (ECR) service.

Create a new private repository. For this project, the recommended name is strapi-deployment.

#### 3. Create an AWS IAM User

In the AWS IAM service, create a new user with programmatic access.

Attach the AmazonEC2ContainerRegistryPowerUser policy to this user. This provides the necessary permissions for GitHub Actions to push images to ECR.

Save the generated Access Key ID and Secret Access Key.

#### 4.Set Up GitHub Secrets

In your GitHub repository, navigate to Settings > Secrets and variables > Actions.

Create the following repository secrets:

Secret Name	Description
AWS_ACCESS_KEY_ID	The Access Key ID from the IAM user you created.
AWS_SECRET_ACCESS_KEY	The Secret Access Key from the IAM user.
AWS_REGION	The AWS region of your ECR repository (e.g., us-east-1).
ECR_REPOSITORY	The name of your ECR repository (e.g., strapi-deployment).
#### 5.Review Terraform Configuration

Open the terraform/main.tf file.

If you are using a region other than us-east-1, you may need to update the ami value to a valid Ubuntu 20.04 AMI for your chosen region.

## Deployment Flow

- Develop Locally: Make your desired changes to the Strapi application.

- Push to Main: Commit your changes and push them to the main branch.

```bash

git add .
git commit -m "Your feature or fix description"
git push origin main
```
- Monitor CI Action: Go to the Actions tab in your GitHub repository. Wait for the "CI - Build and Push to ECR" workflow to complete successfully.

- Copy Image URI: In the completed CI workflow log, find and copy the full Docker image URI. It will look like this: 123456789012.dkr.ecr.us-east-1.amazonaws.com/strapi-deployment:76351dae...

- Trigger Deployment:

Navigate to the Actions tab.

Select the "CD - Terraform Deployment" workflow from the list.

Click the "Run workflow" dropdown.

Paste the full image URI into the image_uri input field.

Click the green "Run workflow" button.

- Verify Deployment:

Wait for the Terraform action to complete.

In the job logs for the apply step, find the public_ip output value.

Open your web browser and navigate to http://<your-public-ip>:1337 to see your running Strapi application.
