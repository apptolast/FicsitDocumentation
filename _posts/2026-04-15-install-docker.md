---
title: "Installing Docker on Ubuntu"
date: 2026-04-15 00:02:00 +0000
categories: [server-setup]
tags: [satisfactory, docker, ubuntu, server-setup, installation]
description: "Step-by-step guide to install Docker CE and Docker Compose plugin on Ubuntu 22.04 and 24.04 LTS to host your Satisfactory dedicated server."
toc: true
---

## Overview

Docker is the simplest way to run a Satisfactory dedicated server. The
`wolveix/satisfactory-server` image handles the SteamCMD download, server startup,
and auto-updates automatically. This guide installs Docker CE and the Compose plugin
on Ubuntu 22.04 or 24.04 LTS.

---

## Prerequisites

- Ubuntu 22.04 LTS or 24.04 LTS (x86_64/amd64)
- SSH access to your server as a user with `sudo` privileges
- Internet access from the server

---

## Step 1: Update the Package Index

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

---

## Step 2: Install Required Dependencies

```bash
sudo apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
```

---

## Step 3: Add Docker's Official GPG Key

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

---

## Step 4: Add Docker's Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

---

## Step 5: Install Docker CE and Compose Plugin

```bash
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

This installs:
- **Docker CE** — the container engine
- **Docker Compose plugin** — `docker compose` (v2, not the old `docker-compose`)

---

## Step 6: Enable and Start Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify Docker is running:

```bash
sudo systemctl status docker
```

---

## Step 7: Add Your User to the Docker Group

Running Docker commands without `sudo` requires adding your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

> You need to log out and back in (or start a new SSH session) for the group change
> to take effect.
{: .prompt-info }

Verify without sudo after re-logging:

```bash
docker run hello-world
```

Expected output includes: `Hello from Docker!`

---

## Step 8: (Optional) Configure Log Rotation

Docker containers can generate large log files. Configure log rotation to prevent disk
exhaustion:

```bash
sudo tee /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
sudo systemctl restart docker
```

---

## Verify Installation

```bash
docker --version
docker compose version
```

Example output:
```text
Docker version 27.x.x, build xxxxxxx
Docker Compose version v2.x.x
```

---

## Troubleshooting

**`docker: Got permission denied`** — you haven't logged out and back in after adding
yourself to the `docker` group. Start a new SSH session.

**`Package 'docker-ce' has no installation candidate`** — the repository wasn't added
correctly. Re-run Steps 3–5.

**`Cannot connect to the Docker daemon`** — Docker isn't running. Run:
```bash
sudo systemctl start docker
```

---

## Next Step

[Running Satisfactory Server with Docker →](/posts/run-satisfactory-docker/)
