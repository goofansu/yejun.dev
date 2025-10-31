---
title: "Kamal"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-10-31T19:26:36+08:00
tags: ["aws", "devops"]
draft: false
toc: true
state: "evergreen"
---

我最近使用 Kamal 将一个 Rails 应用程序部署到 Hetzner 和 AWS 中国区。


## Hetzner {#hetzner}

部署过程非常直接，部署体验非常流畅。


### 步骤 {#steps}

1.  启动服务器
2.  [部署](#deploy)


## AWS 中国区 {#aws-china}

由于中国区服务器无法访问 Docker Hub，因此需要额外的工作。


### 步骤 {#steps}

1.  启动 Amazon EC2 实例
2.  创建 Amazon ECR 仓库来存储 `basecamp/kamal-proxy` 和 `pgvector/pgvector` 镜像
3.  创建 IAM 用户并仅分配「AmazonEC2ContainerRegistryFullAccess」权限
4.  [在本地机器上推送 Docker Hub 镜像到 Amazon ECR](#push-docker-hub-images-to-amazon-ecr-on-local-machine)
5.  [在 Amazon EC2 上从 Amazon ECR 拉取镜像](#pull-images-from-amazon-ecr-on-amazon-ec2)
6.  [部署](#deploy)


### 在本地机器上推送 Docker Hub 镜像到 Amazon ECR {#push-docker-hub-images-to-amazon-ecr-on-local-machine}

1.  登录 ECR
    ```shell
    aws configure
    aws ecr get-login-password | docker login --username AWS --password-stdin <aws-ecr-domain>
    ```

2.  推送 `basecamp/kamal-proxy` 镜像
    ```shell
    docker pull basecamp/kamal-proxy:v0.9.0 --platform linux/amd64
    docker tag basecamp/kamal-proxy:v0.9.0 <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
    docker push <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
    ```

3.  推送 `pgvector/pgvector` 镜像
    ```shell
    docker pull pgvector/pgvector:17 --platform linux/amd64
    docker tag pgvector/pgvector:17 <aws-ecr-domain>/pgvector/pgvector:17
    docker push <aws-ecr-domain>/pgvector/pgvector:17
    ```


### 在 Amazon EC2 上从 Amazon ECR 拉取镜像 {#pull-images-from-amazon-ecr-on-amazon-ec2}

1.  安装 Docker
    ```shell
    sudo apt update
    sudo apt install -y docker.io
    sudo usermod -aG docker $USER
    ```

2.  安装 AWS CLI
    ```shell
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt install -y unzip
    unzip awscliv2.zip
    sudo ./aws/install
    ```

3.  登录 ECR
    ```shell
    aws configure
    aws ecr get-login-password | docker login --username AWS --password-stdin <aws-ecr-domain>
    ```

4.  拉取 `basecamp/kamal-proxy` 镜像
    ```shell
    docker pull <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
    docker tag <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0 basecamp/kamal-proxy:v0.9.0
    ```

5.  拉取 `pgvector/pgvector` 镜像
    ```shell
    docker pull <aws-ecr-domain>/pgvector/pgvector:17
    ```


## 部署 {#deploy}

1.  首次运行 `kamal setup` 来设置所有内容。
2.  后续部署运行 `kamal deploy`。


## 配置 {#config}

参考配置见 [gist](https://gist.github.com/goofansu/c1f6d806f23cca16d582709cf2fed05e)。
