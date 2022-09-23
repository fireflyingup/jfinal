FROM alpine:3.16.0

LABEL author="tcsec"

ARG user=redis
ARG group=root

WORKDIR /

ADD ./base/redis-5.0.14.tar.gz /

# 添加用户
RUN adduser \
    --disabled-password \
    --gecos "" \
    --ingroup "${group}" \
    --no-create-home \
    # --uid 1001 \
    "${user}" && \
    # 安装需要的依赖
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && \
    apk update && \
    apk add --no-cache --virtual .build-deps \
    gcc \
    g++ \
    make \
    libffi-dev \
    openssl-dev && \
    cd /redis-5.0.14/deps && \
    make lua hiredis linenoise && \
    cd /redis-5.0.14 && \
    make PREFIX=/opt/tcsec/redis install && \
    # 移除不需要的文件
    rm -rf /redis-5.0.14 && \
    rm -rf /var/lib/apk/* && \
    rm -rf /tmp/* && \
    apk del .build-deps \
    gcc \
    g++ \
    make \
    libffi-dev \
    openssl-dev && \
    cd /opt/tcsec/redis && mkdir data && \
    chown -R ${user}:${group} /opt


COPY --chown=${user}:${group} ./data/redis.conf /opt/tcsec/redis/
COPY ./shell/entrypoint.sh /usr/local/bin
COPY ./shell/healthcheck.sh /usr/local/bin

EXPOSE 26200

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
