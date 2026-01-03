# syntax=docker/dockerfile:1
ARG NGINX_FROM_IMAGE=nginx:mainline
ARG ENABLED_MODULES=ndk lua rtmp

FROM ${NGINX_FROM_IMAGE} as builder

ARG ENABLED_MODULES
ARG NGINX_FROM_IMAGE

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

RUN \
  if [ -z "${ENABLED_MODULES}" ]; then \
    echo "No additional modules enabled, exiting"; \
    exit 1; \
  fi

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    mercurial \
    gcc \
    make \
    musl-dev \
    pcre2-dev \
    zlib1g-dev \
    openssl \
    libssl-dev \
    curl \
    gnupg2 \
    apt-transport-https

WORKDIR /modules

RUN \
  mkdir -p /usr/lib/nginx/modules && \
  for module in ${ENABLED_MODULES}; do \
    echo "Building module: ${module}"; \
    mkdir -p /modules/${module}; \
  done

# Download the build script and module definitions from pkg-oss
RUN \
  git clone --depth 1 https://github.com/nginx/pkg-oss.git /pkg-oss

# Extract nginx version from the base image
RUN \
  NGINX_VERSION=$(nginx -v 2>&1 | grep -oP 'nginx/\K[0-9.]+') && \
  echo "NGINX_VERSION=${NGINX_VERSION}" > /tmp/nginx_version.env

# Build modules using pkg-oss scripts
RUN \
  . /tmp/nginx_version.env && \
  cd /pkg-oss/debian && \
  for module in ${ENABLED_MODULES}; do \
    if [ -f "Makefile.module-${module}" ]; then \
      echo "Building ${module} from pkg-oss"; \
      make -f Makefile.module-${module} BASE_VERSION=${NGINX_VERSION} module; \
    fi; \
  done

# Final image
FROM ${NGINX_FROM_IMAGE}

# Copy built modules
COPY --from=builder /pkg-oss/debian/*.deb /tmp/

# Install the built modules
RUN \
  apt-get update && \
  dpkg -i /tmp/*.deb || apt-get install -y -f && \
  rm -rf /tmp/*.deb /var/lib/apt/lists/*

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
