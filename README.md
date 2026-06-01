# Docker 环境配置指南

## 使用说明

当前 Docker 环境已经切换为国内镜像链路，并将宿主机项目目录改为通过 `.env` 配置。

容器内代码目录固定为 `/var/www/html`，请保证你的业务项目都放在同一个宿主机目录下，再通过挂载目录映射到容器中使用。

## 环境准备

### 1. 安装 Docker Desktop

请先确认 Docker Desktop 已正常启动。

建议在 Docker Desktop 的 `Docker Engine` 中配置国内镜像加速：

```json
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

保存后重启 Docker Desktop。

### 2. 配置项目目录

先复制环境变量示例文件：

```bash
cp .env.example .env
```

然后修改 `.env` 中的 `WORKSPACE_PATH`，指向你本机存放 PHP 项目的根目录，例如：

```env
WORKSPACE_PATH=/Users/kenny/Desktop/work
```

说明：

- 该目录会被挂载到容器内的 `/var/www/html`
- 例如你的项目实际目录是 `/Users/kenny/Desktop/work/oms-api`，那么容器内路径就是 `/var/www/html/oms-api`
- `nginx/template/*.template` 中的 `root` 配置已经按这个目录结构生效，不需要额外修改容器内路径

## 启动步骤

### 1. 构建并启动容器

首次启动或 Dockerfile 有变更时，建议执行：

```bash
docker-compose up -d --build
```

如果只是日常启动，也可以执行：

```bash
docker-compose up -d
```

### 2. 检查容器状态

执行以下命令确认容器已经正常启动：

```bash
docker-compose ps
```

### 3. 添加或调整 Nginx 模板

Nginx 模板目录：

```text
nginx/template/
```

新增站点时，可直接新增一个模板文件，例如：

```text
nginx/template/oms-api.template
```

模板中的站点根目录应保持容器内路径，例如：

```nginx
root /var/www/html/oms-api/public;
```

`nginx/start.sh` 会在容器启动时自动把 `template` 渲染为 `vhost` 配置，因此新增模板后需要重启 `nginx` 容器使配置重新生成：

```bash
docker-compose restart nginx
```

## 国内镜像说明

当前仓库已尽量切换为国内可用源，主要包括：

- Docker 基础镜像使用国内镜像地址
- APT 使用阿里云 Debian 镜像
- pip 使用阿里云 PyPI 镜像
- Composer 默认使用阿里云 Packagist 镜像
- `php-extension/packages/redis-5.3.7.tgz` 已内置 Redis 扩展安装包
- `php-extension/packages/swoole-4.8.11.tgz` 已内置 Swoole 扩展安装包
- `php-extension/packages/xdebug-3.1.6.tgz` 已内置 Xdebug 扩展安装包
- `php-extension/meminfo` 已内置 `php-meminfo` 源码
- `php-extension/xlswriter` 已内置 `xlswriter` 源码

说明：

- `pecl` 相关扩展安装仍依赖官方 PECL 通道，可用性受当前网络环境影响
- `redis`、`swoole`、`xdebug` 已改为从仓库内本地安装包安装
- `meminfo` 与 `xlswriter` 已改为从仓库内的本地源码目录构建，避免构建阶段再次拉取不稳定外部地址
- 如果个别扩展安装失败，优先重试 `docker-compose build --no-cache phpdebug php`

## 常见问题

### 1. 容器构建失败

建议按下面顺序排查：

1. 确认 Docker Desktop 已重启并加载镜像加速配置
2. 确认 `.env` 中的 `WORKSPACE_PATH` 路径真实存在
3. 执行重新构建命令：

```bash
docker-compose build --no-cache phpdebug php
docker-compose up -d
```

### 2. 站点访问报错或代码未生效

请重点检查：

- 本机项目是否放在 `WORKSPACE_PATH` 指定目录下
- 模板文件中的 `root` 是否与项目目录一致
- 修改模板后是否执行了 `docker-compose restart nginx`

### 3. 新增模板后没有生成对应 conf

请确认模板文件后缀为 `.template`，然后重启 `nginx` 容器重新生成配置。