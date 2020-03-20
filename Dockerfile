FROM golang:alpine AS builder

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

MAINTAINER Roman Atachiants "roman@misakai.com"

# Copy the directory into the container outside of the gopath
RUN mkdir -p /go-build/src/github.com/emitter-io/emitter/
WORKDIR /go-build/src/github.com/emitter-io/emitter/
ADD . /go-build/src/github.com/emitter-io/emitter/

# Download and install any required third party dependencies into the container.
RUN apk add --no-cache git g++ \
  && go install \
  && apk del g++

# Base image for runtime
FROM alpine:latest

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk add --no-cache tzdata\
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm -rf /var/cache/apk/*

RUN apk --no-cache add ca-certificates

WORKDIR /root/
# Get the executable binary from build-img declared previously
COPY --from=builder /go/bin/emitter .

# Expose emitter ports
EXPOSE 4000
EXPOSE 8080
EXPOSE 8443

# Start the broker
CMD ["./emitter"]
