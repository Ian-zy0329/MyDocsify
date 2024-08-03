##### 1.  Java 中的⼏种基本数据类型是什么？对应的包装类型是什么？各⾃占⽤多少字节呢？

byte（Byte 1字节）、short（Short 2字节）、int（Integer 4字节）、long（Long 8字节）、double（Double 4字节）、float（Float 8字节）、char（Character 2字节）、boolean（Boolean 1位）

##### 2. String 、 StringBuffer 和 StringBuilder 的区别是什么? String 为什么是不可变的?

- String 和 StringBuffer 线程安全（对方法加了同步锁），StringBuilder 线程不安全。
- String 不可变，可以理解为常量所以线程安全，String 用 final 修饰字符数组来保存字符串（final 修饰的类不能被继承，方法不能被重写，基本数据类型值不能被改变，引用类型不能指向其他对象
- StringBuffer 和 StringBuilder 提供很多修改字符串的方法比如 append()
- 性能上 StringBuilder > StringBuffer > String，String 被改变会生成一个新的 String 对象，再将指针指向新对象，而 StringBuffer 和 StringBuilder 都是对对象本身进行操作

##### 3. String s1 = new String("abc"); 这段代码创建了⼏个字符串对象?

两个，其中一个字符串对象的引用被保存在字符串常量池中

##### 4. == 与 equals?hashCode 与 equals ?

- 对于基本数据类型来说，`==` 比较的是值。

- 对于引用数据类型来说，`==` 比较的是对象的内存地址。

- **equals()** 不能用于判断基本数据类型的变量，只能用来判断两个对象是否相等

- **类没有重写 equals()方法**：通过`equals()`比较该类的两个对象时，等价于通过“==”比较这两个对象，使用的默认是 `Object`类`equals()`方法。

  **类重写了 equals()方法**：一般我们都重写 `equals()`方法来比较两个对象中的属性是否相等；若它们的属性相等，则返回 true(即，认为这两个对象相等)。

- 如果重写 `equals()` 时没有重写 `hashCode()` 方法的话就可能会导致 `equals` 方法判断是相等的两个对象，`hashCode` 值却不相等。

#### 1. ArrayList 和 LinkedList 区别

- 都是线程不安全的
- ArrayList 底层数据结构是数组，LinkedList 底层是双向链表
- 是否支持快速随机访问，ArrayList 实现了 RandomAccess 接口支持快速随机访问（底层是数组天然支持），链表需要遍历到特定位置才能访问
- 内存占用上，LinkedList 每个元素占用空间比 ArrayList 更多
- 插入删除元素上，ArrayList 在头部插入删除时间复杂度 o(n)，尾部 o(1)，指定位置 o(n)，因为前面或后面元素需要移位，LinkedList 头尾部插入删除都是 o(1)，指定位置 o(n)，因为需要遍历到才能执行操作

#### 2. JVM 组成

- 类加载器子系统（将字节码文件加载到内存）
- 运行时数据区（线程私有：程序计数器、本地方法栈、 虚拟机栈。线程共享：堆、方法区、直接内存）
- 执行引擎（执行字节码，包含解释器和即时编译器 JIT）
- 本地接口（提供调用本地方法的接口）
- 垃圾回收器（自动管理内存）

#### 3. 红黑树

- 自平衡的二叉搜索树