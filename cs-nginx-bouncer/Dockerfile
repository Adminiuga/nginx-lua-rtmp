ARG NGINX_FROM_IMAGE=ghcr.io/adminiuga/nginx-lua-rtmp:latest
FROM ${NGINX_FROM_IMAGE} AS builder

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

COPY ./dummy-packages/* /tmp/packages/dummy/
RUN apt-get update \
    && apt-get install -y --no-install-suggests --no-install-recommends \
                patch make wget git devscripts debhelper dpkg-dev \
                quilt lsb-release build-essential libxml2-utils \
                equivs git g++ \
    && cd /tmp/packages \
    && git clone --depth 1 https://github.com/crowdsecurity/cs-nginx-bouncer.git \
    && pushd cs-nginx-bouncer \
    && debuild -us -uc \
    && popd \
    && for EQUIV in /tmp/packages/dummy/*.equivs; do \
            equivs-build "$EQUIV"; \
       done

FROM ${NGINX_FROM_IMAGE}
RUN --mount=type=bind,target=/tmp/packages/,source=/tmp/packages/,from=builder \
    apt-get update \
    && apt-get install -y --no-install-suggests --no-install-recommends \
        lua5.1 liblua5.1-0-dev luarocks /tmp/packages/*.deb \
    && rm -rf /var/lib/apt/lists/