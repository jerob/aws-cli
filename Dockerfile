FROM alpine:3
# The AWS CLI uses glibc, groff, and less.
# These are included by default in most major distributions of Linux.
RUN apk -v --update add \
        python3 \
        py3-pip \
        groff \
        less \
        mailcap \
        unzip \
        curl \
        gnupg
COPY public_key.gpg .
# Download the installation file
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.26.zip" -o "awscliv2.zip"
# Import the AWS CLI public key with the following command.
RUN gpg --import public_key.gpg
# Download the AWS CLI signature file for the package you downloaded.
# It has the same path and name as the .zip file it corresponds to, but has the extension .sig.
# We save it to the current directory as a file named awscliv2.sig.
RUN curl -o awscliv2.sig https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.7.26.zip.sig
# Verify the signature, passing both the downloaded .sig and .zip file names as parameters to the gpg command.
RUN gpg --verify awscliv2.sig awscliv2.zip
# Unzip the installer.
# The following command unzips the package and creates a directory named aws under the current directory.
RUN unzip awscliv2.zip
# Run the install program. The installation command uses a file named install in the newly unzipped aws directory.
# By default, the files are all installed to /usr/local/aws-cli, and a symbolic link is created in /usr/local/bin.
# The command includes sudo to grant write permissions to those directories.
RUN ./aws/install
RUN apk -v --purge del py-pip && \
    rm /var/cache/apk/*
VOLUME /root/.aws
VOLUME /app
WORKDIR /app
