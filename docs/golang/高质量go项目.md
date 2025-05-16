以下是一些 **GitHub 上高质量的 Go 语言 RESTful API 项目**，涵盖不同技术栈和复杂度，适合学习和参考。这些项目大多结构清晰、文档完善，且结合了实际场景的工程实践：

---

### 一、**入门级项目（适合快速上手）**
#### 1. [**Gin RESTful API Starter**](https://github.com/gothinkster/golang-gin-realworld-example-app)
- **技术栈**：Gin + GORM + JWT + Swagger
- **亮点**：
    - 实现了一个类似 [RealWorld](https://realworld.io/) 的博客平台 API。
    - 包含用户注册/登录、文章发布、评论等功能。
    - 集成 Swagger 自动生成 API 文档。
- **学习点**：
    - Gin 路由和中间件的使用。
    - GORM 操作 MySQL/PostgreSQL。
    - JWT 鉴权实现。

#### 2. [**Echo REST API Example**](https://github.com/victorsteven/echo-rest-api)
- **技术栈**：Echo + GORM + JWT + Docker
- **亮点**：
    - 用户管理 API（CRUD + 分页查询）。
    - 使用 Docker Compose 一键部署。
    - 单元测试和集成测试示例。
- **学习点**：
    - Echo 框架的基础用法。
    - 使用 `go test` 编写测试用例。
    - 环境变量配置（通过 `.env` 文件）。

---

### 二、**进阶级项目（含微服务/中间件集成）**
#### 3. [**Go Microservices Boilerplate**](https://github.com/Massad/gin-boilerplate)
- **技术栈**：Gin + GORM + Redis + gRPC
- **亮点**：
    - 多模块微服务架构（用户服务、商品服务）。
    - 集成 Redis 缓存和分布式锁。
    - 使用 gRPC 实现服务间通信。
- **学习点**：
    - 微服务拆分与通信。
    - 中间件设计（日志、鉴权、限流）。
    - 容器化部署（Docker + Kubernetes）。

#### 4. [**Go REST API with Clean Architecture**](https://github.com/bxcodec/go-clean-arch)
- **技术栈**：Echo + GORM + Clean Architecture
- **亮点**：
    - 基于 Clean Architecture 设计（分层明确：Repository/UseCase/Handler）。
    - 实现文章管理 API，支持 MySQL 和 MongoDB。
    - 依赖注入（DI）实践。
- **学习点**：
    - 如何组织大型项目代码结构。
    - 依赖解耦与接口设计。
    - 多数据库适配。

---

### 三、**企业级项目（含完整 DevOps 流程）**
#### 5. [**Go Kit RESTful Microservice**](https://github.com/shijuvar/go-kit-examples)
- **技术栈**：Go Kit + Consul + Prometheus
- **亮点**：
    - 使用 Go Kit 构建微服务（日志、监控、服务发现）。
    - 集成 Consul 实现服务注册与发现。
    - Prometheus 监控指标暴露。
- **学习点**：
    - Go Kit 的中间件和 Endpoint 设计。
    - 服务治理（熔断、限流）。
    - 云原生工具链集成。

#### 6. [**E-commerce API with DDD**](https://github.com/ThreeDotsLabs/wild-workouts-go-ddd-example)
- **技术栈**：Gin + Firebase + DDD（领域驱动设计）
- **亮点**：
    - 电商系统 API（订单、支付、库存管理）。
    - 使用 DDD 思想设计领域模型。
    - 集成 Firebase 实现实时通知。
- **学习点**：
    - DDD 在 Go 中的实践。
    - 事件驱动架构（Event Sourcing）。
    - CQRS 模式实现。

---

### 四、**工具链集成项目**
#### 7. [**Go REST API with Kubernetes**](https://github.com/kubernetes-sigs/kubebuilder)
- **技术栈**：Kubebuilder + Kubernetes
- **亮点**：
    - 使用 Kubebuilder 快速开发 Kubernetes Operator。
    - 自定义 CRD（Custom Resource Definition）管理 API。
- **学习点**：
    - 如何为 Kubernetes 开发扩展功能。
    - 控制器的 Reconcile 循环设计。

#### 8. [**Golang REST API with Auth0**](https://github.com/auth0-samples/auth0-golang-api-samples)
- **技术栈**：Gin + Auth0（第三方认证）
- **亮点**：
    - 集成 Auth0 实现 OAuth2 和 OpenID Connect。
    - 角色权限管理（RBAC）。
- **学习点**：
    - 第三方身份认证集成。
    - 权限控制的最佳实践。

---

### 五、**如何高效学习这些项目？**
1. **运行项目**：
   ```bash
   # 克隆项目并启动
   git clone https://github.com/gothinkster/golang-gin-realworld-example-app
   cd golang-gin-realworld-example-app
   docker-compose up
   ```
2. **阅读代码**：
    - 从 `main.go` 入口文件开始，理清路由和模块依赖。
    - 关注项目结构（如 `internal/`, `pkg/`, `cmd/` 目录的划分）。
3. **修改调试**：
    - 尝试添加新功能（如增加一个「商品收藏」接口）。
    - 替换技术组件（如将 MySQL 换成 PostgreSQL）。
4. **参与贡献**：
    - 提交 Issue 或 PR 修复 Bug。
    - 优化文档或补充测试用例。

---

### 六、**其他推荐资源**
- **Go 语言官方示例**：  
  [GitHub - golang/examples](https://github.com/golang/examples)
- **Awesome Go 合集**：  
  [GitHub - awesome-go](https://github.com/avelino/awesome-go)

---

这些项目覆盖了从基础到进阶的 RESTful API 开发场景，结合你的 Java 经验，可以重点对比 Go 与 Spring Boot 的差异（如依赖注入、并发模型）。通过模仿和改造这些项目，能快速积累 Go 的实战经验并丰富简历。