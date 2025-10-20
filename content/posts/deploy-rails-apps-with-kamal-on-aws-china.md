---
title: "Deploy Rails apps with Kamal on AWS China"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-10-20T11:59:08+08:00
tags: ["aws", "devops"]
draft: false
toc: true
---

This post describes the steps to deploy a Rails application with Kamal on AWS China.


## Install docker {#install-docker}

```shell
sudo apt update
sudo apt install docker.io
sudo usermod -aG docker $USER
```


## Push docker images to ECR {#push-docker-images-to-ecr}

AWS servers in China cannot access the official Docker registry, so it is necessary to use ECR and push the Docker images there.

Kamal requires the `basecamp/kamal-proxy` image, and I use `postgres` in my project, so I will push both images to ECR.
Since I use macOS for development and Ubuntu amd64 for the server, I will pull images for the `linux/amd64` platform.

```shell
docker pull basecamp/kamal-proxy:v0.9.0 --platform linux/amd64
docker tag basecamp/kamal-proxy:v0.9.0 <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0
docker push <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0

docker pull postgres:17 --platform linux/amd64
docker tag postgres:17 <aws-ecr-registry>/postgres:17
docker push <aws-ecr-registry>/postgres:17
```


## Pull ECR images on EC2 {#pull-ecr-images-on-ec2}


### Install aws-cli {#install-aws-cli}

```shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
```


### Login ECR {#login-ecr}

Before proceeding with this step, create an IAM user named "kamal-deployer" and assign only the "AmazonEC2ContainerRegistryFullAccess" permission.

```shell
aws configure
aws ecr get-login-password --region cn-northwest-1 | docker login --username AWS --password-stdin <aws-ecr-registry>
```


### Pull kamal-proxy image from ECR {#pull-kamal-proxy-image-from-ecr}

Kamal uses the `basecamp/kamal-proxy` image without specifying the registry name, so tag the image after pulling it.

```shell
docker pull <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0
docker tag <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0 basecamp/kamal-proxy:v0.9.0
```


### Pull postgres image from ECR {#pull-postgres-image-from-ecr}

```shell
docker pull <aws-ecr-registry>/postgres:17
```


## Start postgres {#start-postgres}

```shell
kamal accessory boot db
```


## Deploy application {#deploy-application}

```shell
kamal setup
kamal deploy
```


## Software versions {#software-versions}


### Kamal {#kamal}

```shell
$ kamal version
2.7.0
```


### Docker (local) {#docker--local}

```shell
$ docker version
Client:
 Version:           28.3.3
 API version:       1.51
 Go version:        go1.24.5
 Git commit:        980b856
 Built:             Fri Jul 25 11:33:03 2025
 OS/Arch:           darwin/arm64
 Context:           orbstack

Server: Docker Engine - Community
 Engine:
  Version:          28.3.3
  API version:      1.51 (minimum version 1.24)
  Go version:       go1.24.5
  Git commit:       bea959c
  Built:            Fri Jul 25 11:34:22 2025
  OS/Arch:          linux/arm64
  Experimental:     false
 containerd:
  Version:          v2.1.4
  GitCommit:        75cb2b7193e4e490e9fbdc236c0e811ccaba3376
 runc:
  Version:          1.3.1
  GitCommit:        e6457afc48eff1ce22dece664932395026a7105e
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

```


### Docker (server) {#docker--server}

```shell
$ docker version
Client:
 Version:           28.2.2
 API version:       1.50
 Go version:        go1.23.1
 Git commit:        28.2.2-0ubuntu1~24.04.1
 Built:             Wed Sep 10 14:16:39 2025
 OS/Arch:           linux/amd64
 Context:           default

Server:
 Engine:
  Version:          28.2.2
  API version:      1.50 (minimum version 1.24)
  Go version:       go1.23.1
  Git commit:       28.2.2-0ubuntu1~24.04.1
  Built:            Wed Sep 10 14:16:39 2025
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.7.28
  GitCommit:
 runc:
  Version:          1.3.0-0ubuntu2~24.04.1
  GitCommit:
 docker-init:
  Version:          0.19.0
  GitCommit:
```
