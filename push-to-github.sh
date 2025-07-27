#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Push Serverless User API to GitHub ===${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "template.yaml" ]; then
    echo -e "${RED}Error: Not in the serverless-user-api directory${NC}"
    echo "Please run this script from the serverless-user-api directory"
    exit 1
fi

# Check Git status
echo -e "${YELLOW}Checking Git status...${NC}"
git status

echo ""
echo -e "${YELLOW}Please provide your GitHub information:${NC}"
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}Error: GitHub username is required${NC}"
    exit 1
fi

GITHUB_URL="https://github.com/${GITHUB_USERNAME}/serverless-user-api.git"

echo ""
echo -e "${YELLOW}GitHub repository URL: ${GITHUB_URL}${NC}"
echo ""

# Add remote origin
echo -e "${YELLOW}Adding GitHub remote...${NC}"
git remote add origin "$GITHUB_URL" 2>/dev/null || {
    echo -e "${YELLOW}Remote 'origin' already exists. Updating URL...${NC}"
    git remote set-url origin "$GITHUB_URL"
}

# Show remotes
echo -e "${YELLOW}Current remotes:${NC}"
git remote -v

echo ""
echo -e "${YELLOW}Pushing to GitHub...${NC}"
echo -e "${RED}Note: You will be prompted for GitHub credentials:${NC}"
echo "- Username: Your GitHub username"
echo "- Password: Your Personal Access Token (NOT your GitHub password)"
echo ""
echo "If you don't have a Personal Access Token:"
echo "1. Go to GitHub Settings → Developer settings → Personal access tokens"
echo "2. Generate new token with 'repo' scope"
echo "3. Use that token as password"
echo ""

read -p "Press Enter to continue with push..."

# Push to GitHub
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== Successfully pushed to GitHub! ===${NC}"
    echo ""
    echo -e "${GREEN}Your repository is now available at:${NC}"
    echo "https://github.com/${GITHUB_USERNAME}/serverless-user-api"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Visit your repository on GitHub"
    echo "2. Add topics/tags: aws, serverless, sam, lambda, dynamodb, api-gateway"
    echo "3. Consider adding a license"
    echo "4. Star your own repository! ⭐"
else
    echo ""
    echo -e "${RED}=== Push failed! ===${NC}"
    echo "Common issues:"
    echo "1. Wrong username or token"
    echo "2. Repository doesn't exist on GitHub"
    echo "3. No internet connection"
    echo ""
    echo "Please check the error message above and try again."
fi
