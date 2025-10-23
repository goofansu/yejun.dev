---
title: "Kamal"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-10-23T13:34:37+08:00
tags: ["aws", "devops"]
draft: false
toc: true
state: "seedling"
---

## 在 AWS 中国区部署 {#deploy-on-aws-china}


### 在 EC2 上安装 Docker {#install-docker-on-ec2}

```shell
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
```


### 推送镜像到 ECR {#push-images-to-ecr}

中国区的 AWS 服务器无法访问官方的 Docker 镜像仓库，因此需要使用 [AWS ECR](https://www.amazonaws.cn/ecr/) 并将 Docker 镜像推送到那里。

Kamal 需要 `basecamp/kamal-proxy` 镜像，我的项目中使用 `postgres`，所以我会将这两个镜像都推送到 ECR。
由于我使用 macOS 进行开发，服务器使用 Ubuntu amd64，因此我会拉取 `linux/amd64` 平台的镜像。

```shell
docker pull basecamp/kamal-proxy:v0.9.0 --platform linux/amd64
docker tag basecamp/kamal-proxy:v0.9.0 <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0
docker push <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0

docker pull postgres:17 --platform linux/amd64
docker tag postgres:17 <aws-ecr-domain>/postgres:17
docker push <aws-ecr-domain>/postgres:17
```


### 在 EC2 上拉取镜像 {#pull-images-on-ec2}


#### 安装 aws-cli {#install-aws-cli}

```shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
```


#### 登录 ECR {#login-ecr}

在执行此步骤之前，创建一个名为 "kamal-deployer" 的 IAM 用户，并仅分配 "AmazonEC2ContainerRegistryFullAccess" 权限。

```shell
aws configure
aws ecr get-login-password --region cn-northwest-1 | docker login --username AWS --password-stdin <aws-ecr-domain>
```


#### 从 ECR 拉取 kamal-proxy 镜像 {#pull-kamal-proxy-image-from-ecr}

Kamal 使用 `basecamp/kamal-proxy` 镜像时没有指定仓库名称，因此在拉取后需要标记镜像。

```shell
docker pull <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
docker tag <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0 basecamp/kamal-proxy:v0.9.0
```


#### 从 ECR 拉取 postgres 镜像 {#pull-postgres-image-from-ecr}

```shell
docker pull <aws-ecr-domain>/postgres:17
```


### 部署 {#deploy}

在本地机器上，首次运行 `kamal setup`，后续部署运行 `kamal deploy`。

`config/deploy.yml` 配置如下，包含两个容器：`web` 和 `db`：

```yaml
# Name of your application. Used to uniquely configure containers.
service: myapp

# Name of the container image.
image: myapp

# Deploy to these servers.
servers:
  web:
    - <host>

# Enable SSL auto certification via Let's Encrypt and allow for multiple apps on a single web server.
proxy:
  ssl: true
  host: <domain>
  forward_headers: true

# Credentials for your image host.
registry:
  server: <aws-ecr-domain>
  username: AWS
  password:
    - KAMAL_REGISTRY_PASSWORD

# Inject ENV variables into containers (secrets come from .kamal/secrets).
env:
  secret:
    - RAILS_MASTER_KEY
    - POSTGRES_PASSWORD
  clear:
    SOLID_QUEUE_IN_PUMA: true
    DB_HOST: myapp-db

# Aliases are triggered with "bin/kamal <alias>". You can overwrite arguments on invocation:
# "bin/kamal logs -r job" will tail logs from the first server in the job section.
aliases:
  console: app exec --interactive --reuse "bin/rails console"
  shell: app exec --interactive --reuse "bash"
  logs: app logs -f
  dbc: app exec --interactive --reuse "bin/rails dbconsole"

# Use a persistent storage volume for sqlite database files and local Active Storage files.
# Recommended to change this to a mounted volume path that is backed up off server.
volumes:
  - "myapp_storage:/rails/storage"

# Bridge fingerprinted assets, like JS and CSS, between versions to avoid
# hitting 404 on in-flight requests. Combines all files from new and old
# version inside the asset_path.
asset_path: /rails/public/assets

# Configure the image builder.
builder:
  arch: amd64

ssh:
  user: ubuntu

# Use accessory services (secrets come from .kamal/secrets).
accessories:
  db:
    image: <aws-ecr-domain>/postgres:17
    host: myapp-prod-app
    port: 5432
    env:
      clear:
        POSTGRES_DB: myapp_production
        POSTGRES_USER: myapp
      secret:
        - POSTGRES_PASSWORD
    directories:
      - data:/var/lib/postgresql/data
```
