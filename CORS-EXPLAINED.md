# 🌐 CORS và OPTIONS Method - Giải thích chi tiết

## 🤔 **CORS là gì?**

**CORS (Cross-Origin Resource Sharing)** là một cơ chế bảo mật của browser để kiểm soát việc truy cập resources từ các domain khác nhau.

### 🔒 **Same-Origin Policy**
Browser mặc định chặn requests từ domain A đến domain B (khác origin) để bảo mật:
- `https://myapp.com` → `https://api.amazonaws.com` ❌ (Blocked)
- `https://myapp.com` → `https://myapp.com/api` ✅ (Same origin)

## 🚀 **OPTIONS Method**

OPTIONS là HTTP method được dùng để:

### 1. **CORS Preflight Requests**
Browser tự động gửi OPTIONS request trước khi gửi "complex" requests:

```
Complex requests bao gồm:
- Methods: POST, PUT, DELETE, PATCH
- Custom headers: Authorization, X-Custom-Header
- Content-Type: application/json
```

### 2. **API Discovery**
Client có thể dùng OPTIONS để tìm hiểu server hỗ trợ gì:
```bash
curl -X OPTIONS https://api.example.com/users
```

## 🔄 **CORS Flow**

### Simple Request (GET, HEAD, POST với form data):
```
Browser → Server: GET /users
Server → Browser: Response + CORS headers
```

### Complex Request (POST với JSON):
```
1. Browser → Server: OPTIONS /users (Preflight)
2. Server → Browser: CORS headers (Allow/Deny)
3. Browser → Server: POST /users (Actual request)
4. Server → Browser: Response + CORS headers
```

## 🛠️ **Trong AWS API Gateway**

### Template Configuration:
```yaml
UserApi:
  Type: AWS::Serverless::Api
  Properties:
    Cors:
      AllowMethods: "'GET,POST,OPTIONS'"
      AllowHeaders: "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
      AllowOrigin: "'*'"
```

### Kết quả:
- API Gateway tự động xử lý OPTIONS requests
- Trả về appropriate CORS headers
- Không cần Lambda function cho OPTIONS

## 📋 **CORS Headers**

### Request Headers (Browser gửi):
```
Origin: https://myapp.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type
```

### Response Headers (Server trả về):
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET,POST,OPTIONS
Access-Control-Allow-Headers: Content-Type,Authorization
Access-Control-Max-Age: 86400
```

## 🧪 **Testing CORS**

### 1. Command Line:
```bash
# Test OPTIONS request
curl -X OPTIONS https://api.example.com/users \
  -H "Origin: https://myapp.com" \
  -H "Access-Control-Request-Method: POST" \
  -v

# Test actual request
curl -X POST https://api.example.com/users \
  -H "Origin: https://myapp.com" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test"}' \
  -v
```

### 2. Browser (F12 Network tab):
```javascript
fetch('https://api.example.com/users', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ name: 'Test' })
});
```

### 3. HTML Demo:
Mở file `cors-demo.html` trong browser để test interactive.

## ⚠️ **Common Issues**

### 1. **CORS Error trong Browser:**
```
Access to fetch at 'https://api.example.com' from origin 'https://myapp.com' 
has been blocked by CORS policy
```

**Giải pháp:**
- Kiểm tra `Access-Control-Allow-Origin` header
- Đảm bảo OPTIONS method được enable
- Kiểm tra `Access-Control-Allow-Methods`

### 2. **Preflight Request Failed:**
```
Response to preflight request doesn't pass access control check
```

**Giải pháp:**
- Server phải respond 200 OK cho OPTIONS
- Phải có đúng CORS headers trong OPTIONS response

### 3. **Missing Headers:**
```
Request header field content-type is not allowed by Access-Control-Allow-Headers
```

**Giải pháp:**
- Thêm header vào `Access-Control-Allow-Headers`

## 🎯 **Best Practices**

### 1. **Security:**
```yaml
# ❌ Không nên dùng wildcard trong production
AllowOrigin: "'*'"

# ✅ Nên specify exact domains
AllowOrigin: "'https://myapp.com,https://admin.myapp.com'"
```

### 2. **Performance:**
```yaml
# Cache preflight response
Access-Control-Max-Age: 86400  # 24 hours
```

### 3. **Headers:**
```yaml
# Chỉ allow headers thực sự cần thiết
AllowHeaders: "'Content-Type,Authorization'"
```

## 🔍 **Debug Tools**

### 1. **Browser DevTools:**
- Network tab: Xem preflight requests
- Console: Xem CORS errors

### 2. **curl với verbose:**
```bash
curl -X OPTIONS https://api.example.com/users -v
```

### 3. **Postman:**
- Disable "Send anonymous usage data" để test CORS properly

## 📚 **Resources**

- [MDN CORS Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [AWS API Gateway CORS](https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html)
- [CORS Specification](https://fetch.spec.whatwg.org/#http-cors-protocol)

## 🎮 **Hands-on Testing**

1. Deploy API với `./cloudshell-deploy.sh`
2. Chạy `./test-cors.sh` để test CORS headers
3. Mở `cors-demo.html` trong browser để test interactive
4. Mở F12 Network tab để xem preflight requests
