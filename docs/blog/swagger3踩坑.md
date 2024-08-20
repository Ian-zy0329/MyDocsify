## 起因
学习 elasticsearch 的时候，由于 es 用的版本是 7.17.3，对应 spring boot 版本必须 2.7 以上，所以将 spring boot 版本升到 2.7.18
但是启动的时候 swagger 报这个错误

    org.springframework.context.ApplicationContextException: Failed to start bean 'documentationPluginsBootstrapper'; nested exception is java.lang.NullPointerException

查了一下为什么报这个错
>Springfox 设置 Spring MVC 的路径匹配策略是 ant-path-matcher，而 Spring Boot 2.6.x版本的默认匹配策略是 path-pattern-matcher，这就造成了上面的报错

有两种解决方式，第二种只用在 swagger 配置类中加上这个方法
        
        @Bean
        public static BeanPostProcessor springfoxHandlerProviderBeanPostProcessor() {
        return new BeanPostProcessor() {
        
                @Override
                public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
                    if (bean instanceof WebMvcRequestHandlerProvider || bean instanceof WebFluxRequestHandlerProvider) {
                        customizeSpringfoxHandlerMappings(getHandlerMappings(bean));
                    }
                    return bean;
                }
        
                private <T extends RequestMappingInfoHandlerMapping> void customizeSpringfoxHandlerMappings(List<T> mappings) {
                    List<T> copy = mappings.stream()
                            .filter(mapping -> mapping.getPatternParser() == null)
                            .collect(Collectors.toList());
                    mappings.clear();
                    mappings.addAll(copy);
                }
        
                @SuppressWarnings("unchecked")
                private List<RequestMappingInfoHandlerMapping> getHandlerMappings(Object bean) {
                    try {
                        Field field = ReflectionUtils.findField(bean.getClass(), "handlerMappings");
                        field.setAccessible(true);
                        return (List<RequestMappingInfoHandlerMapping>) field.get(bean);
                    } catch (IllegalArgumentException | IllegalAccessException e) {
                        throw new IllegalStateException(e);
                    }
                }
            };
        }

## 解决
但是这个类 springfox.documentation.spring.web.plugins.WebFluxRequestHandlerProvider 在我现在使用的 2.7 版本没有，索性我将 swagger 升到 3.0
，然后顺利启动了，但是访问这个地址 http://localhost:8080/swagger-ui.html 报 404 了，查了一下 swagger 3.0 改默认地址了 
http://localhost:8080/swagger-ui/index.html 但是我访问这个也还是 404，后台也没有报错，实在找不到原因。
然后翻到一篇帖子说 swagger3.0 以上还需要导入 springfox-boot-starter，不然无法进入后台界面，试了下果然好了，还是得细心

    <!-- https://mvnrepository.com/artifact/io.springfox/springfox-boot-starter -->
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-boot-starter</artifactId>
        <version>3.0.0</version>
    </dependency>

## 经验与教训
升级版本时可以先去官网上看看，比如这次官网都写了要用到这个依赖甚至之前的这俩依赖都不需要

    <!--Swagger-UI API文档生产工具-->
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger2</artifactId>
        <version> 3.0.0</version>
    </dependency>
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger-ui</artifactId>
        <version> 3.0.0</version>
    </dependency>

![img_6.png](_media%2Fimg_6.png)
            
            