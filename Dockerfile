# Build against the official Ubuntu nginx source package to ensure ABI compatibility with the stock nginx binary
FROM ubuntu:jammy-20251013

# For reproducible builds, set a fixed snapshot date for apt packages
# Current snapshot is for nginx:1.18.0-6ubuntu14.7
ARG APT_SNAPSHOT_DATETIME=20251221T000000Z

# Specify the version of the nginx source code to use
ARG NGINX_VERSION=1.18.0-6ubuntu14.7

# Specify the version of the ModSecurity-nginx to use
ARG NGINX_CONNECTOR_VERSION=v1.0.4

# Specify target architecture (x86_64 or aarch64)
ARG TARGET_ARCH=x86_64

ENV DEBIAN_FRONTEND=noninteractive

# Update the latest CA certificates
RUN apt-get update \
&& apt-get install --no-install-recommends -y ca-certificates

# Add custom sources.list to use snapshot repository
COPY ./apt/${TARGET_ARCH}/sources.list /etc/apt/

# Install build dependencies
RUN apt-get update --snapshot ${APT_SNAPSHOT_DATETIME} \
&& apt-get install --no-install-recommends --snapshot ${APT_SNAPSHOT_DATETIME} -y git libmodsecurity-dev \
&& apt-get --snapshot ${APT_SNAPSHOT_DATETIME} build-dep -y nginx-core

WORKDIR /build

# Download nginx/ModSecurity-nginx source code
# Ubuntu 22.04 LTS (Jammy) ships with nginx 1.18.0
RUN apt-get --snapshot ${APT_SNAPSHOT_DATETIME} source nginx-core=${NGINX_VERSION} \
&& cd nginx-1.18.0/debian/modules \
&& git clone https://github.com/owasp-modsecurity/ModSecurity-nginx.git http-modsecurity \
&& cd http-modsecurity \
&& git checkout ${NGINX_CONNECTOR_VERSION} \
&& cd ../../.. \
&& echo 'libnginx-mod-http-modsecurity.patch' >> debian/patches/series

# Copy custom debian files for building the package
COPY debian nginx-1.18.0/debian

# Build the nginx package with the ModSecurity module
# The resulting .deb files will be placed under /build/dist
RUN cd nginx-1.18.0 && dpkg-buildpackage -nc \
&& cd .. \
&& mkdir dist \
&& mv libnginx-mod-http-modsecurity* dist
