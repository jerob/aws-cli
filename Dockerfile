FROM alpine:3
RUN apk -v --update add \
        python3 \
        py3-pip \
        groff \
        less \
        mailcap
RUN pip install --upgrade awscli
RUN apk -v --purge del py-pip && \
    rm /var/cache/apk/*
VOLUME /root/.aws
VOLUME /app
WORKDIR /app
