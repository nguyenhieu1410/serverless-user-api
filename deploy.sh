#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Serverless User API Deployment ===${NC}"
echo ""

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo -e "${RED}Error: SAM CLI is not installed${NC}"
    echo "Please install SAM CLI: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed${NC}"
    exit 1
fi

# Install dependencies for UUID layer
echo -e "${YELLOW}Installing dependencies for UUID layer...${NC}"
cd layers/uuid-layer/nodejs
npm install
cd ../../..

# Install dependencies for Lambda functions
echo -e "${YELLOW}Installing dependencies for Lambda functions...${NC}"
cd src/handlers
npm install
cd ../..

# Build the SAM application
echo -e "${YELLOW}Building SAM application...${NC}"
sam build

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

# Deploy the SAM application
echo -e "${YELLOW}Deploying SAM application...${NC}"
sam deploy --guided

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== Deployment Successful! ===${NC}"
    echo ""
    
    # Get stack outputs
    echo -e "${YELLOW}Stack Outputs:${NC}"
    aws cloudformation describe-stacks \
        --stack-name serverless-user-api \
        --region us-east-1 \
        --query 'Stacks[0].Outputs[*].[OutputKey,OutputValue]' \
        --output table
    
    echo ""
    echo -e "${GREEN}=== API Endpoints ===${NC}"
    API_URL=$(aws cloudformation describe-stacks \
        --stack-name serverless-user-api \
        --region us-east-1 \
        --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' \
        --output text)
    
    echo "Base URL: $API_URL"
    echo "POST /users - Create user: ${API_URL}users"
    echo "GET /users - Get all users: ${API_URL}users"
    
    echo ""
    echo -e "${YELLOW}Test your API with:${NC}"
    echo "curl -X POST ${API_URL}users -H 'Content-Type: application/json' -d '{\"name\":\"John Doe\"}'"
    echo "curl -X GET ${API_URL}users"
    
else
    echo ""
    echo -e "${RED}=== Deployment Failed! ===${NC}"
    echo "Please check the error messages above."
    exit 1
fi
