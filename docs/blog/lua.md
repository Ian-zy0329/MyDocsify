# Lua + Redis
## 什么是 Lua
Lua 是轻量级的脚本语言，用 C 语言编写，简单高效易于集成，可用于游戏开发、web 应用、嵌入式系统、扩展和插件等
## Lua 简单语法
常用类型：nil（空）、boolean（布尔值）、number（数字）、string（字符串）、table（表）
### 声明类型
不用写类型
```lua
--- 全局变量
name = 'lua'
age = 25
flag = true
--- 局部变量
local phoneNum = '137xxxxxx'
```
### table 类型
table 可以作为数组也可以作为类似 map 使用

作为数组
```bash
Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
> arr_table = {'felord.cn','Felordcn',1}
> print(arr_table[1])
felord.cn
> print(arr_table[3])
1
> print(#arr_table)
3
```

作为字典
```bash
Lua 5.1.5  Copyright (C) 1994-2012 Lua.org, PUC-Rio
> arr_table = {name = 'felord.cn', age = 18}
> print(arr_table['name'])
felord.cn
> print(arr_table.name)
felord.cn
> print(arr_table[1])
nil
> print(arr_table['age'])
18
> print(#arr_table)
0
```
### 判断、循环
```lua
local a = 10
if a < 10  then
	print('a小于10')
elseif a < 20 then
	print('a小于20，大于等于10')
else
	print('a大于等于20')
end
```

```lua
local arr = {1,2,name='felord.cn'}

for i, v in ipairs(arr) do
    print('i = '..i)
    print('v = '.. v)
end

print('-------------------')

for i, v in pairs(arr) do
    print('p i = '..i)
    print('p v = '.. v)
end

i = 1
v = 1
i = 2
v = 2
-----------------------
p i = 1
p v = 1
p i = 2
p v = 2
p i = name
p v = felord.cn
```

## redis Lua 命令
### EVAL
redis 中使用 EVAL 命令执行指定 lua 脚本
```redis
EVAL luascript numkeys key [key ...] arg[arg ...]
```
- EVAL 命令的关键字。
- luascript Lua 脚本。
- numkeys 指定的Lua脚本需要处理键的数量，其实就是 key数组的长度。
- key 传递给Lua脚本零到多个键，空格隔开，在Lua 脚本中通过 KEYS[INDEX]来获取对应的值，其中1 <= INDEX <= numkeys。
- arg是传递给脚本的零到多个附加参数，空格隔开，在Lua脚本中通过ARGV[INDEX]来获取对应的值，其中1 <= INDEX <= numkeys。

通过return 返回结果，通过redis.call执行redis命令
```lua
eval "return redis.call('keys','*')" 0
--- 以上命令返回所有的key，类似于直接执行 keys *
```

### call 函数和 pcall 函数区别
它们唯一的区别就在于处理错误的方式，前者执行命令错误时会向调用者直接返回一个错误；而后者则会将错误包装为一个我们上面讲的table表格

### 值转换
由于在Redis中存在Redis和Lua两种不同的运行环境，在Redis和Lua互相传递数据时必然发生对应的转换操作，这种转换操作是我们在实践中不能忽略的。例如如果Lua脚本向Redis返回小数，那么会损失小数精度；如果转换为字符串则是安全的。
```bash
127.0.0.1:6379> EVAL "return 3.14" 0
(integer) 3
127.0.0.1:6379> EVAL "return tostring(3.14)" 0
"3.14"
```

### 原子执行
Lua脚本在Redis中是以原子方式执行的，在Redis服务器执行EVAL命令时，在命令执行完毕并向调用者返回结果之前，只会执行当前命令指定的Lua脚本包含的所有逻辑，其它客户端发送的命令将被阻塞，直到EVAL命令执行完毕为止。因此LUA脚本不宜编写一些过于复杂了逻辑，必须尽量保证Lua脚本的效率，否则会影响其它客户端。

### 脚本管理
#### SCRIPT LOAD
加载脚本到缓存以达到重复使用，避免多次加载浪费带宽，每一个脚本都会通过 SHA（Secure Hash Algorithm，加密算法） 校验返回唯一字符串标识。需要配合EVALSHA命令来执行缓存后的脚本。
```bash
127.0.0.1:6379> SCRIPT LOAD "return 'hello'"
"1b936e3fe509bcbc9cd0664897bbe8fd0cac101b"
127.0.0.1:6379> EVALSHA 1b936e3fe509bcbc9cd0664897bbe8fd0cac101b 0
"hello"
```
#### SCRIPT FLUSH
既然有缓存就有清除缓存，但是遗憾的是并没有根据SHA来删除脚本缓存，而是清除所有的脚本缓存，所以在生产中一般不会再生产过程中使用该命令。
#### SCRIPT EXISTS
以SHA标识为参数检查一个或者多个缓存是否存在。
#### SCRIPT KILL
终止正在执行的脚本。但是为了数据的完整性此命令并不能保证一定能终止成功。如果当一个脚本执行了一部分写的逻辑而需要被终止时，该命令是不凑效的。需要执行SHUTDOWN nosave在不对数据执行持久化的情况下终止服务器来完成终止脚本。

## 其它一些要点
- 务必对Lua脚本进行全面测试以保证其逻辑的健壮性，当Lua脚本遇到异常时，已经执行过的逻辑是不会回滚的。
- 尽量不使用Lua提供的具有随机性的函数
- 在Lua脚本中不要编写function函数,整个脚本作为一个函数的函数体
- 在脚本编写中声明的变量全部使用local关键字
- 在集群中使用Lua脚本要确保逻辑中所有的key分到相同机器，也就是同一个插槽(slot)中，可采用Redis Hash Tag技术
- 再次重申Lua脚本一定不要包含过于耗时、过于复杂的逻辑

## redis + lua 简单实现分布式锁
### 加锁
不在存在 lock，则设置 lock 为 123，并设置过期时间为 60，返回 1 表示加锁成功，反之返回 0 表示失败
```bash
127.0.0.1:6379> eval " if redis.call('get',KEYS[1]) then return 0;else redis.call('set',KEYS[1],ARGV[1]);redis.call('expire',KEYS[1],ARGV[2]);return 1;end" 1 lock 123 60
(integer) 1
127.0.0.1:6379> get lock
"123"
127.0.0.1:6379> eval " if redis.call('get',KEYS[1]) then return 0;else redis.call('set',KEYS[1],ARGV[1]);redis.call('expire',KEYS[1],ARGV[2]);return 1;end" 1 lock 123 60
(integer) 0
127.0.0.1:6379> eval " if redis.call('get',KEYS[1]) then return 0;else redis.call('set',KEYS[1],ARGV[1]);redis.call('expire',KEYS[1],ARGV[2]);return 1;end" 1 lock 123 60
(integer) 1
```
### 释放锁
不存在 lock，无需释放，存在 lock 并且与传入值相等则删除 lock 返回 1，不等返回 0 
```bash
127.0.0.1:6379> eval "local v = redis.call('get',KEYS[1]);if v then if v ~= ARGV[1] then return 0; end;redis.call('del',KEYS[1]);end;return 1;" 1 lock 123
(integer) 1
127.0.0.1:6379> get lock
(nil)
127.0.0.1:6379> eval "local v = redis.call('get',KEYS[1]);if v then if v ~= ARGV[1] then return 0; end;redis.call('del',KEYS[1]);end;return 1;" 1 lock 123
(integer) 1
```

## redis + lua 实现限流
### 限流算法
#### 1. 固定时间窗口算法（Fixed Window Algorithm）
原理：将时间划分为固定大小的窗口（如1秒钟），在每个时间窗口内，记录请求的数量。如果在一个窗口内请求数量超过了设定的阈值，后续的请求会被拒绝，直到进入下一个时间窗口。

优点：实现简单，易于理解和部署。

缺点：可能出现“突发”流量问题，即两个时间窗口的边界处可能允许连续的两组请求都达到阈值，从而在边界处导致瞬时超载。

适用场景：适合对短时间内瞬时请求量不敏感的系统，比如简单的API限流。
#### 2. 滑动时间窗口算法（Sliding Window Algorithm）
原理：滑动窗口算法通过在固定时间窗口内细分为多个小窗口（如1秒钟分为10个100毫秒的小窗口），实时滑动并记录小窗口内的请求数量。滑动窗口会不断更新以覆盖最新的时间段，从而更精确地控制请求速率。

优点：更加平滑地限制请求速率，减少了“突发”流量问题。

缺点：实现相对复杂，尤其是在精确统计和更新小窗口的情况下。

适用场景：适合需要更加精确限流的场景，比如高并发的订单系统。
#### 3. 令牌桶算法（Token Bucket Algorithm）
原理：系统以恒定速率向桶中添加令牌，每个请求需要消耗一个令牌。当令牌用完时，新的请求将被拒绝或延迟处理。桶的容量决定了短时间内可以处理的最大请求数。

优点：灵活，允许突发流量，并且可以通过调整令牌发放速率和桶容量来适应不同的流量需求。

缺点：在极端情况下，可能出现令牌积压，导致突发流量超过预期。

适用场景：适合对突发流量有一定容忍度的系统，如视频流媒体、文件上传等需要支持短期高峰流量的场景。
#### 4. 漏桶算法（Leaky Bucket Algorithm）
原理：漏桶算法类似于令牌桶，但它以固定速率处理请求（即漏水），请求进来时直接放入桶中，如果桶满了，后续请求会被拒绝或延迟处理。漏桶算法严格控制了请求的处理速率，不允许突发流量。

优点：严格控制请求速率，防止突发流量。

缺点：不允许突发流量，可能导致短期高并发请求被大量拒绝。

适用场景：适合对请求速率要求非常严格的系统，如银行交易系统、支付系统等。
#### 5. 计数器算法
原理：在固定时间窗口内（如1分钟），计数器记录请求的次数。如果请求数量超过阈值，则拒绝后续请求。计数器在每个时间窗口结束时重置。

优点：实现简单，适合基本的限流需求。

缺点：边界条件下存在“突发”问题，无法处理复杂的流量模式。

适用场景：适合简单的API限流场景。
#### 6. 自适应限流算法
原理：自适应限流算法基于系统当前负载和性能指标（如CPU使用率、响应时间）动态调整限流策略，确保系统在高负载下仍然能够提供稳定的服务。

优点：动态调整限流策略，适应系统实时负载变化。

缺点：实现复杂，需要持续监控和调整策略。

适用场景：适合高可用性要求的系统，如微服务架构中的服务限流。

### 总结与适用场景
1. 固定时间窗口：适合简单的API限流，不太关注突发流量。
2. 滑动时间窗口：适合对流量波动敏感的系统，需要更精确的限流控制。
3. 令牌桶：适合需要允许突发流量的场景，如流媒体、文件上传等。
4. 漏桶：适合严格限制请求速率的场景，如支付系统、银行交易系统。
5. 计数器：适合简单的限流需求，通常与其他算法结合使用。
6. 自适应限流：适合复杂系统中，需要根据实时负载动态调整限流策略的场景。

### 基于计数器算法实现限流
#### lua
```lua
local key = "rate.limit:" ..KEYS[1]
local limit = tonumber(ARGV[1])
local current = tonumber(redis.call('get',key) or "0")
if current + 1 > limit then
    return 0
else
    redis.call('INCRBY',key,"1")
    redis.call('expire',key,"60")
    return current + 1
end
```
#### 限流注解
```java
@Target({ElementType.TYPE,ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface RateLimit {

    String key() default "";

    int time();

    int count();
}
```
#### redis 配置
```java
@Component
public class RedisConfiguration {

    @Bean
    public DefaultRedisScript<Long> redisScript() {
        DefaultRedisScript<Long> script = new DefaultRedisScript<>();
        script.setScriptSource(new ResourceScriptSource(new ClassPathResource("META-INF/script/request_rate_limiter.lua")));
        script.setResultType(Long.class);
        return script;
    }

    @Bean
    public RedisTemplate<String, Serializable> limitRedisTemplate(LettuceConnectionFactory redisConnectionFactory) {
        RedisTemplate<String, Serializable> redisTemplate = new RedisTemplate<>();
        redisTemplate.setKeySerializer(new StringRedisSerializer());
        redisTemplate.setValueSerializer(new GenericJackson2JsonRedisSerializer());
        redisTemplate.setConnectionFactory(redisConnectionFactory);
        return redisTemplate;
    }
}
```
#### 拦截器
```java
@Aspect
@Configuration
public class LimitAspect {

    private static final Logger LOGGER = LoggerFactory.getLogger(LimitAspect.class);

    @Autowired
    private RedisTemplate<String, Serializable> limitRedisTemplate;

    @Autowired
    private DefaultRedisScript<Long> redisScript;

    @Around("execution(* top.ian.mymall.controller ..*(..) )")
    public Object interceptor(ProceedingJoinPoint joinPoint) throws Throwable {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Class<?> targetClass = method.getDeclaringClass();
        RateLimit rateLimit = method.getAnnotation(RateLimit.class);

        if (rateLimit != null) {
            HttpServletRequest request = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
            String ipAddr = getIpAddr(request);

            StringBuffer stringBuffer = new StringBuffer();
            stringBuffer.append(ipAddr).append("-")
                    .append(targetClass.getName()).append("-")
                    .append(method.getName()).append("-")
                    .append(rateLimit.key());

            List<String> keys = Collections.singletonList(stringBuffer.toString());
            Long number = limitRedisTemplate.execute(redisScript, keys, rateLimit.count(), rateLimit.time());

            if (number != null && number.intValue() != 0 && number.intValue() <= rateLimit.count()) {
                LOGGER.info("限流时间段内访问第：{} 次",number.toString());
                return joinPoint.proceed();
            }

        } else {
            return joinPoint.proceed();
        }

        throw new RuntimeException("已经到设置限流次数");
    }

    public static String getIpAddr(HttpServletRequest request) {
        String ipAddress = null;
        try {
            ipAddress = request.getHeader("x-forwarded-for");
            if (ipAddress == null || ipAddress.length() == 0 || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getHeader("Proxy-Client-IP");
            }
            if (ipAddress == null || ipAddress.length() == 0 || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getHeader("WL-Proxy-Client-IP");
            }
            if (ipAddress == null || ipAddress.length() == 0 || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getRemoteAddr();
            }
            // 对于通过多个代理的情况，第一个IP为客户端真实IP,多个IP按照','分割
            if (ipAddress != null && ipAddress.length() > 15) { // "***.***.***.***".length()
                // = 15
                if (ipAddress.indexOf(",") > 0) {
                    ipAddress = ipAddress.substring(0, ipAddress.indexOf(","));
                }
            }
        } catch (Exception e) {
            ipAddress = "";
        }
        return ipAddress;
    }
}
```
#### 控制层
```java
@RestController
public class LimiterController {

    @Autowired
    private RedisTemplate redisTemplate ;

    @RateLimit(key = "test",time = 10,count = 10)
    @GetMapping("/test")
    public String luaLimiter() {
        RedisAtomicInteger entityIdCounter = new RedisAtomicInteger("entityIdCounter", redisTemplate.getConnectionFactory());

        String date = DateFormatUtils.format(new Date(), "yyyy-MM-dd HH:mm:ss.SSS");
        return date + "累计访问次数：" + entityIdCounter;
    }
}
```
#### 验证
```
2024-09-04 21:57:55.579  INFO 18848 --- [nio-8080-exec-6] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：1 次
2024-09-04 21:57:55.605  INFO 18848 --- [nio-8080-exec-5] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：2 次
2024-09-04 21:57:55.615  INFO 18848 --- [nio-8080-exec-8] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：3 次
2024-09-04 21:57:55.625  INFO 18848 --- [nio-8080-exec-9] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：4 次
2024-09-04 21:57:55.633  INFO 18848 --- [nio-8080-exec-7] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：5 次
2024-09-04 21:57:55.642  INFO 18848 --- [io-8080-exec-10] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：6 次
2024-09-04 21:57:55.651  INFO 18848 --- [nio-8080-exec-1] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：7 次
2024-09-04 21:57:55.661  INFO 18848 --- [nio-8080-exec-2] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：8 次
2024-09-04 21:57:55.669  INFO 18848 --- [nio-8080-exec-3] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：9 次
2024-09-04 21:57:55.680  INFO 18848 --- [nio-8080-exec-4] top.ian.mymall.config.LimitAspect        : 限流时间段内访问第：10 次
2024-09-04 21:57:55.691 ERROR 18848 --- [nio-8080-exec-6] o.a.c.c.C.[.[.[/].[dispatcherServlet]    : Servlet.service() for servlet [dispatcherServlet] in context with path [] threw exception [Request processing failed; nested exception is java.lang.RuntimeException: 已经到设置限流次数] with root cause

java.lang.RuntimeException: 已经到设置限流次数
```
#### jmeter 测试验证
![img_17.png](_media/Fimg_17.png)

## redis + lua 实现商品库存扣减
要点：
* 同一个SKU，库存数量共享；
* 剩余库存必须要大于等于本次扣减数量，否则会出现超卖现象；
* 对同一个数量多用户并发扣减时，要注意并发安全，保证数据的一致性；
* 类似于秒杀这样高QPS的扣减场景，要保证性能与高可用；
* 对于购物车下单场景，多个商品库存批量扣减，要保证事务一致性；
* 如果发生交易退款，保证库存扣减可以返还：
  * 返还的数据总量不能大于扣减总量；
  * 返还要保证幂等性；
  * 允许多次返还。

