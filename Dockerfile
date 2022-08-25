FROM alpine:3
ENV AWSCLI_VERSION "1.25.60"
RUN apk -v --update add \
        python3 \
        py3-pip \
        groff \
        less \
        mailcap
RUN pip install --upgrade awscli==${AWSCLI_VERSION} && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*
VOLUME /root/.aws
VOLUME /app
WORKDIR /app
