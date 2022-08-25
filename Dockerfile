FROM alpine:3 as builder

ARG AWS_CLI_VERSION=2.7.26
RUN apk add --no-cache python3 py3-virtualenv git unzip groff build-base libffi-dev cmake
RUN git clone --single-branch --depth 1 -b ${AWS_CLI_VERSION} https://github.com/aws/aws-cli.git

WORKDIR aws-cli
RUN sed -i'' 's/PyInstaller.*/PyInstaller==5.2/g' requirements-build.txt
RUN python3 -m venv venv
RUN . venv/bin/activate
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN scripts/installers/make-exe
RUN unzip -q dist/awscli-exe.zip
RUN aws/install --bin-dir /aws-cli-bin
RUN /aws-cli-bin/aws --version

# reduce image size: remove autocomplete and examples
RUN rm -rf /usr/local/aws-cli/v2/current/dist/aws_completer /usr/local/aws-cli/v2/current/dist/awscli/data/ac.index /usr/local/aws-cli/v2/current/dist/awscli/examples
RUN find /usr/local/aws-cli/v2/current/dist/awscli/botocore/data -name examples-1.json -delete

# build the final image
FROM alpine:3
COPY --from=builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=builder /aws-cli-bin/ /usr/local/bin/
RUN apk -v --update --no-cache add \
        python3 \
        groff && \
        rm /var/cache/apk/* && rm -rf /usr/share/doc/ && rm -rf /usr/share/man && rm -rf /usr/share/locale/
ENTRYPOINT ["aws"]
