#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Testing CORS and OPTIONS Method ===${NC}"
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

# Test 1: OPTIONS request (CORS preflight)
echo -e "${GREEN}Test 1: OPTIONS request (CORS preflight)${NC}"
echo -e "${BLUE}Command: curl -X OPTIONS ${API_URL}users -H 'Origin: https://example.com' -v${NC}"
echo ""

curl -X OPTIONS "${API_URL}users" \
    -H "Origin: https://example.com" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type" \
    -v

echo ""
echo ""

# Test 2: POST request with CORS headers
echo -e "${GREEN}Test 2: POST request with CORS headers${NC}"
echo -e "${BLUE}Command: curl -X POST ${API_URL}users with CORS headers${NC}"
echo ""

curl -X POST "${API_URL}users" \
    -H "Content-Type: application/json" \
    -H "Origin: https://example.com" \
    -d '{"name":"CORS Test User"}' \
    -v

echo ""
echo ""

# Test 3: GET request with CORS headers
echo -e "${GREEN}Test 3: GET request with CORS headers${NC}"
echo -e "${BLUE}Command: curl -X GET ${API_URL}users with CORS headers${NC}"
echo ""

curl -X GET "${API_URL}users" \
    -H "Origin: https://example.com" \
    -v

echo ""
echo ""

echo -e "${YELLOW}=== CORS Headers to look for: ===${NC}"
echo "- Access-Control-Allow-Origin: *"
echo "- Access-Control-Allow-Methods: GET,POST,OPTIONS"
echo "- Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
echo ""

echo -e "${BLUE}=== What happens in browser: ===${NC}"
echo "1. Browser sends OPTIONS request (preflight) before POST/PUT/DELETE"
echo "2. Server responds with allowed origins, methods, headers"
echo "3. If allowed, browser sends the actual request"
echo "4. Server includes CORS headers in response"
