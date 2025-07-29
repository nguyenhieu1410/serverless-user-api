# 🚀 Quick Start - CloudShell Deployment

## 1️⃣ Mở AWS CloudShell
- Đăng nhập AWS Console
- Click biểu tượng CloudShell (terminal) ở góc phải trên

## 2️⃣ Clone dự án
```bash
git clone https://github.com/nguyenhieu1410/serverless-user-api.git
cd serverless-user-api
```

## 3️⃣ Setup môi trường
```bash
./cloudshell-setup.sh
```

## 4️⃣ Deploy dự án
```bash
./cloudshell-deploy.sh
```

## 5️⃣ Test API
```bash
./test-api.sh
```

## 🎯 Kết quả mong đợi
- API Gateway endpoint được tạo
- 2 Lambda functions hoạt động
- DynamoDB table được tạo
- API có thể tạo và lấy danh sách users

## 🧹 Cleanup
```bash
sam delete --stack-name serverless-user-api --region us-east-1
```

---
**Thời gian ước tính**: 10-15 phút
**Chi phí**: Free Tier eligible
