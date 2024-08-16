## MyBatis 动态 sql 是做什么的？动态 sql 的执⾏原理？
- 动态 sql 可以让我们在 xml 文件中以标签的形式编写动态 sql，完成逻辑判断和动态拼接 sql 的功能。
- 通过 OGNL 表达式语言获取 sql 表达式的值，然后根据表达式的值动态拼接 sql ，以此来完成动态 sql 的功能。
- MyBatis 提供 9 种动态 sql 标签：<if>,<where>(trim,set),<choose>(when,otherwise),<foreach>,<bind>
## MyBatis 都有哪些 Executor 执⾏器？
MyBatis 有三种基本的 Executor 执⾏器：
- SimpleExecutor：每执行一次 update 或者 select 就开启一个 statement 对象，用完就立刻关闭
- ReuseExecutor：执行 update 或者 select 就以 sql 为 key，查找 statement 对象，存在就使用，不存在就创建，用完不关闭 statement 对象，而是放在 Map<String,statement> 中，供下次使用，简单来说就是重复使用 statement 对象
- BatchExecutor：执行 update 将所有 sql 添加到批处理中（addBatch()），等待统一执行（executeBatch()），它缓存了多个 statement 对象，每个 statement 对象都是 addBatch() 后，等待逐一执行 executeBatch() 批处理
