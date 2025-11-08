---
title: "Kamal"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-11-09T00:23:24+08:00
tags: ["aws", "devops"]
draft: false
toc: true
state: "budding"
---

## Deploy Rails applications {#deploy-rails-applications}

I recently deployed a Rails application to Hetzner and AWS China[^fn:1].
Deploying on Hetzner is simple, requiring just two steps: launching a server and deploying.
In contrast, deploying on AWS China involves extra steps because Docker Hub is not accessible from servers located in China.

The steps are:

1.  Launch an Amazon EC2 instance
2.  Create Amazon ECR repositories to store Docker Hub images
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


### Deploy {#deploy}

1.  Run `kamal setup` the first time to setup everything.
2.  Run `kamal deploy` for subsequent deployments.


## Deploy public images {#deploy-public-images}

I use Atuin[^fn:2] for shell history. It supports syncing shell history through a sync server, which can be self-hosted using Docker. [Kamal accessories](https://kamal-deploy.org/docs/configuration/accessories/) are good at deploying such Docker images. The idea is to transform its [Docker Compose example](https://docs.atuin.sh/self-hosting/docker/#docker-compose) to Kamal accessories:

```yaml
service: atuin
image: atuin
accessories:
  db:
    image: postgres:14
    host: &host hetzner
    env:
      clear:
        POSTGRES_DB: atuin
        POSTGRES_USER: atuin
      secret:
        - POSTGRES_PASSWORD
    directories:
      - ./data:/var/lib/postgresql/data/
  server:
    image: ghcr.io/atuinsh/atuin:v18.10.0
    host: *host
    cmd: server start
    env:
      clear:
        ATUIN_HOST: 0.0.0.0
        ATUIN_OPEN_REGISTRATION: false
        RUST_LOG: info,atuin_server=debug
      secret:
        - ATUIN_DB_URI
    proxy:
      host: atuin.yejun.dev
      app_port: 8888
      ssl: true
      healthcheck:
        interval: 1
        timeout: 1
        path: "/"
```

See <https://github.com/goofansu/kamal-services> for details.

[^fn:1]: The [gist](https://gist.github.com/goofansu/c1f6d806f23cca16d582709cf2fed05e) is extracted from my application and for your reference.
[^fn:2]: [Atuin](https://atuin.sh) is a command-line tool to sync, search and backup shell history.
