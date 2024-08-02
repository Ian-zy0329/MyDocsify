##### 5. Spring MVC

核心组件：模型（Model）、视图（View）、控制器（Controller）

模型：负责应用程序的数据和业务逻辑

视图：负责展示数据

控制器：负责处理用户请求，通过注解 @Controller 或者 @RequestMapping 将 HTTP 请求映射到具体的处理方法，调用模型来处理业务逻辑，并将处理结果返回给视图
##### 6. SpringBoot 常用注解

@SpringBootApplication、@Configuration（声明配置类）、@Autowired（自动装配 bean）、@Component、@Repository、@Service、@RestController = @ResponseBody + @Controller（返回 JSON 或 XML 形式写入 HTTP 响应 Response）、@RequestMapping、@RequestParam、@Value（读取简单的配置信息）

##### 7. SpringCloud 原理

1. 网关（SpringCloud Gateway）
2. 负载均衡（Ribbon）
3. 服务调用（OpenFeign）
4. 限流熔断（Sentinel）
5. 服务发现和配置管理（Nacos）
6. 消息队列（RocketMQ）
7. 分布式事物（Seata）