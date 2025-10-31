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

I recently deployed a Rails application to Hetzner and AWS China using Kamal.


## Hetzner {#hetzner}

The process is very straightforward, and the deployment experience is really smooth.


### Steps {#steps}

1.  Launch a server
2.  [Deploy](#deploy)


## AWS China {#aws-china}

Additional work is needed because Docker Hub is inaccessible from servers in China.


### Steps {#steps}

1.  Launch an Amazon EC2 instance
2.  Create Amazon ECR repositories to store `basecamp/kamal-proxy` and `pgvector/pgvector` images
3.  Create an IAM user and assign only the "AmazonEC2ContainerRegistryFullAccess" permission
4.  [Push Docker Hub images to Amazon ECR on local machine](#push-docker-hub-images-to-amazon-ecr-on-local-machine)
5.  [Pull images from Amazon ECR on Amazon EC2](#pull-images-from-amazon-ecr-on-amazon-ec2)
6.  [Deploy](#deploy)


### Push Docker Hub images to Amazon ECR on local machine {#push-docker-hub-images-to-amazon-ecr-on-local-machine}

1.  Login ECR
    ```shell
    aws configure
    aws ecr get-login-password | docker login --username AWS --password-stdin <aws-ecr-domain>
    ```

2.  Push `basecamp/kamal-proxy` image
    ```shell
    docker pull basecamp/kamal-proxy:v0.9.0 --platform linux/amd64
    docker tag basecamp/kamal-proxy:v0.9.0 <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
    docker push <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
    ```

3.  Push `pgvector/pgvector` image
    ```shell
    docker pull pgvector/pgvector:17 --platform linux/amd64
    docker tag pgvector/pgvector:17 <aws-ecr-domain>/pgvector/pgvector:17
    docker push <aws-ecr-domain>/pgvector/pgvector:17
    ```


### Pull images from Amazon ECR on Amazon EC2 {#pull-images-from-amazon-ecr-on-amazon-ec2}

1.  Install Docker
    ```shell
    sudo apt update
    sudo apt install -y docker.io
    sudo usermod -aG docker $USER
    ```

2.  Install AWS CLI
    ```shell
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt install -y unzip
    unzip awscliv2.zip
    sudo ./aws/install
    ```

3.  Login ECR
    ```shell
    aws configure
    aws ecr get-login-password | docker login --username AWS --password-stdin <aws-ecr-domain>
    ```

4.  Pull `basecamp/kamal-proxy` image
    ```shell
    docker pull <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
    docker tag <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0 basecamp/kamal-proxy:v0.9.0
    ```

5.  Pull `pgvector/pgvector` image
    ```shell
    docker pull <aws-ecr-domain>/pgvector/pgvector:17
    ```


## Deploy {#deploy}

1.  Run `kamal setup` the first time to setup everything.
2.  Run `kamal deploy` for subsequent deployments.


## Config {#config}

See [gist](https://gist.github.com/goofansu/c1f6d806f23cca16d582709cf2fed05e) for reference.
