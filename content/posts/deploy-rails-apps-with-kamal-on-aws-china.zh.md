---
title: "在 AWS 中国区使用 Kamal 部署 Rails 应用"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-10-21T20:36:08+08:00
tags: ["aws", "devops"]
draft: false
toc: true
---

本文介绍了在 AWS 中国区使用 Kamal 部署 Rails 应用程序的步骤。


## 在 EC2 上安装 Docker {#install-docker-on-ec2}

```shell
sudo apt update
sudo apt install docker.io
sudo usermod -aG docker $USER
```


## 准备 Docker 镜像 {#prepare-docker-images}

由于 AWS 中国区服务器无法访问官方 Docker 镜像仓库，因此需要使用 [AWS ECR](https://www.amazonaws.cn/ecr/) 并将 Docker 镜像推送到那里。


### 推送镜像到 ECR {#push-images-to-ecr}

Kamal 需要 `basecamp/kamal-proxy` 镜像，而我的项目中使用了 `postgres`，所以我将把这两个镜像都推送到 ECR。
由于我使用 macOS 作为开发机器，使用 Ubuntu amd64 作为服务器，因此我将拉取 `linux/amd64` 平台的镜像。

```shell
docker pull basecamp/kamal-proxy:v0.9.0 --platform linux/amd64
docker tag basecamp/kamal-proxy:v0.9.0 <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0
docker push <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0

docker pull postgres:17 --platform linux/amd64
docker tag postgres:17 <aws-ecr-registry>/postgres:17
docker push <aws-ecr-registry>/postgres:17
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

在进行此步骤之前，请创建一个名为 "kamal-deployer" 的 IAM 用户，并仅分配 "AmazonEC2ContainerRegistryFullAccess" 权限。

```shell
aws configure
aws ecr get-login-password --region cn-northwest-1 | docker login --username AWS --password-stdin <aws-ecr-registry>
```


#### 从 ECR 拉取 kamal-proxy 镜像 {#pull-kamal-proxy-image-from-ecr}

Kamal 使用 `basecamp/kamal-proxy` 镜像时没有指定镜像仓库名称，因此需要在拉取后对镜像进行标记。

```shell
docker pull <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0
docker tag <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0 basecamp/kamal-proxy:v0.9.0
```


#### 从 ECR 拉取 postgres 镜像 {#pull-postgres-image-from-ecr}

```shell
docker pull <aws-ecr-registry>/postgres:17
```


## 部署 {#deploy}


### 首次部署所有内容 {#deploy-everything-for-the-first-time}

```shell
kamal setup
```


### 部署服务 {#deploy-services}

```shell
kamal deploy
```
