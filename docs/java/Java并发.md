## 什么是线程死锁?
多个线程同时阻塞，等待某个锁的释放

## volatile 关键字
volatile 关键字能保证数据的可见性，都到主存中进行读取，但不能保证数据的原子性。synchronized 关键字两者都能保证。

单例模式：双重校验锁实现对象单例（线程安全）
~~~java
public class Singleton {

    private volatile static Singleton uniqueInstance;

    private Singleton() {
    }

    public  static Singleton getUniqueInstance() {
       //先判断对象是否已经实例过，没有实例化过才进入加锁代码
        if (uniqueInstance == null) {
            //类对象加锁
            synchronized (Singleton.class) {
                if (uniqueInstance == null) {
                    uniqueInstance = new Singleton();
                }
            }
        }
        return uniqueInstance;
    }
}
~~~

## 乐观锁和悲观锁
### 什么是悲观锁？
悲观锁假设都是最坏的情况，每次访问共享资源都会出现问题，所以每次在获取资源操作上都会上锁，其他线程想获取这个资源就会阻塞直到锁被释放。

synchronized 和 ReentrantLock 等独占锁就是悲观锁思想的实现。

### 什么是乐观锁？
乐观锁假设都是最好的情况，每次访问共享资源都不会出现问题，不需要加锁，每次提交修改的时候去验证对应的资源是否被其他线程修改。

java.util.concurrent.atomic包下面的原子变量类（比如AtomicInteger、LongAdder）就是使用了乐观锁的一种实现方式 CAS 算法实现的

CAS 算法：Compare And Swap，用一个预期值和要更新的变量值进行比较，两值相等才会进行更新，CAS 涉及到三个操作数：V、E、N、

ABA 问题

## synchronized 是什么？有什么用？
synchronized 可以保证被它修饰的方法或者代码块在任何时刻只有一个线程执行

### synchronized 和 volatile 有什么区别？
- volatile 用于修饰变量，synchronized 用于修饰方法和代码块
- volatile 可见性，不能保证原子性，synchronized 都保证
- volatile 主要用于解决变量在多个线程中的可见性，synchronized 主要解决多个线程之间访问资源的同步性

## ReentrantLock 是什么？
ReentrantLock 实现了 Lock 接口，是一个可重入且独占式的锁，ReentrantLock 更灵活、更强大，增加了轮询、超时、中断、公平锁和非公平锁等高级功能

### 公平锁和非公平锁有什么区别？
- 公平锁：锁被释放后，先申请的线程先得到锁。为了维护顺序，上下文切换频繁，性能差点
- 非公平锁：锁被释放后，随即或者按照其他优先级顺序获得锁。性能更好，但可能某些线程一直获取不到锁

### synchronized 和 ReentrantLock 有什么区别？
- 两者都是可重入锁
- ReentrantLock增加了一些高级功能：等待可中断、可实现公平锁、可实现选择性通知

## ThreadLocal 有什么用？
ThreadLocal类主要解决的就是让每个线程绑定自己的值，如果你创建了一个ThreadLocal变量，那么访问这个变量的每个线程都会有这个变量的本地副本

### ThreadLocal 原理

## 线程池
### ThreadPoolExecutor 构造函数来创建，线程池常见参数有哪些？如何解释？
- int corePoolSize,//线程池的核心线程数量
- int maximumPoolSize,//线程池的最大线程数
- long keepAliveTime,//当线程数大于核心线程数时，多余的空闲线程存活的最长时间
- TimeUnit unit,//时间单位
- BlockingQueue<Runnable> workQueue,//任务队列，用来储存等待执行任务的队列
- ThreadFactory threadFactory,//线程工厂，用来创建线程，一般默认即可
- RejectedExecutionHandler handler//拒绝策略，当提交的任务过多而不能及时处理时，我们可以定制策略来处理任务

### 线程池的拒绝策略有哪些？当前同时运行的线程数量达到最大线程数量并且队列也已经被放满了任务
- ThreadPoolExecutor.AbortPolicy：抛出 RejectedExecutionException来拒绝新任务的处理。
- ThreadPoolExecutor.CallerRunsPolicy：调用执行自己的线程运行任务，任务回退给调用者，使用调用者的线程来执行任务
- ThreadPoolExecutor.DiscardPolicy：不处理新任务，直接丢弃掉
- ThreadPoolExecutor.DiscardOldestPolicy：此策略将丢弃最早的未处理的任务请求

### 线程池处理任务的流程了解吗？
- 如果当前运行线程数小于核心线程数，就创建一个线程执行任务
- 大于等于核心线程数，小于最大线程数，就把任务放到任务队列中
- 大于等于核心线程数，小于最大线程数，但是任务队列满了，就创建一个线程执行任务
- 等于最大线程数，并且任务队列满了，就基于拒绝策略，默认是 abortPolicy ，会抛出异常