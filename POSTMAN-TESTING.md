# 📮 Postman Testing Guide

Hướng dẫn chi tiết để test Serverless User API bằng Postman.

## 🚀 **Setup Postman**

### Bước 1: Import Collection và Environment

1. **Mở Postman**
2. **Import Collection**:
   - Click **Import** button
   - Chọn file `postman-collection-updated.json`
   - Hoặc drag & drop file vào Postman

3. **Import Environment**:
   - Click **Import** button
   - Chọn file `postman-environment.json`
   - Hoặc drag & drop file vào Postman

### Bước 2: Cấu hình Environment

1. **Select Environment**: 
   - Click dropdown ở góc phải trên
   - Chọn "Serverless User API Environment"

2. **Update Base URL**:
   - Click **Environment** tab
   - Sửa `baseUrl` từ `YOUR_API_ID` thành API ID thực tế
   - Ví dụ: `https://abc123def4.execute-api.us-east-1.amazonaws.com/dev`

### Bước 3: Lấy API URL

Sau khi deploy API, lấy URL bằng cách:

```bash
# Trong CloudShell hoặc terminal
aws cloudformation describe-stacks \
  --stack-name serverless-user-api \
  --region us-east-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`UserApi`].OutputValue' \
  --output text
```

## 🧪 **Test Cases**

### 1. **Health Check**

#### OPTIONS - CORS Preflight
- **Method**: OPTIONS
- **URL**: `{{baseUrl}}/users`
- **Headers**:
  ```
  Origin: https://example.com
  Access-Control-Request-Method: POST
  Access-Control-Request-Headers: Content-Type
  ```
- **Expected**: 200 OK với CORS headers

### 2. **User Management**

#### Create User - Success
- **Method**: POST
- **URL**: `{{baseUrl}}/users`
- **Headers**: `Content-Type: application/json`
- **Body**:
  ```json
  {
    "name": "John Doe"
  }
  ```
- **Expected**: 200 OK với user object

#### Get All Users
- **Method**: GET
- **URL**: `{{baseUrl}}/users`
- **Expected**: 200 OK với array of users

### 3. **Error Cases**

#### Empty Name
- **Body**: `{"name": ""}`
- **Expected**: 400 Bad Request

#### Missing Name
- **Body**: `{}`
- **Expected**: 400 Bad Request

#### Only Spaces
- **Body**: `{"name": "   "}`
- **Expected**: 400 Bad Request

## 🔍 **Automated Tests**

Collection đã bao gồm automated tests:

### Response Structure Tests
```javascript
pm.test("Response has correct structure", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('statusCode');
    pm.expect(jsonData).to.have.property('body');
});
```

### UUID Validation
```javascript
pm.test("User ID is UUID format", function () {
    var jsonData = pm.response.json();
    var uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    pm.expect(jsonData.body.id).to.match(uuidRegex);
});
```

### CORS Headers Test
```javascript
pm.test("CORS headers are present", function () {
    pm.expect(pm.response.headers.get('Access-Control-Allow-Origin')).to.eql('*');
});
```

## 🏃‍♂️ **Running Tests**

### Individual Tests
1. Select request từ collection
2. Click **Send**
3. Xem response và test results

### Collection Runner
1. Click **Collections** tab
2. Click **...** next to collection name
3. Select **Run collection**
4. Configure settings:
   - **Environment**: Serverless User API Environment
   - **Iterations**: 1 (hoặc nhiều hơn cho stress test)
   - **Delay**: 0ms
5. Click **Run**

### Newman (Command Line)
```bash
# Install Newman
npm install -g newman

# Run collection
newman run postman-collection-updated.json \
  -e postman-environment.json \
  --reporters cli,html \
  --reporter-html-export results.html
```

## 📊 **Test Results Analysis**

### Success Indicators
- ✅ Status codes match expected (200, 400, etc.)
- ✅ Response structure is correct
- ✅ CORS headers present
- ✅ UUID format validation passes
- ✅ Response time < 5 seconds

### Common Issues

#### 1. **CORS Errors**
```
Access-Control-Allow-Origin header missing
```
**Solution**: Kiểm tra CORS configuration trong template.yaml

#### 2. **404 Not Found**
```
{"message": "Not Found"}
```
**Solution**: Kiểm tra API URL và endpoint path

#### 3. **500 Internal Server Error**
```
{"message": "Internal server error"}
```
**Solution**: Kiểm tra CloudWatch Logs cho Lambda functions

## 🔧 **Advanced Testing**

### Variables và Dynamic Data
```javascript
// Pre-request script
pm.environment.set("randomName", "User_" + Math.random().toString(36).substr(2, 9));
```

### Chaining Requests
```javascript
// Test script - save user ID for next request
var jsonData = pm.response.json();
pm.environment.set("userId", jsonData.body.id);
```

### Performance Testing
```javascript
pm.test("Response time is acceptable", function () {
    pm.expect(pm.response.responseTime).to.be.below(2000);
});
```

## 📈 **Monitoring và Reporting**

### Postman Monitor
1. Click **...** next to collection
2. Select **Monitor collection**
3. Configure schedule và notifications

### Custom Reports
```javascript
// Custom test for reporting
pm.test(`API Health Check - ${new Date().toISOString()}`, function () {
    pm.response.to.have.status(200);
});
```

## 🐛 **Troubleshooting**

### Debug Mode
1. Open **Postman Console** (View → Show Postman Console)
2. Add console.log trong scripts:
```javascript
console.log("Response:", pm.response.json());
```

### Network Issues
1. Check **Settings** → **Proxy**
2. Disable proxy nếu có
3. Check firewall settings

### SSL Issues
1. **Settings** → **General**
2. Turn off **SSL certificate verification** (chỉ cho testing)

## 📚 **Best Practices**

1. **Use Environment Variables**: Không hardcode URLs
2. **Add Tests**: Luôn có automated tests
3. **Organize Collections**: Group related requests
4. **Document Requests**: Add descriptions
5. **Version Control**: Save collections trong Git
6. **Monitor Performance**: Track response times
7. **Handle Errors**: Test error scenarios

## 🎯 **Quick Start Checklist**

- [ ] Import collection và environment
- [ ] Update baseUrl với API ID thực tế
- [ ] Select correct environment
- [ ] Run "OPTIONS - CORS Preflight" test
- [ ] Run "Create User - Success" test
- [ ] Run "Get All Users" test
- [ ] Run full collection với Collection Runner
- [ ] Check test results và response times

## 📞 **Support**

Nếu gặp vấn đề:
1. Check CloudWatch Logs
2. Verify API deployment status
3. Test với curl command trước
4. Check Postman Console logs
