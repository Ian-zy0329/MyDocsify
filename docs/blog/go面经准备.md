# Go
## 基础
- 什么是闭包？Go 的闭包有哪些用法？
  答：
  - 一个函数，它“记住了”它定义时的外部变量，即使这些变量已经离开了作用域，它仍然可以使用它们
  - 即闭包是一个函数捕获并持有其外部变量的引用

```go
func Counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}

c := Counter()
fmt.Println(c()) // 输出 1
fmt.Println(c()) // 输出 2
fmt.Println(c()) // 输出 3
```
- 捕获（capture）：这个函数里用到了外部的 count 变量 
- 持有（hold）引用：Go 会让这个变量 count 和这个函数一起存在于内存中，即使正常来说它早该被释放了
> 这就是闭包的本质：函数 + 相关变量的“绑定包裹”
- 为什么这很有用？
  - 封装状态（像私有变量一样）：
  ```go
  c := Counter()
  // 这个 c 自带一个 count 状态，外部访问不了，只能调用 c() 增加 count
  ```
  - 实现函数工厂、延迟执行等功能。

- slice 的扩容机制是什么？
  答：
  - append() 时，若容量不足，底层会重新分配更大的数组，并拷贝原有数据
  - 扩容策略：
    - 容量 < 1024：新容量为原来的 2 倍
    - 容量 ≥ 1024：每次增长约 25%
  - 所以：append 后的 slice 可能会变，原 slice 不再指向同一个数组

## Goroutine
- Goroutine 是什么？和线程的区别？
  答：
  - Goroutine 是 Go 的轻量级协程，由 Go 运行时调度
  - 每个 Goroutine 初始只占用 2KB 栈内存，成千上万个协程不是问题
  - 由 GPM 模型（Goroutine、Processor、Machine）调度，避免线程阻塞
- 如何安全退出 Goroutine？

- sync 包有哪些并发控制工具？
  答：
  - sync.Mutex：互斥锁
  - sync.RWMutex：读写锁，多个读允许，写独占
  - sync.WaitGroup：等待一组 goroutine 完成
  - sync.Once：确保只执行一次（如单例）
  - sync.Map：并发安全 map
- 如何实现一个协程池？
  答：
  1. 创建一个任务通道（任务队列）
  2. 启动固定数量的 worker goroutine 从任务通道中取任务
  3. 使用 WaitGroup 等待所有任务完成
  
## channel
> 重点在于理解设计哲学（通信代替共享内存）和底层机制
### 基础概念
- Channel 是什么？  
  答：Channel 是 Go 提供的类型安全通信管道，用于 Goroutine 间同步和数据传递（遵循 "Do not communicate by sharing memory; instead, share memory by communicating" 原则）。
- 无缓冲和有缓冲 Channel 的区别？  
  答：
  - 无缓冲 Channel (ch := make(chan T))：发送和接收操作同步阻塞（"Hand-off" 机制）。发送方阻塞直到接收方就绪，反之亦然。 
  - 有缓冲 Channel (ch := make(chan T, size))：发送方在缓冲区未满时不阻塞；接收方在缓冲区非空时不阻塞。缓冲区满/空时才阻塞。
  
### 底层实现
- Channel 的底层结构（hchan）？   
关键点：环形缓冲区 + 互斥锁 + 两个等待队列。
```go
type hchan struct {
    buf      unsafe.Pointer // 环形缓冲区指针
    sendx    uint           // 发送索引
    recvx    uint           // 接收索引
    lock     mutex          // 互斥锁（非 Go 的 sync.Mutex）
    sendq    waitq          // 阻塞的发送方 Goroutine 队列
    recvq    waitq          // 阻塞的接收方 Goroutine 队列
    // ... 其他字段
}
```
- Channel 发送/接收的底层流程？   
  答：
  1. 加锁（防止竞争）。 
  2. 若对方 Goroutine 在等待： 
     - 发送时发现接收队列 recvq 非空 → 直接拷贝数据给等待的接收方。 
     - 接收时发现发送队列 sendq 非空 → 直接从发送方取数据。 
  3. 无等待者时： 
     - 有缓冲 Channel 且缓冲区未满 → 数据写入缓冲区。 
     - 无缓冲/缓冲区满 → 当前 Goroutine 加入等待队列并挂起。
  4. 解锁。

> 个人理解：channel 实际就是个环形队列的实现并有互斥锁维护 goroutine 安全，使用也是基本的入队出队，创建时可以指定 buffer 数组大小，入队通过调用 chansend 函数，chansend 函数所做的事就是如果刚好有取元素的请求调用 send 函数给出元素，或者 ringbuffer 有空间就存在没有就阻塞，这三种情况最后维护 sendx 索引，出队同理

### 高级特性
- 关闭 Channel 的规则？   
  答：
  - 关闭 nil Channel → panic
  - 重复关闭 → panic
  - 向已关闭 Channel 发送数据 → panic
  - 接收已关闭的 Channel
    - 缓冲区有数据 → 读完剩余数据后返回零值
    - 无数据 → 立即返回零值（可通过 val, ok := <-ch 中 ok=false 判断关闭）

- Channel 导致 Goroutine 泄漏的场景？  
  解决方案：用 context 超时控制或 select 退出。
```go
func leak() {
    ch := make(chan int)
    go func() {
        val := <-ch // 阻塞（无发送方）
        fmt.Println(val)
    }()
    // 无代码向 ch 发送 → Goroutine 永远阻塞（泄漏）
}
```

- select 的运行机制？   
  答：
  - 随机执行一个可运行的 case（若多个就绪）
  - 无 case 就绪时：
    - 有 default → 执行 default
    - 无 default → 阻塞直到任一 case 就绪

### 并发模式
- 如何用 Channel 实现工作池（Worker Pool）？
```go
func workerPool(jobs <-chan int, results chan<- int) {
    for job := range jobs { // 多个 Worker 并发消费 jobs
        results <- job * 2
    }
}

func main() {
    jobs, results := make(chan int, 100), make(chan int, 100)
    // 启动 3 个 Worker
    for i := 0; i < 3; i++ {
        go workerPool(jobs, results)
    }
    // 发送任务
    for i := 0; i < 10; i++ {
        jobs <- i
    }
    close(jobs) // 关键：关闭 jobs 通知 Worker 退出
    // 收集结果...
}
```

- 如何用 Channel 实现生产者-消费者模型？
```go
func producer(ch chan<- int) {
    for i := 0; i < 10; i++ {
        ch <- i
    }
    close(ch) // 生产完毕关闭 Channel
}

func consumer(ch <-chan int) {
    for num := range ch { // 自动退出循环
        fmt.Println(num)
    }
}
```
### 源码级扩展问题
- Channel 在哪些场景下会触发 Goroutine 调度？   
  答：当 Goroutine 因 Channel 操作阻塞时，调度器会将其移出线程，并运行其他 Goroutine（通过 gopark 挂起，唤醒时用 goready）

- Channel 和 sync.Mutex 如何选择？   
  答：
  - Channel：适合数据流动、生命周期管理（如任务分发、流水线）
  - sync.Mutex：适合保护临界区（如共享结构体内状态更新）

  
