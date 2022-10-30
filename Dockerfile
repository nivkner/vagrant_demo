# needed to support older versions of the kernel
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /opt
RUN apt-get update -y \
    && apt-get install -y apt-utils \
    && apt-get install -y build-essential git sudo

# allows using submodules from docker container
RUN git config --global --add safe.directory /opt/vagrant_demo/qemu/source
RUN git config --global --add safe.directory /opt/vagrant_demo/linux/source

# use `--volume $(pwd):/opt/vagrant_demo` to build in host directory
RUN mkdir /opt/vagrant_demo
WORKDIR /opt/vagrant_demo

# to avoid overriding VAGRANT_HOME on non-docker runs
RUN mkdir /opt/vagrant_home
ENV VAGRANT_HOME=/opt/vagrant_home
CMD ["/usr/bin/make"]
