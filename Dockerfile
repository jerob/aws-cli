FROM alpine:3
RUN apk -v --update add \
        python \
        py-pip \
        groff \
        less \
        mailcap \
        && \
    pip install --upgrade awscli && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*
VOLUME /root/.aws
VOLUME /app
WORKDIR /app
