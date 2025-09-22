# Strapi-ci-cd
Project Structure
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


How It Works
This project is built around two distinct GitHub Actions workflows.

CI Pipeline (ci.yml)
This workflow is focused on Continuous Integration. It builds and packages the application.

Trigger: Automatically runs on every push to the main branch.

Steps:

Checks out the source code.

Logs into your AWS ECR account using the configured secrets.

Builds a Docker image of the Strapi application.

Tags the image with the unique Git commit SHA.

Pushes the tagged image to your private ECR repository.

CD Pipeline (terraform.yml)
This workflow is focused on Continuous Deployment. It provisions the infrastructure and deploys the application.

Trigger: This workflow is manually triggered from the "Actions" tab in GitHub.

Input: It requires you to provide the full ECR Image URI of the container you wish to deploy.

Steps:

Checks out the source code.

Sets up the Terraform CLI.

Initializes, plans, and applies the Terraform configuration.

Terraform provisions an EC2 instance, which pulls the specified Docker image from ECR and runs it as a container.

Deployment Process
To deploy an update to your application, follow these steps:

Push a Code Change: Make your desired changes to the Strapi application and push the commit to the main branch.

Bash

git push origin main
Wait for the CI Pipeline: Go to the Actions tab in your GitHub repository and wait for the "CI - Build and Push to ECR" workflow to complete successfully.

Copy the Image URI: In the completed CI workflow logs, find and copy the full Docker image URI. It will look like this:
123456789012.dkr.ecr.us-east-1.amazonaws.com/strapi-deployment:a1b2c3d4e5f6...

Trigger the CD Pipeline:

Navigate to the "CD - Terraform Deployment" workflow in the Actions tab.

Click the "Run workflow" dropdown.

Paste the copied Image URI into the input field.

Click the green "Run workflow" button.

Verify Deployment: Once the Terraform workflow is complete, check its logs. The public IP address of the EC2 instance will be listed in the "Terraform Apply" step's output. You can access your Strapi application at http://<your-public-ip>:1337.

