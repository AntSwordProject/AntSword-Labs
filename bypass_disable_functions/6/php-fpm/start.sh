#!/bin/sh
# 启动的时候生成 flag
echo "antsword{"$(openssl rand -hex 16)"}" > /flag
# webshell 下看不到 flag 内容
chmod 600 /flag
# 想要看 flag 内容, 通过执行命令 tac /flag 来完成
chmod +s /usr/bin/tac

php-fpm
