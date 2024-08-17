## JWT实现认证和授权的原理
- 用户调用登录接口，登录成功后获取到JWT的token；
- 之后用户每次调用接口都在http的header中添加一个叫Authorization的头，值为JWT的token；
- 后台程序通过对Authorization头中信息的解码及数字签名校验来获取其中的用户信息，从而实现认证和授权。 
## JWT的组成
JWT token的格式：header.payload.signature
- header中用于存放签名的生成算法；
{"alg": "HS512"}
- payload中用于存放用户名、token的生成时间和过期时间；
{"sub":"admin","created":1489079981393,"exp":1489684781}
- signature为以header和payload生成的签名，一旦header和payload被篡改，验证将失败。
String signature = HMACSHA512(base64UrlEncode(header) + "." +base64UrlEncode(payload),secret)