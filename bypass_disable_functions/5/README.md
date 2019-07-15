## 05 PHP-FPM

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system,putenv
```

相比 04 禁用了 `putenv`

### 使用条件

* Linux 操作系统
* PHP-FPM
* 存在可写的目录, 需要上传 `.so` 文件

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

4. 使用「绕过 disable_functions」插件, 选择 `PHP-FPM/FastCGI` 模式进行

![3.png](https://i.loli.net/2019/07/15/5d2c640c8ca8b89051.png)

注意该模式下需要选择 PHP-FPM 的接口地址, 需要自行找配置文件查 FPM 接口地址, 默认的是 `unix:///` 本地 socket 这种的,如果配置成 TCP 的默认是 `127.0.0.1:9000`

本例中, FPM 运行在 `127.0.0.1:9000` 端口

![3.5.png](https://i.loli.net/2019/07/15/5d2c6409b1e5662016.png)

所以在此处选择 `127.0.0.1:9000`:

![4.png](https://i.loli.net/2019/07/15/5d2c640faebba50053.png)

然后点击「开始」

![5.png](https://i.loli.net/2019/07/15/5d2c64126628f46480.png)

5. 成功后可以看到 `/var/www/html/` 目录下新建了一个 `.antproxy.php` 文件。我们创建副本, 并将连接的 URL shell 脚本名字改为 `.antproxy.php`, 就可以成功执行命令。

![6.png](https://i.loli.net/2019/07/15/5d2c6414d653e68495.png)

6. 使用新建的 Shell 来执行命令

![7.png](https://i.loli.net/2019/07/15/5d2c64176f0dd87138.png)

**注意**

从上图可看出来 在目标机器的 lo 上用 PHP 启动了一个 http server, 并且加载的是 PHP 默认配置。

所以我们需要在插件中填写正确的 php 可执行文件的路径(如果在环境变量中, 可以直接写 `php`)

最后使用 `tac /flag` 来读取 flag 内容
