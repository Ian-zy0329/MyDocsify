## Go
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
