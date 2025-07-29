#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Running Newman Tests ===${NC}"
echo ""

# Check if Newman is installed
if ! command -v newman &> /dev/null; then
    echo -e "${YELLOW}Newman not found. Installing Newman...${NC}"
    npm install -g newman
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install Newman. Please install manually:${NC}"
        echo "npm install -g newman"
        exit 1
    fi
fi

# Check if API is deployed
API_URL=$(aws cloudformation describe-stacks \
    --stack-name serverless-user-api \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' \
    --output text 2>/dev/null)

if [ -z "$API_URL" ]; then
    echo -e "${RED}❌ Error: API not deployed. Please deploy first:${NC}"
    echo "./cloudshell-deploy.sh"
    exit 1
fi

echo -e "${BLUE}API URL: $API_URL${NC}"
echo ""

# Generate configured environment file
echo -e "${YELLOW}Generating environment file...${NC}"
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

# Run Newman tests
echo -e "${YELLOW}Running Newman tests...${NC}"
echo ""

newman run postman-collection-updated.json \
    -e postman-environment-configured.json \
    --reporters cli,html,json \
    --reporter-html-export newman-report.html \
    --reporter-json-export newman-report.json \
    --timeout-request 30000 \
    --delay-request 1000 \
    --verbose

NEWMAN_EXIT_CODE=$?

echo ""
if [ $NEWMAN_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed. Check the report for details.${NC}"
fi

echo ""
echo -e "${BLUE}=== Test Reports Generated ===${NC}"
echo "📄 HTML Report: newman-report.html"
echo "📄 JSON Report: newman-report.json"
echo ""

if command -v python3 &> /dev/null; then
    echo -e "${YELLOW}To view HTML report, run:${NC}"
    echo "python3 -m http.server 8000"
    echo "Then open: http://localhost:8000/newman-report.html"
elif command -v python &> /dev/null; then
    echo -e "${YELLOW}To view HTML report, run:${NC}"
    echo "python -m SimpleHTTPServer 8000"
    echo "Then open: http://localhost:8000/newman-report.html"
fi

echo ""
echo -e "${BLUE}=== Test Summary ===${NC}"

# Parse JSON report for summary
if [ -f "newman-report.json" ] && command -v jq &> /dev/null; then
    TOTAL_TESTS=$(jq '.run.stats.tests.total' newman-report.json)
    PASSED_TESTS=$(jq '.run.stats.tests.passed' newman-report.json)
    FAILED_TESTS=$(jq '.run.stats.tests.failed' newman-report.json)
    
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    
    if [ "$FAILED_TESTS" -gt 0 ]; then
        echo ""
        echo -e "${RED}Failed Tests:${NC}"
        jq -r '.run.executions[] | select(.assertions[] | select(.error != null)) | .item.name' newman-report.json | sort | uniq
    fi
fi

echo ""
echo -e "${GREEN}=== Newman Testing Complete ===${NC}"

exit $NEWMAN_EXIT_CODE
