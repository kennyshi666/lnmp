# Docker环境配置指南

## 环境准备

### 1. 开启VPN
确保网络连接正常，开启VPN以便正常访问Docker Hub等外部资源。

### 2. 安装Docker Desktop
下载并安装Docker Desktop，确保Docker服务正常运行。

在docker desktop里面配置docker engine加上下面配置
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
## 部署步骤

### 3. 启动容器服务
执行以下命令启动所有服务：
```bash
docker-compose up -d
```

### 4. 处理PHP-FPM容器创建失败问题
如果PHP-FPM容器创建失败，请按以下步骤处理：

1. 手动拉取PHP镜像：
   ```bash
   docker pull php:7.3-fpm
   ```

2. 重新执行启动命令：
   ```bash
   docker-compose up -d
   ```

## 配置管理

### 5. 添加Nginx模板配置
1. 进入nginx模板目录：
   ```
   nginx/template/
   ```

2. 新增系统模板文件，例如：
   ```
   oms-api.template
   ```

3. 重启Nginx容器使配置生效：
   ```bash
   docker restart nginx容器名
   ```

## 注意事项

- 确保所有步骤按顺序执行
- 如遇到其他容器启动失败，可参考步骤4的解决方案
- 新增模板文件后记得重启相应服务