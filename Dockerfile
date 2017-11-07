# @file Dockerfile
# @license The MIT License (MIT)
# @copyright 2016 Alex <alex@maximum.guru>

FROM        ubuntu:16.04

MAINTAINER  Alex <alex@maximum.guru>

ENV     CJDNS_REMOTE https://github.com/cjdelisle/cjdns.git

## Defaults: Compiles with SECCOMP and runs cjd's assertion tests
ENV     CJDNS_NO_TEST 0
ENV     CJDNS_SECCOMP 0

EXPOSE  65533

RUN     apt update && \
        DEBIAN_FRONTEND=noninteractive apt install -y \
            bash \
            build-essential \
            git \
            inetutils-ping \
            iproute2 \
            iptables \
            liblua5.1-0-dev \
            libsqlite3-dev \
            linux-headers-generic \
            lua-filesystem \
            lua5.1 \
            kmod \
            psmisc \
            luarocks \
            net-tools \
            nodejs \
            python \
            sqlite3 \
            unzip && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN     for module in \
            alt-getopt \
            bencode \
            bit32 \
            cgilua \
            dkjson \
            inifile \
            jsonrpc4lua \
            lua-cjson \
            luaproc \
            luasocket \
            luasql-sqlite3 \
            sha2 \
            wsapi-xavante \
            xavante; \
        do luarocks install $module; done

RUN     git clone --depth=1 ${CJDNS_REMOTE} && \
        cd cjdns && \
        NO_TEST=${CJDNS_NO_TEST} Seccomp_NO=${CJDNS_SECCOMP} ./do && \
        install -m755 -oroot -groot cjdroute /usr/sbin/cjdroute && \
        rm -rf /cjdns

WORKDIR /transitd
ADD     patches/  patches/
ADD     src/      src/
ADD     README.md .
ADD     LICENSE   .
ADD     transitd.conf.sample .

WORKDIR /
ADD     docker/*.sh ./

WORKDIR /usr/sbin/
ADD     docker/transitd-cli transitd-cli

RUN     patch -p0 /usr/local/share/lua/5.1/socket/http.lua \
                  /transitd/patches/luasocket-ipv6-fix.patch && \
        patch -p0 /usr/local/share/lua/5.1/cgilua/post.lua \
                  /transitd/patches/cgilua-content-type-fix.patch

RUN     apt purge -y --auto-remove \
            build-essential \
            git \
            liblua5.1-0-dev \
            libsqlite3-dev \
            linux-headers-generic \
            luarocks \
            nodejs \
            python \
            unzip && \
        apt autoremove; apt clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD     ["/start.sh"]

