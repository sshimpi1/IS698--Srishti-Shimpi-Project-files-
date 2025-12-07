Project Overview
The project is focused on designing and implementing a scalable multi-tiered cloud architecture on AWS. 
The key objective shall be to demonstrate skills in implementing a secure environment for hosting web applications, securing resources with VPC, and automating monitoring using serverless components.
Terraform manages the entire infrastructure deployment for networking, while AWS CloudFormation is used for application resources.

Architecture Overview
The deployed architecture is based on a classic three-tier pattern to make it secure and highly available:
Networking: A dedicated VPC with a separate Public (for access) and Private (for security) subnets spanning across Availability Zones.
Tier 1: Presentation Layer - An ALB distributes incoming web traffic load with efficiency.
Tier 2 (Application): EC2 Instances running a simple web app managed by an ASG for resiliency and scalability.
Tier 3 (Data): An RDS Database - MySQL/PostgreSQL is securely isolated inside the Private Subnets.
Storage & Logging: An S3 Bucket storing files/ logs will trigger an AWS Lambda function, which writes logs into CloudWatch on every new file that gets uploaded.
Security: Security Groups tightly regulate all network traffic between tiers: ALB → EC2 → RDS.

Prerequisites
It tells the user all the information that's needed before running your scripts.
AWS Account: The candidate should have an active AWS account.
IAM Permissions: Administrative permissions or specific IAM permissions are required in particular, such as EC2, RDS, Lambda, and S3.
AWS CLI (Configured and authenticated)
Git
Python 3.x and Boto3-if they run your Boto3 script CloudFormation/Terraform

Quick Deployment Steps Follow these steps to deploy the full Multi-AZ architecture from your terminal:
1. ⚙️ Setup & Initialize
Clone the repository:
Bash  git clone [YOUR-REPOSITORY-URL]
  cd [project-folder]
Ensure prerequisites: Verify the AWS CLI is configured and your Key Pair exists.

2. 🌐 Deploy Networking (Terraform)
This creates the VPC, all subnets (Public/Private, AZs), and Security Groups.
Bash  cd terraform/
  terraform init
  terraform apply --auto-approve

3. 🖥️ Deploy Application (CloudFormation)
This launches the ALB, ASG, EC2 instances, RDS database, S3 bucket, and Lambda function.
Bash
  cd ../cloudformation/
  aws cloudformation create-stack \
    --stack-name SrishtiProjectStack \
    --template-body file://srishti-full-architecture.yaml \
    --parameters ParameterKey=KeyName,ParameterValue=[YOUR-KEY-PAIR-NAME] \
    --capabilities CAPABILITY_IAM
   
4. ✅ Validate Functionality (Boto3)
Run the Python script to test the web tier and confirm the S3-to-Lambda logging mechanism is active.
Bash  
    cd ../boto3-scripts/
    python3 boto3_tasks.py
   
5. 🔎 Final Verification
Web App: Get the ALB DNS Name from the CloudFormation stack outputs and paste it into your browser.
Logging: Check the CloudWatch Log Group (/aws/lambda/srishti-s3-upload-logger) for the two new log entries created by the Boto3 script.
