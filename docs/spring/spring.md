## 5. Spring MVC

核心组件：模型（Model）、视图（View）、控制器（Controller）

模型：负责应用程序的数据和业务逻辑

视图：负责展示数据

控制器：负责处理用户请求，通过注解 @Controller 或者 @RequestMapping 将 HTTP 请求映射到具体的处理方法，调用模型来处理业务逻辑，并将处理结果返回给视图
## 6. SpringBoot 常用注解

@SpringBootApplication、@Configuration（声明配置类）、@Autowired（自动装配 bean）、@Component、@Repository、@Service、@RestController = @ResponseBody + @Controller（返回 JSON 或 XML 形式写入 HTTP 响应 Response）、@RequestMapping、@RequestParam、@Value（读取简单的配置信息）
### 组件相关注解
- @Controller controller层组件，通常与'@RequestMapping'联用，当SpringMVC获取到请求时会转发到指定路径的方法
- @Service service层组件，service层专注系统业务逻辑处理
- @Repository dao层组件，dao层专注系统数据的处理
- @Component 用于修饰springboot组件，生成实例化对象
### 依赖注入注解
- @Autowired 根据对象类型自动注入依赖对象
- @Resource 根据对象名称自动注入依赖对象
- @Qualifier 当同一个对象有多个实例时，使用'@Autowired'注解无法注入，可以使用'@Qualifier'指定实例名称进行精确注入
### 实例与生命周期相关注解
- @Bean 用于修饰方法，创建一个Bean实例，交给Spring容器管理
- @Scope 用于声明一个Spring Bean实例的作用域，作用域有以下四种
  - singleton：单例模式，在Spring容器中该实例唯一，Spring默认的实例模式
  - prototype：原型模式，每次使用实例时都将重新创建
  - request：同一请求中使用相同实例，不同请求将重新创建
  - session：同一会话中使用相同实例，不同会话将重新创建
- @Primary 同一个对象有多个实例，优先使用该实例
- @PostConstruct 用于修饰方法，当对象实例被创建依赖注入完成后执行，可用于实例的初始化操作
- @PreDestroy 用于修饰方法，当对象实例被Spring容器移除后执行，可用对象实例持有资源的释放
### SpringMVC相关注解
- @RequestMapping 可用于将Web请求路径映射到处理类的方法上，当作用于类上时，可以统一类中所有方法的路由路径，当作用于方法上时，可单独指定方法的路由路径。
- @RequestBody 表示方法的请求参数为JSON格式，从Body中传入，将自动绑定到方法参数对象中。
- @ResponseBody 表示方法将返回JSON格式的数据，会自动将返回的对象转化为JSON数据。
- @RequestParam 用于接收请求参数，query param：GET请求拼接在地址里的参数、form data：POST表单提交的参数、multipart：文件上传请求的部分参数
- @PathVariable 用于接收请求路径中的参数，常用于REST风格的API。
- @RequestPart 用于接收文件上传中的文件参数，通常是multipart/form-data形式传入的参数。
- @RestController 用于表示controller层的组件，与@Controller注解的不同在于，相当于在每个请求处理方法上都添加了@ResponseBody注解，这些方法都将返回JSON格式数据。
- @GetMapping 用于表示GET请求方法，等价于@RequestMapping(method = RequestMethod.GET)。
- @PostMapping 用于表示POST请求方法，等价于@RequestMapping(method = RequestMethod.POST)。
### 配置相关注解
- @Configuration 用于声明一个Java形式的配置类，SpringBoot推荐使用Java配置，在该类中声明的Bean等配置将被SpringBoot的组件扫描功能扫描到。
- @EnableAutoConfiguration 启用SpringBoot的自动化配置，会根据你在pom.xml添加的依赖和application-dev.yml中的配置自动创建你需要的配置。
- @ComponentScan 启用SpringBoot的组件扫描功能，将自动装配和注入指定包下的Bean实例。
- @SpringBootApplication 用于表示SpringBoot应用中的启动类，相当于@Configuration、@EnableAutoConfiguration和@ComponentScan三个注解的结合体。
- @EnableCaching 当添加Spring Data Redis依赖之后，可用该注解开启Spring基于注解的缓存管理功能。
- @value 用于注入在配置文件中配置好的属性
- @ConfigurationProperties 用于批量注入外部配置，以对象的形式来导入指定前缀的配置
- @Conditional 用于表示当某个条件满足时，该组件或Bean将被Spring容器，创建下面是几个常用的条件注解：
  - @ConditionalOnBean：当某个Bean存在时，配置生效。
  - @ConditionalOnMissingBean：当某个Bean不存在时，配置生效。
  - @ConditionalOnClass：当某个类在Classpath存在时，配置生效。
  - @ConditionalOnMissingClass：当某个类在Classpath不存在时，配置生效
### 数据库事务相关注解
- @EnableTransactionManagement 启用Spring基于注解的事务管理功能，需要和@Configuration注解一起使用。
- @Transactional 表示方法和类需要开启事务，当作用与类上时，类中所有方法均会开启事务，当作用于方法上时，方法开启事务，方法上的注解无法被子类所继承。
### SpringSecurity相关注解
- @EnableWebSecurity 启用SpringSecurity的Web功能。
- @EnableGlobalMethodSecurity 启用SpringSecurity基于方法的安全功能，当我们使用@PreAuthorize修饰接口方法时，需要有对应权限的用户才能访问。
### 全局异常处理注解
- @ControllerAdvice 常与@ExceptionHandler注解一起使用，用于捕获全局异常，能作用于所有controller中。
- @ExceptionHandler 修饰方法时，表示该方法为处理全局异常的方法。
### AOP相关注解
- @Aspect 用于定义切面，切面是通知和切点的结合，定义了何时、何地应用通知功能。
- @Before 表示前置通知（Before），通知方法会在目标方法调用之前执行，通知描述了切面要完成的工作以及何时执行。
- @After 表示后置通知（After），通知方法会在目标方法返回或抛出异常后执行。
- @AfterReturning 表示返回通知（AfterReturning），通知方法会在目标方法返回后执行。
- @AfterThrowing 表示异常通知（AfterThrowing），通知方法会在目标方法抛出异常后执行。
- @Around 表示环绕通知（Around），通知方法会将目标方法封装起来，在目标方法调用之前和之后执行自定义的行为。
- @Pointcut 定义切点表达式，定义了通知功能被应用的范围。
- @Order 用于定义组件的执行顺序，在AOP中指的是切面的执行顺序，value属性越低优先级越高。
### 测试相关注解
- @SpringBootTest 用于指定测试类启用Spring Boot Test功能，默认会提供Mock环境。
- @Test 指定方法为测试方法。
## 7. SpringCloud 原理

1. 网关（SpringCloud Gateway）
2. 负载均衡（Ribbon）
3. 服务调用（OpenFeign）
4. 限流熔断（Sentinel）
5. 服务发现和配置管理（Nacos）
6. 消息队列（RocketMQ）
7. 分布式事物（Seata）