# Go
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
## 并发模式
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
## 源码级扩展问题
- Channel 在哪些场景下会触发 Goroutine 调度？   
  答：当 Goroutine 因 Channel 操作阻塞时，调度器会将其移出线程，并运行其他 Goroutine（通过 gopark 挂起，唤醒时用 goready）
- Channel 和 sync.Mutex 如何选择？
  答：
  - Channel：适合数据流动、生命周期管理（如任务分发、流水线）
  - sync.Mutex：适合保护临界区（如共享结构体内状态更新）


## GMP模型
- GMP 是 Go Runtime 的调度模型：
  - G（Goroutine）：任务。
  - M（Machine）：线程。
  - P（Processor）：逻辑处理器，负责调度 G。
- 调度过程： 
  - G 挂在 P 的队列上。 
  - M 获取一个 P 执行其中的 G。 
  - 支持 work stealing 和调度抢占。
### make 和 new 的区别，引用类型的意义
- new：
  仅分配内存（置零），返回指向该类型指针（*T）。
  适用于所有类型（值类型如 int、结构体；引用类型如 map）。
- make：
  分配并初始化内存（如初始化内部数据结构），返回类型本身（T，非指针）。
  仅适用于引用类型：slice、map、channel。
- 引用类型的意义：
  引用类型（slice、map、channel）内部包含指向底层数据的指针，赋值或传参时传递的是描述符（如切片的 ptr/len/cap），而非整个数据。这避免了数据复制，提升效率，但需注意多个变量引用同一底层数据时的并发安全问题。
### 逃逸分析
- 目的：编译器决定变量分配在栈还是堆。
  栈分配：函数退出自动回收，高效。
  堆分配：变量生命周期跨越函数边界时（逃逸），需由 GC 回收。
- 常见逃逸场景：
  - 返回局部变量指针（如函数内 new 的对象）。
  - 闭包引用外部变量。
  - 变量大小超过栈限制。
  - 发送指针到 channel 或存入全局变量。
- 查看逃逸分析：
```bash
go build -gcflags="-m" main.go
```
### Channel 的实现
- 核心结构（runtime.hchan）：
```go
type hchan struct {
  qcount   uint           // 队列中元素数量
  dataqsiz uint           // 环形队列大小
  buf      unsafe.Pointer // 环形队列指针
  sendx    uint           // 发送索引
  recvx    uint           // 接收索引
  sendq    waitq          // 发送等待队列（sudog 链表）
  recvq    waitq          // 接收等待队列（sudog 链表）
  lock     mutex          // 互斥锁
}
```
- 操作原理：
  - 发送/接收：
    - 若缓冲区有空位/数据
    - 否则，当前 goroutine 加入 sendq/recvq 队列，并阻塞（被挂起到 G 的 waiting 状态）。
  - 同步：当阻塞的发送者遇到接收者（或反之），绕过缓冲区直接拷贝数据，并唤醒对方。
  - 关闭：设置 closed 标志，唤醒所有等待的 goroutine，后续发送会 panic。

### GMP 与 GC
(1) GMP 模型
- 组件：
  - G（Goroutine）：轻量级协程。 
  - M（Machine）：系统线程，绑定内核线程。 
  - P（Processor）：调度上下文，包含本地运行队列（runq）。
- 调度流程：
  1. 新 G 加入 P 的本地 runq。 
  2. M 从绑定的 P 的 runq 获取 G 执行。 
  3. 若 P 的 runq 为空，从全局队列或其他 P 偷取（work-stealing）。
- 网络 I/O 等待队列：
  - 当 G 阻塞于网络 I/O 时，会被移到 网络轮询器（netpoller）（由运行时管理）。 
  - netpoller 基于 epoll（Linux）/kqueue（BSD）实现，当 I/O 就绪时，将 G 放回 P 的 runq。

(2) GC（垃圾回收）
- 三色标记法：
  - 白：待扫描对象（最终回收）。 
  - 灰：已扫描但子对象未扫描。 
  - 黑：已扫描且子对象已扫描（存活）。
- 读写屏障（Write Barrier）：
  - 插入屏障（Dijkstra 屏障）：
    写操作时，若目标对象为黑色，将新引用对象标记为灰色。
```go
obj.field = newRef  // 若 obj 为黑，则标记 newRef 为灰
```
- 删除屏障（Yuasa 屏障）：
  删除引用时，将原引用对象标记为灰色。
```go
oldRef = obj.field  // 删除前标记 oldRef 为灰
obj.field = nil
```
- Go 1.8+ 混合屏障：结合两者，在标记阶段保证强三色不变性。

### Map 的实现
(1) 原生 map
- 底层结构（runtime.hmap）：
  - 桶数组（[]bmap），每个桶存 8 个键值对。
  - 哈希值低位定位桶，高位在 tophash 中加速匹配。
  - 扩容机制：
    - 增量扩容（负载因子 > 6.5）：2 倍扩容，渐进式迁移（写入时迁移旧桶）。
    - 等量扩容（溢出桶过多）：bucket 数量不变，整理溢出桶提高效率。
- 随机遍历：
  - 每次 range map 随机选择起始桶和槽位（通过 hmap.offset 和随机种子）。
  - 避免依赖固定遍历顺序（安全考虑）。

(2) sync.Map
- 适用场景：读多写少，键集合相对稳定。
- 核心设计：
```go
type Map struct {
  mu    Mutex
  read  atomic.Value // 只读部分（readOnly 结构）
  dirty map[any]*entry // 可写部分（加锁访问）
}
```
  - 读：优先无锁访问 read，未命中时加锁查 dirty。
  - 写：
    - 若 read 中存在键，尝试原子更新。
    - 否则加锁操作 dirty，必要时触发 dirty 提升（全量拷贝 read 数据并重建）。
  - 删除：标记删除（entry.p 置 nil），dirty 中直接删除。
