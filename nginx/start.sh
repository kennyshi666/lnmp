#!/bin/sh
set -e

# 动态生成虚拟主机配置文件
echo "Generating Nginx virtual host config files..."
if [ "$(ls -A /etc/nginx/template/*.template 2>/dev/null)" ]; then
    for template in /etc/nginx/template/*.template; do
        conf_file="/etc/nginx/vhost/$(basename ${template%.template}).conf"
        envsubst '${PHP_FPM_SERVICE}' < "$template" > "$conf_file"
        echo "Generated $conf_file from $template"
    done
else
    echo "No virtual host templates found in /etc/nginx/vhost/"
fi

# 更新 /etc/hosts 文件
if [ -f /etc/hosts-modification ]; then
    if ! grep -q "$(head -n 1 /etc/hosts-modification)" /etc/hosts; then
        cat /etc/hosts-modification >> /etc/hosts
        echo "Hosts modifications applied."
    else
        echo "Hosts modifications already applied."
    fi
else
    echo "No hosts-modification file found."
fi

# 启动 Nginx
echo "Starting Nginx..."
nginx -g "daemon off;"
