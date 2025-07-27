#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

STACK_NAME="serverless-user-api"
REGION="us-east-1"

echo -e "${YELLOW}=== Serverless User API Cleanup ===${NC}"
echo ""

# Check if stack exists
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" &>/dev/null
if [ $? -ne 0 ]; then
    echo -e "${RED}Stack $STACK_NAME not found in region $REGION${NC}"
    exit 1
fi

echo -e "${YELLOW}Stack Details:${NC}"
echo "Stack Name: $STACK_NAME"
echo "Region: $REGION"
echo ""

echo -e "${RED}WARNING: This will delete all resources created by the SAM application!${NC}"
echo "This includes:"
echo "- Lambda functions"
echo "- API Gateway"
echo "- DynamoDB table and all data"
echo "- Lambda layers"
echo "- IAM roles and policies"
echo "- CloudFormation stack"
echo ""

read -p "Are you sure you want to delete the stack? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Starting cleanup process...${NC}"

# Delete SAM stack
echo "Deleting SAM stack: $STACK_NAME"
sam delete --stack-name "$STACK_NAME" --region "$REGION" --no-prompts

if [ $? -eq 0 ]; then
    echo -e "${GREEN}=== Cleanup Successful! ===${NC}"
    echo "All resources have been deleted."
else
    echo -e "${RED}=== Cleanup Failed! ===${NC}"
    echo "Please check the error messages above."
    echo "You may need to manually delete some resources."
    exit 1
fi

echo ""
echo -e "${GREEN}Cleanup completed successfully!${NC}"
