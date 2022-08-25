FROM alpine:3 as builder
ENV AWSCLI_VERSION=2.7.26
RUN apk add --no-cache \
    python3 \
    curl \
    make \
    cmake \
    gcc \
    libc-dev \
    libffi-dev \
    openssl-dev \
    && curl -L https://github.com/aws/aws-cli/archive/refs/tags/${AWSCLI_VERSION}.tar.gz | tar -xz \
    && cd awscli-${AWSCLI_VERSION} \
    && ./configure --prefix=/opt/aws-cli/ --with-download-deps \
    && make \
    && make install

# COPY public_key.gpg .
# Download the installation file
# RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# Import the AWS CLI public key with the following command.
# RUN gpg --import public_key.gpg
# Download the AWS CLI signature file for the package you downloaded.
# It has the same path and name as the .zip file it corresponds to, but has the extension .sig.
# We save it to the current directory as a file named awscliv2.sig.
# RUN curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip.sig
# Verify the signature, passing both the downloaded .sig and .zip file names as parameters to the gpg command.
# RUN gpg --verify awscliv2.sig awscliv2.zip
# Unzip the installer.
# The following command unzips the package and creates a directory named aws under the current directory.
# RUN unzip awscliv2.zip
# Run the install program. The installation command uses a file named install in the newly unzipped aws directory.
# By default, the files are all installed to /usr/local/aws-cli, and a symbolic link is created in /usr/local/bin.
# The command includes sudo to grant write permissions to those directories.
# RUN ./aws/install
# reduce image size: remove autocomplete and examples
RUN rm -rf /opt/aws-cli/dist/aws_completer /opt/aws-cli/dist/awscli/data/ac.index /opt/aws-cli/dist/awscli/examples
RUN find /opt/aws-cli/dist/awscli/botocore/data -name examples-1.json -delete

FROM alpine:3
# ENV PATH="${PATH}:/usr/local/bin"
COPY --from=builder /opt/aws-cli/ /opt/aws-cli/
# The AWS CLI uses groff
# These are included by default in most major distributions of Linux.
RUN apk -v --update --no-cache add \
        python3 \
        groff \
        mailcap && \
        rm /var/cache/apk/* && rm -rf /usr/share/doc/ && rm -rf /usr/share/man && rm -rf /usr/share/locale/
VOLUME /root/.aws
VOLUME /app
WORKDIR /app

ENTRYPOINT ["/opt/aws-cli/bin/aws"]
