# 🚀 CloudShell Deployment Guide

Hướng dẫn triển khai Serverless User API bằng AWS CloudShell.

## 📋 Yêu cầu

- AWS Account với quyền truy cập CloudShell
- Quyền tạo CloudFormation stack, Lambda functions, API Gateway, DynamoDB

## 🚀 Hướng dẫn triển khai

### Bước 1: Mở AWS CloudShell

1. Đăng nhập vào AWS Console
2. Tìm và mở **CloudShell** (biểu tượng terminal ở góc phải trên)
3. Chờ CloudShell khởi động

### Bước 2: Clone hoặc upload dự án

#### Option A: Clone từ GitHub (nếu đã push lên GitHub)
```bash
git clone <your-github-repo-url>
cd serverless-user-api
```

#### Option B: Upload file zip
1. Nén toàn bộ dự án thành file zip
2. Upload lên CloudShell bằng cách click **Actions** > **Upload file**
3. Giải nén:
```bash
unzip serverless-user-api.zip
cd serverless-user-api
```

#### Option C: Tạo từ đầu (copy-paste code)
```bash
mkdir serverless-user-api
cd serverless-user-api
# Sau đó copy-paste từng file từ local
```

### Bước 3: Setup môi trường

```bash
# Chạy script setup tự động
./cloudshell-setup.sh
```

Script này sẽ:
- Cài đặt Node.js 18
- Cài đặt AWS SAM CLI
- Cài đặt dependencies cho dự án
- Verify các installations

### Bước 4: Deploy dự án

```bash
# Chạy script deploy tự động
./cloudshell-deploy.sh
```

Hoặc deploy thủ công:

```bash
# Build dự án
sam build

# Deploy (lần đầu)
sam deploy --guided

# Deploy các lần sau
sam deploy
```

### Bước 5: Test API

```bash
# Chạy script test tự động
./test-api.sh
```

Hoặc test thủ công:

```bash
# Lấy API URL
API_URL=$(aws cloudformation describe-stacks \
    --stack-name serverless-user-api \
    --region us-east-1 \
    --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' \
    --output text)

# Test tạo user
curl -X POST ${API_URL}users \
    -H 'Content-Type: application/json' \
    -d '{"name":"John Doe"}'

# Test lấy danh sách users
curl -X GET ${API_URL}users
```

## 🔧 Troubleshooting

### Lỗi permissions
```bash
# Kiểm tra AWS identity
aws sts get-caller-identity

# Kiểm tra region
aws configure get region
```

### Lỗi SAM CLI
```bash
# Cài đặt lại SAM CLI
wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
sudo ./sam-installation/install --update
```

### Lỗi Node.js
```bash
# Kiểm tra version
node -v
npm -v

# Cài đặt lại dependencies
cd layers/uuid-layer/nodejs && npm install
cd ../../../src/handlers && npm install
```

### Lỗi deployment
```bash
# Xem logs chi tiết
sam logs -n CreateUserFunction --stack-name serverless-user-api --tail

# Kiểm tra CloudFormation events
aws cloudformation describe-stack-events \
    --stack-name serverless-user-api \
    --region us-east-1
```

## 🧹 Cleanup

Để xóa tất cả resources:

```bash
# Xóa CloudFormation stack
aws cloudformation delete-stack \
    --stack-name serverless-user-api \
    --region us-east-1

# Hoặc dùng SAM
sam delete --stack-name serverless-user-api --region us-east-1
```

## 📚 Useful Commands

```bash
# Xem stack status
aws cloudformation describe-stacks \
    --stack-name serverless-user-api \
    --region us-east-1

# Xem DynamoDB table
aws dynamodb scan \
    --table-name serverless-user-api-users-dev \
    --region us-east-1

# Xem Lambda logs
sam logs -n CreateUserFunction --stack-name serverless-user-api --tail
sam logs -n GetUsersFunction --stack-name serverless-user-api --tail

# Build và test local
sam build
sam local start-api
```

## 🎯 Tips

1. **CloudShell timeout**: CloudShell session timeout sau 20 phút không hoạt động. Hãy save công việc thường xuyên.

2. **Storage**: CloudShell có 1GB persistent storage trong `$HOME`. Files sẽ được giữ lại giữa các sessions.

3. **Region**: Đảm bảo deploy trong region phù hợp (mặc định us-east-1).

4. **Monitoring**: Sử dụng CloudWatch để monitor Lambda functions và API Gateway.

5. **Cost**: Dự án này sử dụng AWS Free Tier eligible services, nhưng hãy cleanup sau khi test xong.

## 🔗 Resources

- [AWS CloudShell User Guide](https://docs.aws.amazon.com/cloudshell/latest/userguide/)
- [AWS SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
