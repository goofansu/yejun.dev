---
title: "Kamal deploy on AWS China"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
tags: ["aws", "devops"]
draft: false
toc: true
---

This post describes the steps to deploy a Rails application to AWS China.


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

Kamal uses the `basecamp/kamal-proxy` image without specifying the registry name, so create a tag from our container.

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
