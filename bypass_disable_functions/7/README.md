## 07 PHP7 GC with Certain Destructors UAF

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system,putenv
```

### 使用条件

* Linux 操作系统
* PHP 版本
  * 7.0 - all versions to date
  * 7.1 - all versions to date
  * 7.2 - all versions to date
  * 7.3 - all versions to date

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

![1.png](https://i.loli.net/2019/07/15/5d2c640538ed262329.png)

也可直接使用配置导入插件导入下面的配置:

```
{"_id":"YoW1ftyOv7JjrLmN","addr":"IANA 保留地址用于本地回送","category":"default","ctime":1562515402313,"decoder":"default","encode":"UTF8","encoder":"base64","httpConf":{"body":{},"headers":{}},"ip":"127.0.0.1","note":"AntSword-Labs Bypass disable functions","otherConf":{"chunk-step-byte-max":"3","chunk-step-byte-min":"2","command-path":"","filemanager-cache":1,"ignore-https":1,"request-timeout":"30000","terminal-cache":0,"upload-fragment":"500","use-chunk":0,"use-multipart":0},"pwd":"ant","type":"php","url":"http://127.0.0.1:18080/index.php","utime":1562517866376}
```

3. 尝试使用虚拟终端执行命令, 无果

![2.png](https://i.loli.net/2019/07/15/5d2c64072664176648.png)

4. 使用「绕过 disable_functions」插件, 选择 `Json Serializer UAF` 模式进行

 ![gc_1.png](https://i.loli.net/2019/11/11/RwDrUOIM7hpJQdk.png)

 注意 PHP 版本需要满足:

  * 7.0 - all versions to date
  * 7.1 - all versions to date
  * 7.2 - all versions to date
  * 7.3 - all versions to date

5. 点击「开始」按钮后，成功之后, 会创建一个新的「虚拟终端」, 在该终端下可执行命令,最后使用 `tac /flag` 来读取 flag 内容

![gc_2.png](https://i.loli.net/2019/11/11/Ks18xFXDo2RS7vf.png)

### 其它事项

* UAF 一次可能不成功，多次尝试

### 参考链接

* [https://github.com/mm0r1/exploits/tree/master/php7-gc-bypass](https://github.com/mm0r1/exploits/tree/master/php7-gc-bypass)
* [https://bugs.php.net/bug.php?id=72530](https://bugs.php.net/bug.php?id=72530)
