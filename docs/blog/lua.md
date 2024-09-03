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
