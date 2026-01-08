# Crowdsec LUA bouncer based on Nginx with Lua and RTMP Modules

This repository contains a custom nginx Docker image based on the official nginx stable image with additional modules:
- **lua** (with ndk dependency) - For scripting capabilities within nginx
- **rtmp** - For RTMP streaming support

Additionally the `nginx-lua-rtmp/cs-nginx-bouncer:latest` docker image contains LUA Crowdsec bouncer.
This docker image needs two environment variables:
- CROWDSEC_API_URL
- CROWDSEC_API_KEY

which overrides `/etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf` API_URL and API_KEY values. 

## Build Process

The image is built automatically via GitHub Actions when:
1. The Dockerfile is modified
2. The workflow file is modified
3. Manually triggered via GitHub Actions UI

## Usage

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/<your-username>/skyduino/nginx-lua-rtmp:latest
```

### Run the container

```bash
docker run -d -p 80:80 ghcr.io/<your-username>/skyduino/nginx-lua-rtmp:latest
```

### Build locally

```bash
docker build --build-arg ENABLED_MODULES="ndk lua rtmp" -t nginx-lua-rtmp .
```

## Configuration

The base image is `nginx:mainline`. You can modify this in the GitHub Actions workflow file by changing the `NGINX_FROM_IMAGE` build argument.

## Modules Included

- **ndk** (Nginx Development Kit) - Required dependency for lua module
- **lua** (v0.10.28) - Embed Lua scripting into nginx
- **rtmp** (v1.2.2) - RTMP protocol support for live streaming

## GitHub Actions Workflow

The workflow file is located at `.github/workflows/build-nginx-image.yml`. It:
- Uses Docker Buildx for multi-platform builds (amd64, arm64)
- Pushes images to GitHub Container Registry (ghcr.io)
- Creates automatic tags based on branch, PR, or commit SHA
- Uses GitHub Actions cache for faster builds

### Manual Trigger

To manually trigger a build:
1. Go to the Actions tab in your GitHub repository
2. Select "Build Nginx Docker Image with Modules"
3. Click "Run workflow"
4. Select the branch and click "Run workflow"

## Accessing the Image

After the workflow runs successfully, the image will be available at:
```
ghcr.io/<your-github-username>/<repository-name>/nginx-lua-rtmp:latest
```

Make sure your GitHub repository has package visibility set appropriately (public or private).
