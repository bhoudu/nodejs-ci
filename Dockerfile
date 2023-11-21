# Build final docker image now that all binaries are OK
FROM node:20.6-alpine3.18 as base

ARG UPLIFT_VERSION
ENV UPLIFT_VERSION $UPLIFT_VERSION

# Install alpine packages
RUN apk update
RUN apk upgrade --available
RUN apk add --no-cache aws-cli curl wget zip tar gzip git openssl jq bash
RUN rm -rf /var/cache/apk/*

# Test AWSCLI
RUN aws --version

# Install uplift
COPY files/uplift.tar.gz /root/uplift.tar.gz
RUN mkdir -p /root/uplift_temp
RUN tar -xvzf /root/uplift.tar.gz -C /root/uplift_temp
RUN rm /root/uplift.tar.gz
RUN mv /root/uplift_temp/uplift /usr/local/bin/uplift
RUN rm -Rf /root/uplift_temp
RUN chmod +x /usr/local/bin/uplift
RUN uplift version

# Entrypoint
ENTRYPOINT ["/bin/bash", "-l", "-c"]

# Test the image before building
FROM base AS test

RUN node -v && \
    npm -v && \
    yarn -v && \
    uplift version && \
    aws --version

# Create Image after tests
FROM base AS release
