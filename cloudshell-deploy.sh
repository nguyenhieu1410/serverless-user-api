#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== CloudShell Deployment for Serverless User API ===${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "template.yaml" ]; then
    echo -e "${RED}Error: template.yaml not found. Please run this script from the project root directory.${NC}"
    exit 1
fi

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo -e "${RED}Error: SAM CLI is not installed. Please run ./cloudshell-setup.sh first.${NC}"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not configured or credentials are invalid.${NC}"
    exit 1
fi

echo -e "${BLUE}Current AWS Identity:${NC}"
aws sts get-caller-identity --output table

# Install dependencies if node_modules don't exist
if [ ! -d "layers/uuid-layer/nodejs/node_modules" ]; then
    echo -e "${YELLOW}Installing UUID layer dependencies...${NC}"
    cd layers/uuid-layer/nodejs
    npm install
    cd ../../..
fi

if [ ! -d "src/handlers/node_modules" ]; then
    echo -e "${YELLOW}Installing Lambda function dependencies...${NC}"
    cd src/handlers
    npm install
    cd ../..
fi

# Build the SAM application
echo -e "${YELLOW}Building SAM application...${NC}"
sam build

if [ $? -ne 0 ]; then
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi

# Deploy the SAM application
echo -e "${YELLOW}Deploying SAM application...${NC}"

# Check if this is first deployment
if aws cloudformation describe-stacks --stack-name serverless-user-api --region us-east-1 &> /dev/null; then
    echo -e "${BLUE}Stack exists, updating...${NC}"
    sam deploy
else
    echo -e "${BLUE}First deployment, running guided deployment...${NC}"
    sam deploy --guided
fi

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
    
    if [ ! -z "$API_URL" ]; then
        echo "Base URL: $API_URL"
        echo "POST /users - Create user: ${API_URL}users"
        echo "GET /users - Get all users: ${API_URL}users"
        
        echo ""
        echo -e "${YELLOW}Test your API with:${NC}"
        echo "curl -X POST ${API_URL}users -H 'Content-Type: application/json' -d '{\"name\":\"John Doe\"}'"
        echo "curl -X GET ${API_URL}users"
        
        echo ""
        echo -e "${BLUE}Or run the automated test script:${NC}"
        echo "./test-api.sh"
    fi
    
else
    echo ""
    echo -e "${RED}=== Deployment Failed! ===${NC}"
    echo "Please check the error messages above."
    exit 1
fi
