#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Testing Serverless User API ===${NC}"
echo ""

# Get API URL from CloudFormation stack
API_URL=$(aws cloudformation describe-stacks \
    --stack-name serverless-user-api \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' \
    --output text 2>/dev/null)

if [ -z "$API_URL" ]; then
    echo -e "${RED}Error: Could not get API URL from CloudFormation stack${NC}"
    echo "Make sure the stack 'serverless-user-api' is deployed successfully."
    exit 1
fi

echo -e "${YELLOW}API Base URL: $API_URL${NC}"
echo ""

# Test 1: Create a user
echo -e "${GREEN}Test 1: Creating a new user...${NC}"
CREATE_RESPONSE=$(curl -s -X POST "${API_URL}users" \
    -H "Content-Type: application/json" \
    -d '{"name":"John Doe"}')

echo "Response:"
echo "$CREATE_RESPONSE" | jq '.' 2>/dev/null || echo "$CREATE_RESPONSE"
echo ""

# Test 2: Create another user
echo -e "${GREEN}Test 2: Creating another user...${NC}"
CREATE_RESPONSE2=$(curl -s -X POST "${API_URL}users" \
    -H "Content-Type: application/json" \
    -d '{"name":"Jane Smith"}')

echo "Response:"
echo "$CREATE_RESPONSE2" | jq '.' 2>/dev/null || echo "$CREATE_RESPONSE2"
echo ""

# Test 3: Get all users
echo -e "${GREEN}Test 3: Getting all users...${NC}"
GET_RESPONSE=$(curl -s -X GET "${API_URL}users")

echo "Response:"
echo "$GET_RESPONSE" | jq '.' 2>/dev/null || echo "$GET_RESPONSE"
echo ""

# Test 4: Test error case (empty name)
echo -e "${GREEN}Test 4: Testing error case (empty name)...${NC}"
ERROR_RESPONSE=$(curl -s -X POST "${API_URL}users" \
    -H "Content-Type: application/json" \
    -d '{"name":""}')

echo "Response:"
echo "$ERROR_RESPONSE" | jq '.' 2>/dev/null || echo "$ERROR_RESPONSE"
echo ""

# Test 5: Test error case (missing name)
echo -e "${GREEN}Test 5: Testing error case (missing name)...${NC}"
ERROR_RESPONSE2=$(curl -s -X POST "${API_URL}users" \
    -H "Content-Type: application/json" \
    -d '{}')

echo "Response:"
echo "$ERROR_RESPONSE2" | jq '.' 2>/dev/null || echo "$ERROR_RESPONSE2"
echo ""

echo -e "${YELLOW}=== API Testing Complete ===${NC}"
echo ""
echo -e "${GREEN}Manual Testing Commands:${NC}"
echo ""
echo "Create User:"
echo "curl -X POST ${API_URL}users -H 'Content-Type: application/json' -d '{\"name\":\"Your Name\"}'"
echo ""
echo "Get All Users:"
echo "curl -X GET ${API_URL}users"
echo ""

# Check DynamoDB table
TABLE_NAME=$(aws cloudformation describe-stacks \
    --stack-name serverless-user-api \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`UsersTableName`].OutputValue' \
    --output text 2>/dev/null)

if [ ! -z "$TABLE_NAME" ]; then
    echo -e "${GREEN}DynamoDB Table Data:${NC}"
    aws dynamodb scan --table-name "$TABLE_NAME" --region us-east-1 --output table
fi
