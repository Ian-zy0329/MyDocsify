#### 1. sql 连接

内连接（inner join）、左连接（left join）、右连接（right join）、全连接（full join）

#### 2. MySQL 储存引擎

- InnoDB（默认储存引擎，支持事务） 和 MyISAM（之前的默认储存引擎）
- InnoDB 支持行级锁和表级锁，提供事务支持，具有提交和回滚事务的能力
- InnoDB 支持数据库异常崩溃后的安全恢复，依赖于 redo log
- InnoDB 使用 B+Tree 作为索引的底层数据结构

#### 3. sql 优化

- 在 GROUP BY 子句和 ORDER BY 子句中使用索引
- 使用延迟查询优化 limit [offset], [rows]  offset 过大的话，会造成严重的性能问题，原因主要是因为 MySQL 每次会把一整行都扫描出来，扫描 offset 遍，找到 offset 之后会抛弃 offset 之前的数据，再从 offset 开始读取 10 条数据，这里利用了覆盖索引的特性，覆盖索引即需要查询的字段正好是索引的字段，那么直接根据该索引，就可以查到数据了，而无需回表查询。当使用非主键索引进行查询时，数据库会先找到对应的主键值，然后再通过主键索引来定位和检索完整的行数据。这个过程被称为“回表”。
-  EXPLAIN 来查看 SQL 执行计划