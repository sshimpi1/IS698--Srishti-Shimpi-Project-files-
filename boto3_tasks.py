import boto3
import json

# --- Configuration ---
S3_BUCKET_NAME = "srishti-project-bucket-540821623764-unique-2025" # Replace with your actual unique name
KEY_PAIR_NAME = "srishti_project_key"
LAMBDA_FUNCTION_NAME = "srishti-s3-upload-logger"
REGION = 'us-east-1'

# --- Clients ---
ec2_client = boto3.client('ec2', region_name=REGION)
s3_client = boto3.client('s3', region_name=REGION)
lambda_client = boto3.client('lambda', region_name=REGION)

# --- Task 1: Create an S3 Bucket and upload a file ---
def create_and_upload_s3():
    try:
        # Create a dummy file to upload
        with open("test_upload.txt", "w") as f:
            f.write("This file triggers the Lambda function.")
        
        # Upload the file
        s3_client.upload_file("test_upload.txt", S3_BUCKET_NAME, "boto3_upload_log.txt")
        print(f"✅ S3 Upload successful. File uploaded to {S3_BUCKET_NAME}")
        
    except Exception as e:
        print(f"❌ S3 Upload/Creation Failed: {e}")

# --- Task 2: Retrieve EC2 metadata (Simple check for an instance) ---
def get_ec2_metadata():
    try:
        response = ec2_client.describe_instances(
            Filters=[
                {'Name': 'key-name', 'Values': [KEY_PAIR_NAME]}
            ]
        )
        instance_data = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instance_data.append({
                    "InstanceId": instance['InstanceId'],
                    "InstanceType": instance['InstanceType'],
                    "LaunchTime": str(instance['LaunchTime'])
                })
        print("\n✅ EC2 Metadata Retrieved:")
        print(json.dumps(instance_data, indent=2))
        
    except Exception as e:
        print(f"❌ EC2 Metadata retrieval failed: {e}")

# --- Task 3: List running EC2 instances (State check) ---
def list_running_ec2():
    try:
        response = ec2_client.describe_instances(
            Filters=[
                {'Name': 'instance-state-name', 'Values': ['running']}
            ]
        )
        running_ids = [
            i['InstanceId'] for r in response['Reservations'] for i in r['Instances']
        ]
        print("\n✅ Running EC2 Instances:")
        print(running_ids)
    except Exception as e:
        print(f"❌ Listing running EC2 failed: {e}")

# --- Task 4: Invoke Lambda manually ---
def invoke_lambda_manual():
    payload = json.dumps({"source": "Boto3 Manual Invoke", "time": "2025-12-05"})
    try:
        response = lambda_client.invoke(
            FunctionName=LAMBDA_FUNCTION_NAME,
            InvocationType='RequestResponse',
            Payload=payload
        )
        print(f"\n✅ Lambda Invocation successful. Status code: {response['StatusCode']}")
        print("   Check CloudWatch logs for 'Boto3 Manual Invoke' message.")
    except Exception as e:
        print(f"❌ Lambda Invocation Failed: {e}")


# --- Execute all tasks ---
if __name__ == "__main__":
    create_and_upload_s3()
    get_ec2_metadata()
    list_running_ec2()
    invoke_lambda_manual()