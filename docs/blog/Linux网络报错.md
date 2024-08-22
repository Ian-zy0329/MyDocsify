# Linux网络服务报错
>分享一下今天用本地 Linux 虚拟机时，Tabby 一直连不上 Linux，发现是 Linux network 服务挂了，解决方法和思路

## Tabby 连不上 Linux
之前也出现过连不上的情况，解决办法是超时时间过短，然后在 Tabby 设置--高级设置 里'准备超时'时间设长点就连上了
![img_8.png](_media%2Fimg_8.png)
但这次很明显不是连接超时的问题，报错显示的是'ECONNREFUSED'，拒绝连接，那说明 ip 地址不对，但不应该，Linux 我是设置了静态 ip 的
![img_7.png](_media%2Fimg_7.png)

## 检查 Linux 静态 ip 设置
通过'cd /etc/sysconfig/network-scripts/'命令进入到这个文件夹下
![img_9.png](_media%2Fimg_9.png)
通过'vim ifcfg-enp0s3'进入编辑
![img_11.png](_media%2Fimg_11.png)
确认静态 ip 设置没问题

## 检查 network 服务是否正常
通过'systemctl status network.service'命令，发现网络服务挂了
![img_12.png](_media%2Fimg_12.png)
尝试重启'systemctl restart network.service'失败
![img_13.png](_media%2Fimg_13.png)

## 查看日志
'cd /var/log'进入日志目录
![img_14.png](_media%2Fimg_14.png)
然后用'tail -n 30 messages'查看最后30行的内容，发现问题，配置的静态 ip 已经存在了
![img_15.png](_media%2Fimg_15.png)

## 问题原因以及解决方案
应该是电脑重启自动分配 ip 刚好跟 Linux 虚拟机撞了，但由于改虚拟机 ip 会牵扯其他服务配置，最后就改了下本地
把自动设置成手动即可，以防再次出现这个问题。
![img_16.png](_media%2Fimg_16.png)