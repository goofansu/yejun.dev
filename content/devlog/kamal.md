---
title: "Kamal"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-12-02T13:31:12+08:00
tags: ["deployment"]
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
    docker pull pgvector/pgvector:pg17 --platform linux/amd64
    docker tag pgvector/pgvector:pg17 <aws-ecr-domain>/pgvector/pgvector:pg17
    docker push <aws-ecr-domain>/pgvector/pgvector:pg17
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
    docker pull <aws-ecr-domain>/pgvector/pgvector:pg17
    ```


### Deploy {#deploy}

1.  Run `kamal setup` the first time to setup everything.
2.  Run `kamal deploy` for subsequent deployments.


## Self-hosting {#self-hosting}

Since [this pr](https://github.com/basecamp/kamal/pull/981), you can use [kamal-proxy](https://github.com/basecamp/kamal-proxy) to forward requests to [accessories](https://kamal-deploy.org/docs/configuration/accessories/), it's time for self-hosting!

For example, I use Atuin[^fn:2] for shell history, and it supports syncing shell history through a sync server. Thankfully, the sync server can be self-hosted using Docker, and there is a [Docker Compose example](https://docs.atuin.sh/self-hosting/docker/#docker-compose). The task is to transform the example to a Kamal configuration:

```yaml { hl_lines=["26-29"] }
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

The highlights adds the `proxy` configuration for the `server` accessory, telling `kamal-proxy` to forwards the HTTP requests to the `server` container's `app_port`.

[kamal-services](https://github.com/goofansu/kamal-services) includes all my self-hosting services.


## Tips {#tips}


### kamal-proxy {#kamal-proxy}

You could `ssh` into the host with a running `kamal-proxy`, and execute the following command to see the proxied services:

```shell
docker exec kamal-proxy kamal-proxy list
```

For example, let's see the Atuin service:

```shell
$ docker exec kamal-proxy kamal-proxy list
Service          Host             Path  Target             State    TLS
atuin-server     atuin.yejun.dev  /     41fda841ea5c:8888  running  yes

$ docker ps --filter "name=atuin*" --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"
CONTAINER ID   IMAGE                            NAMES
41fda841ea5c   ghcr.io/atuinsh/atuin:v18.10.0   atuin-server
551f7d61d1ac   postgres:14                      atuin-db
```

[^fn:1]: The [gist](https://gist.github.com/goofansu/c1f6d806f23cca16d582709cf2fed05e) is extracted from my application and for your reference.
[^fn:2]: [Atuin](https://atuin.sh) is a command-line tool to sync, search and backup shell history.
