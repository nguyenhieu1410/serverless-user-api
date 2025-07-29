#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== CloudShell Setup for Serverless User API ===${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update system packages
echo -e "${YELLOW}Updating system packages...${NC}"
sudo yum update -y

# Install Node.js 18 if not already installed
if ! command_exists node || [[ $(node -v) != v18* ]]; then
    echo -e "${YELLOW}Installing Node.js 18...${NC}"
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
else
    echo -e "${GREEN}Node.js 18 is already installed${NC}"
fi

# Install SAM CLI if not already installed
if ! command_exists sam; then
    echo -e "${YELLOW}Installing AWS SAM CLI...${NC}"
    wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
    unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
    sudo ./sam-installation/install
    rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
else
    echo -e "${GREEN}AWS SAM CLI is already installed${NC}"
fi

# Verify installations
echo -e "${BLUE}=== Verifying installations ===${NC}"
echo "Node.js version: $(node -v)"
echo "NPM version: $(npm -v)"
echo "AWS CLI version: $(aws --version)"
echo "SAM CLI version: $(sam --version)"
echo "Git version: $(git --version)"

# Install project dependencies
echo -e "${YELLOW}Installing project dependencies...${NC}"

# Install UUID layer dependencies
echo -e "${YELLOW}Installing UUID layer dependencies...${NC}"
cd layers/uuid-layer/nodejs
npm install
cd ../../..

# Install Lambda function dependencies
echo -e "${YELLOW}Installing Lambda function dependencies...${NC}"
cd src/handlers
npm install
cd ../..

echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Run: ${YELLOW}sam build${NC}"
echo "2. Run: ${YELLOW}sam deploy --guided${NC}"
echo "3. Test your API with: ${YELLOW}./test-api.sh${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
