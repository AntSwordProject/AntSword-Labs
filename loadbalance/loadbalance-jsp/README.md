## JSP LoadBalance

### 架构如下

```
                          ┌─────────────┐
                          │             │
                   ┌──────►  LBSNode 1  │
┌─────────┐        │      │             │
│         │        │      └─────────────┘
│  Nginx  ├────────┤
│         │        │      ┌─────────────┐
└─────────┘        │      │             │
                   └──────►  LBSNode 2  │
                          │             │
                          └─────────────┘
```


### 实验

假定业务中存在RCE漏洞，上传了 WebShell 之后, 因为负载均衡的存在, 导致后续上传的工具、执行命令等操作出现不连续的情况。

演示环境中, LBSNode1 和 LBSNode2 均存在位置相同的 Shell: ant.jsp

1. 启动环境

```
$ docker-compose up -d
```

Shell | 密码 | 编码器
:-:|:-:|:-:
`http://127.0.0.1:18080/ant.jsp` | `ant` ｜ `default`

无法直接连接内网中的两台 node, 只能通过 nginx LBS 去连接

![1.jpg](https://i.loli.net/2021/03/19/vJPXnZx1flAL3G6.jpg)

2. 打开 AntSword 添加 Shell

![2.jpg](https://i.loli.net/2021/03/19/KcgyjuTVOLNt1fo.jpg)

3. 尝试使用虚拟终端执行命令, 查看 IP

可以看到执行 ip addr 返回的IP并不是固定不变，意味着请求在两台 Node 之间跳

![3.jpg](https://i.loli.net/2021/03/19/tTBjqLuwFUpHXil.jpg)

4. 创建 antproxy.jsp 脚本

修改转发地址，转向某个 Node 的 内网的 WebShell 访问地址。图中将 target 指向了 LBSNode1 的 ant.jsp

![4.jpg](https://i.loli.net/2021/03/19/Qns5C387fezGTay.jpg)

> 注意不要使用上传功能，上传功能会分片上传，导致分散在不同 Node 上

注意要让每一台 Node 上都上传了 `antproxy.jsp`


5. 修改 Shell 配置, 将 URL 部分填写为 antproxy.jsp 的地址，其它配置不变

![5.jpg](https://i.loli.net/2021/03/19/cODduXS1E8q4BN7.jpg)

6. 测试执行命令, 查看 IP

可以看到 IP 已经固定, 意味着请求已经固定到了 LBSNode1 这台机器上了。

![6.jpg](https://i.loli.net/2021/03/19/uQEdoOXg9SrJ4wf.jpg)

查看一下 Node1 上面的 tomcat 的日志, 可以看到收束的过程

![7.jpg](https://i.loli.net/2021/03/19/MjFqOD1mIB4swyu.jpg)

### 其它事项

* LBSNode 内网之间必须要互通

### 加固建议

* LBSNode 之间禁止互通
