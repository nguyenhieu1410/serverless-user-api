#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Getting API URL for Postman ===${NC}"
echo ""

# Get API URL from CloudFormation stack
API_URL=$(aws cloudformation describe-stacks \
    --stack-name serverless-user-api \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' \
    --output text 2>/dev/null)

if [ -z "$API_URL" ]; then
    echo -e "${RED}❌ Error: Could not get API URL from CloudFormation stack${NC}"
    echo ""
    echo -e "${YELLOW}Possible reasons:${NC}"
    echo "1. Stack 'serverless-user-api' is not deployed"
    echo "2. Stack deployment failed"
    echo "3. Wrong region (currently checking us-east-1)"
    echo ""
    echo -e "${BLUE}To deploy the stack:${NC}"
    echo "./cloudshell-deploy.sh"
    echo ""
    echo -e "${BLUE}To check stack status:${NC}"
    echo "aws cloudformation describe-stacks --stack-name serverless-user-api --region us-east-1"
    exit 1
fi

echo -e "${GREEN}✅ API URL found!${NC}"
echo ""
echo -e "${YELLOW}API Base URL:${NC}"
echo "$API_URL"
echo ""

echo -e "${YELLOW}API Endpoints:${NC}"
echo "POST $API_URL/users - Create user"
echo "GET  $API_URL/users - Get all users"
echo ""

echo -e "${BLUE}=== For Postman Setup ===${NC}"
echo ""
echo -e "${YELLOW}1. Import Collection:${NC}"
echo "   - File: postman-collection-updated.json"
echo ""
echo -e "${YELLOW}2. Import Environment:${NC}"
echo "   - File: postman-environment.json"
echo ""
echo -e "${YELLOW}3. Update Environment Variable:${NC}"
echo "   - Variable: baseUrl"
echo "   - Value: $API_URL"
echo ""

# Create a temporary environment file with the correct URL
echo -e "${YELLOW}4. Or use this pre-configured environment file:${NC}"

cat > postman-environment-configured.json << EOF
{
  "id": "serverless-user-api-env-configured",
  "name": "Serverless User API Environment (Configured)",
  "values": [
    {
      "key": "baseUrl",
      "value": "$API_URL",
      "description": "Base URL for the API (Auto-configured)",
      "enabled": true
    },
    {
      "key": "region",
      "value": "us-east-1",
      "description": "AWS Region",
      "enabled": true
    },
    {
      "key": "stage",
      "value": "dev",
      "description": "API Gateway Stage",
      "enabled": true
    }
  ],
  "_postman_variable_scope": "environment"
}
EOF

echo "   - File: postman-environment-configured.json (✅ Auto-generated with correct URL)"
echo ""

echo -e "${BLUE}=== Quick Test Commands ===${NC}"
echo ""
echo -e "${YELLOW}Test with curl:${NC}"
echo "# Create user:"
echo "curl -X POST $API_URL/users -H 'Content-Type: application/json' -d '{\"name\":\"Postman Test User\"}'"
echo ""
echo "# Get users:"
echo "curl -X GET $API_URL/users"
echo ""

echo -e "${YELLOW}Test CORS (OPTIONS):${NC}"
echo "curl -X OPTIONS $API_URL/users -H 'Origin: https://example.com' -v"
echo ""

echo -e "${GREEN}=== Ready for Postman Testing! ===${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Import postman-collection-updated.json into Postman"
echo "2. Import postman-environment-configured.json into Postman"
echo "3. Select the configured environment"
echo "4. Start testing!"
