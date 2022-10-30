# needed to support older versions of the kernel
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /opt
RUN apt-get update -y \
    && apt-get install -y apt-utils \
    && apt-get install -y build-essential git sudo

# use `--volume $(pwd):/opt/vagrant_demo` to build in host directory
RUN mkdir /opt/vagrant_demo
WORKDIR /opt/vagrant_demo

CMD ["/usr/bin/make"]
