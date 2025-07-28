#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configure GitHub Authentication ===${NC}"
echo ""

echo -e "${YELLOW}To push to GitHub, you need a Personal Access Token.${NC}"
echo ""
echo -e "${BLUE}If you don't have one yet:${NC}"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Click 'Generate new token' → 'Generate new token (classic)'"
echo "3. Set Note: 'serverless-user-api'"
echo "4. Set Expiration: '90 days' or 'No expiration'"
echo "5. Check scope: ✅ 'repo' (Full control of private repositories)"
echo "6. Click 'Generate token'"
echo "7. Copy the token (starts with 'ghp_...')"
echo ""

read -p "Do you have a Personal Access Token? (y/n): " HAS_TOKEN

if [ "$HAS_TOKEN" != "y" ] && [ "$HAS_TOKEN" != "Y" ]; then
    echo ""
    echo -e "${YELLOW}Please create a Personal Access Token first and then run this script again.${NC}"
    echo "URL: https://github.com/settings/tokens"
    exit 1
fi

echo ""
echo -e "${YELLOW}Please enter your Personal Access Token:${NC}"
echo -e "${RED}(Token will not be displayed for security)${NC}"
read -s GITHUB_TOKEN

if [ -z "$GITHUB_TOKEN" ]; then
    echo ""
    echo -e "${RED}Error: Token cannot be empty${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Configuring Git remote with token...${NC}"

# Update remote URL with token
git remote set-url origin "https://${GITHUB_TOKEN}@github.com/nguyenhieu1410/serverless-user-api.git"

echo -e "${GREEN}✅ Remote URL updated successfully${NC}"
echo ""

# Verify remote
echo -e "${YELLOW}Current remote (token hidden):${NC}"
git remote get-url origin | sed 's/ghp_[^@]*@/[TOKEN]@/'

echo ""
echo -e "${YELLOW}Attempting to push to GitHub...${NC}"

# Push to GitHub
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 SUCCESS! Code pushed to GitHub successfully!${NC}"
    echo ""
    echo -e "${GREEN}Your repository is now available at:${NC}"
    echo "https://github.com/nguyenhieu1410/serverless-user-api"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Visit your repository on GitHub"
    echo "2. Add repository description and topics"
    echo "3. Consider adding a license"
    echo "4. Share your project! 🚀"
    
    # Clean up - remove token from URL for security
    echo ""
    echo -e "${YELLOW}Cleaning up token from Git config for security...${NC}"
    git remote set-url origin "https://github.com/nguyenhieu1410/serverless-user-api.git"
    git config credential.helper store
    echo -e "${GREEN}✅ Token cleaned up. Future pushes will prompt for credentials.${NC}"
    
else
    echo ""
    echo -e "${RED}❌ Push failed!${NC}"
    echo ""
    echo -e "${YELLOW}Common issues:${NC}"
    echo "1. Invalid or expired token"
    echo "2. Token doesn't have 'repo' scope"
    echo "3. Repository name mismatch"
    echo "4. Network connectivity issues"
    echo ""
    echo "Please check your token and try again."
    
    # Clean up failed token
    git remote set-url origin "https://github.com/nguyenhieu1410/serverless-user-api.git"
fi
