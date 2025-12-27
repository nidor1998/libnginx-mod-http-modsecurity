# libnginx-mod-http-modsecurity for Ubuntu 22.04 LTS (Jammy)

## Overview

This project is intended for users who need nginx with [ModSecurity](https://github.com/owasp-modsecurity/ModSecurity)
on Ubuntu 22.04 LTS (Jammy) while keeping the stock Ubuntu nginx packages unchanged.   
It focuses on stability and operational safety.

This module is built against the official Ubuntu 22.04 LTS nginx source package and is ABI-compatible with the stock
nginx
binary.

- Compatible with Ubuntu nginx packages
- Allows safe updates of Ubuntu nginx packages
- Simple, reproducible and transparent build process
- No dependencies on outside Ubuntu repositories
- No need to compile nginx from the source

`libnginx-mod-http-modsecurity`
is [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx) [v1.0.4](https://github.com/owasp-modsecurity/ModSecurity-nginx/tree/v1.0.4)
that is the connection point between nginx and
libmodsecurity ([ModSecurity](https://github.com/owasp-modsecurity/ModSecurity)) v3.

This module is expected to continue working on Ubuntu 22.04 systems covered by
Ubuntu [ESM](https://ubuntu.com/security/esm), as long as the stock Ubuntu nginx packages remain ABI-compatible.

## Background

- Ubuntu 24.04 LTS (Noble)
  has [libnginx-mod-http-modsecurity](https://launchpad.net/ubuntu/noble/+package/libnginx-mod-http-modsecurity) , but
  it is not available for Ubuntu 22.04 LTS (Jammy)
- Some users want to integrate [ModSecurity](https://github.com/owasp-modsecurity/ModSecurity) into their running nginx
- Some users want to use the official Ubuntu nginx packages and avoid compiling from the source due to various reasons
- Some users cannot use PPA due to various reasons
- No one wants to break [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx) when the official nginx package is updated
- Some users need a reproducible and transparent build process  
  The build process is described in [Dockerfile](./Dockerfile).

## Requirements

Ubuntu 22.04 LTS (Jammy)

- x86_64 and aarch64 are supported

## License

This project is licensed under the Apache-2.0 License.

## How to build

```
docker build --build-arg TARGET_ARCH=$(uname -i) -t builder .
```

If you don't want to build yourself, you can
use [Releases](https://github.com/nidor1998/libnginx-mod-http-modsecurity/releases)  
This is
an  [immutable releases](https://docs.github.com/en/code-security/supply-chain-security/understanding-your-software-supply-chain/immutable-releases)
that is designed to be transparent, verifiable, and reproducible.

You can check the build process, logs, and the artifact supply chain.
Any commits and tags in this repository were signed and verified.

## How to install

```
# Install libmodsecurity (if not installed)
sudo apt update && sudo apt install libmodsecurity3

# If you get dependency errors, run
sudo apt --fix-broken install

# Install modsecurity-crs (if required)
sudo apt install modsecurity-crs
 
# Install libnginx-mod-http-modsecurity (x86_64)
sudo dpkg -i ./libnginx-mod-http-modsecurity_1.18.0-6ubuntu14.7+modsecurity104_amd64.deb

# Install libnginx-mod-http-modsecurity (aarch64)
sudo dpkg -i ./libnginx-mod-http-modsecurity_1.18.0-6ubuntu14.7+modsecurity104_arm64.deb
```

## How to configure

NOTE: This package does not install any configuration files
for [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx)
and [ModSecurity](https://github.com/owasp-modsecurity/ModSecurity).

Basic example (nginx.conf):

```
location / {
        modsecurity on;

        modsecurity_rules '
            SecRuleEngine On
            SecDebugLog /tmp/modsec_debug.log
            SecDebugLogLevel 9
            SecRuleRemoveById 10
            
            # modsecurity-crs is required
            Include /etc/modsecurity/crs/crs-setup.conf
            Include /usr/share/modsecurity-crs/rules/*.conf
        ';

        try_files $uri $uri/ =404;
}
```

## About the build process

This module is built against the official Ubuntu 22.04 LTS nginx source package (obtained via `apt source nginx`).   
[ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx) source code is cloned
from [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx) and checkout to `v1.0.4` tag.

For reproducibility, the build process is done in a Docker container and all apt packages are snapshotted.

The build artifacts are expected to work with any Ubuntu 22.04 LTS (Jammy) nginx version. This is because Ubuntu
maintainers
will not change nginx ABI in patch releases.

But if something goes wrong, you can always build the module against the latest nginx source package.
You can change the apt snapshot date with Docker `APT_SNAPSHOT_DATETIME` ARG and rebuild.

The build process is described in [Dockerfile](./Dockerfile).

## Roadmap

This project is based on [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx), currently
using [v1.0.4](https://github.com/owasp-modsecurity/ModSecurity-nginx/tree/v1.0.4).

Future updates of this project will follow new releases
of [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx).

Note: `libmodsecurity3` and `nginx` themselves are maintained by Ubuntu and updated independently of this project.

## Disclaimer

This is not an Ubuntu official package.

This is just a build tool for `libnginx-mod-http-modsecurity` package for Ubuntu 22.04 LTS (Jammy).  
This is not a [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx)
and [ModSecurity](https://github.com/owasp-modsecurity/ModSecurity) itself. So please use them at your own risk.

Issues related to this build process itself may be discussed.  
I cannot provide support for [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx)
and [ModSecurity](https://github.com/owasp-modsecurity/ModSecurity) itself.