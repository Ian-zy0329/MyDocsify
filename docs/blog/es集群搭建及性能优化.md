# 基于 docker 搭建 es集群以及性能优化
## Elasticsearch 配置

### 路径设置
es 的数据目录和日志目录
````
path:
  data: /var/data/elasticsearch
  logs: /var/log/elasticsearch
````
### 锁定物理内存
锁定物理内存，在es运行后锁定使用的内存大小，锁定大小一般是服务器内存的50%。当系统物理内存空间不足，es不会使用交换分区，避免频繁的交换导致的IOPS升高，属于性能上的优化。默认是不打开
````
bootstrap.memory_lock
````

### 跨域设置
````
http.cors.enabled: true 【是否开启跨域访问】
http.cors.allow-origin: “*” 【开启跨域后，能访问es的地址限制，*号表示无限制】
````
### 基础参数
````
node.name	配置ES集群内的节点名称，同一个集群内的节点名称要具备唯一性。
node.data：true	指定该节点是否存储索引数据，默认为true。
node.master：true	指定该节点是否有资格被选举成为node，一定要注意只是设置成有资格， 不代表该node一定就是master，默认是true。es是默认集群中的第一台机器为master，如果这台机挂了就会重新选举master。
node.attr.rack: r1	集群个性化调优设置，用于后期集群进行分片分配时的过滤
discovery.seed_hosts	当节点启动时，传递一个初始主机列表来执行发现
cluster.initial_master_nodes	写入候选主节点的设备地址，来开启服务时就可以被选为主节点
ingest.geoip.downloader.enabled	是否开启es启动时更新地图相关的数据库。
````

### 集群参数
````
cluster.name	配置ES集群名称，同一个集群内的所有节点集群名称必须一致。
cluster.routing.allocation.same_shard.host:true	防止同一个shard的主副本存在同一个物理机上。
cluster.routing.allocation.node_initial_primaries_recoveries: 4	设置一个节点的并发数量，两种情况，第一种是在初始复苏过程中，默认是4个。
cluster.routing.allocation.node_concurrent_recoveries: 4	设置一个节点的并发数量的第二种情况，在添加、删除节点及调整时。默认是4个。
discovery.zen.minimum_master_nodes: 1	设置一个集群中主节点的数量，当多于三个节点时，该值可在2-4之间。
discovery.zen.ping.timeout: 3s	设置ping其他节点时的超时时间，网络比较慢时可将该值设大
discovery.zen.ping.multicast.enabled: false	禁止当前节点发现多个集群节点，默认值为true
cluster.fault_detection.leader_check.interval：2s	设置每个节点在选中的主节点的检查之间等待的时间。默认为1秒
discovery.cluster_formation_warning_timeout: 30s	启动后30秒内，如果集群未形成，那么将会记录一条警告信息，警告信息未master not fount开始，默认为10秒

````
