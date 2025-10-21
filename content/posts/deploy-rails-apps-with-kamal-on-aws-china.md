---
title: "Deploy Rails apps with Kamal on AWS China"
author: ["Yejun Su"]
date: 2025-10-18T12:00:00+08:00
lastmod: 2025-10-22T00:06:32+08:00
tags: ["aws", "devops"]
draft: false
toc: true
---

This post describes the steps to deploy a Rails application with Kamal on AWS China.


## Install Docker on EC2 {#install-docker-on-ec2}

```shell
sudo apt update
sudo apt install docker.io
sudo usermod -aG docker $USER
```


## Prepare Docker images {#prepare-docker-images}

AWS servers in China cannot access the official Docker registry, so it is necessary to use [AWS ECR](https://www.amazonaws.cn/ecr/) and push the Docker images there.


### Push images to ECR {#push-images-to-ecr}

Kamal requires the `basecamp/kamal-proxy` image, and I use `postgres` in my project, so I will push both images to ECR.
Since I use macOS for development and Ubuntu amd64 for the server, I will pull images for the `linux/amd64` platform.

```shell
docker pull basecamp/kamal-proxy:v0.9.0 --platform linux/amd64
docker tag basecamp/kamal-proxy:v0.9.0 <aws-ecr-registry>/basecamp/kamal-proxy:v0.9.0
docker push <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0

docker pull postgres:17 --platform linux/amd64
docker tag postgres:17 <aws-ecr-domain>/postgres:17
docker push <aws-ecr-domain>/postgres:17
```


### Pull images on EC2 {#pull-images-on-ec2}


#### Install aws-cli {#install-aws-cli}

```shell
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
```


#### Login ECR {#login-ecr}

Before proceeding with this step, create an IAM user named "kamal-deployer" and assign only the "AmazonEC2ContainerRegistryFullAccess" permission.

```shell
aws configure
aws ecr get-login-password --region cn-northwest-1 | docker login --username AWS --password-stdin <aws-ecr-domain>
```


#### Pull kamal-proxy image from ECR {#pull-kamal-proxy-image-from-ecr}

Kamal uses the `basecamp/kamal-proxy` image without specifying the registry name, so tag the image after pulling it.

```shell
docker pull <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0
docker tag <aws-ecr-domain>/basecamp/kamal-proxy:v0.9.0 basecamp/kamal-proxy:v0.9.0
```


#### Pull postgres image from ECR {#pull-postgres-image-from-ecr}

```shell
docker pull <aws-ecr-domain>/postgres:17
```


## Deploy {#deploy}

Run `kamal setup` the first time, then `kamal deploy` for subsequent deployments.

The `config/deploy.yml` is like the following, there are two containers: `web` and `db`:

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
