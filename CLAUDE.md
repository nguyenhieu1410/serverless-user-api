# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a serverless REST API built with AWS SAM (Serverless Application Model) for user management. The API provides endpoints to create and retrieve users, using AWS Lambda functions, API Gateway, and DynamoDB.

## Development Commands

### Build and Deploy
```bash
# Install dependencies (required before build/deploy)
cd layers/uuid-layer/nodejs && npm install && cd ../../..
cd src/handlers && npm install && cd ../..

# Build the SAM application
sam build

# Deploy with guided setup (first time)
sam deploy --guided

# Deploy with existing configuration
sam deploy

# Quick deploy script (handles dependencies + build + deploy)
./deploy.sh
```

### Testing
```bash
# Automated API testing
./test-api.sh

# Manual API testing
curl -X POST <API_URL>/users -H 'Content-Type: application/json' -d '{"name":"John Doe"}'
curl -X GET <API_URL>/users

# Get API URL from CloudFormation
aws cloudformation describe-stacks --stack-name serverless-user-api --region us-east-1 --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' --output text
```

### Cleanup
```bash
# Delete all AWS resources
./cleanup.sh
# or
sam delete --stack-name serverless-user-api --region us-east-1
```

## Architecture

### Core Components
- **API Gateway**: REST API with CORS enabled, routes to Lambda functions
- **Lambda Functions**: 
  - `createUser.js`: Creates new users with UUID generation
  - `getUsers.js`: Retrieves all users sorted by creation date
- **Lambda Layer**: Contains UUID library (v9.0.0) shared across functions
- **DynamoDB**: Users table with `id` (UUID) as primary key
- **CloudFormation**: Infrastructure as Code via SAM template

### Key Files
- `template.yaml`: SAM template defining all AWS resources
- `samconfig.toml`: SAM deployment configuration
- `src/handlers/`: Lambda function code
- `layers/uuid-layer/`: Shared UUID library layer

### Data Model
Users table schema:
- `id`: String (UUID, Primary Key)
- `name`: String (required, non-empty)
- `createdAt`: String (ISO 8601 timestamp)

### Environment Variables
- `USERS_TABLE`: DynamoDB table name (auto-injected by SAM)

## Development Notes

### Lambda Functions
- Both functions use AWS SDK v2 (`aws-sdk` package)
- UUID generation handled by layer dependency
- CORS headers included in all responses
- Error handling for validation and DynamoDB operations
- CloudWatch logging enabled

### Dependencies Management
- Handler dependencies: `src/handlers/package.json` (aws-sdk)
- Layer dependencies: `layers/uuid-layer/nodejs/package.json` (uuid)
- No root-level package.json - dependencies managed per component

### Regional Configuration
- Default region: `us-east-1`
- Stack name: `serverless-user-api`
- Stage: `dev` (configurable via parameter overrides)

### Testing Strategy
- `test-api.sh` provides comprehensive API testing
- Tests include success cases and error validation
- CloudFormation stack outputs used to get API endpoints
- DynamoDB table scanning for data verification