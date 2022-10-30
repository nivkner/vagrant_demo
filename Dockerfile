# needed to support older versions of the kernel
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /opt
RUN apt-get update -y
# prerequisites for vagrant demo itself
RUN apt-get install -y apt-utils \
    && apt-get install -y build-essential git sudo
# prerequisites for libvirt
RUN apt-get install -y cpu-checker qemu-kvm
# prerequisites for qemu
# taken from: https://wiki.qemu.org/Hosts/Linux
RUN apt-get install -y libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev \
# I found out that the following packages are also required:
    ninja-build meson
# prerequisites for vagrant
# taken from: https://github.com/vagrant-libvirt/vagrant-libvirt#readme
RUN apt-get install -y vagrant ruby-libvirt \
    qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base \
    libxslt-dev libxml2-dev libvirt-dev ruby-dev
# prerequisites for linux
# taken from: https://phoenixnap.com/kb/build-linux-kernel
RUN apt-get install -y fakeroot build-essential ncurses-dev xz-utils libssl-dev bc flex libelf-dev bison \
# taken from: https://stackoverflow.com/questions/61657707/btf-tmp-vmlinux-btf-pahole-pahole-is-not-available
    dwarves \
# perf requires other libraries ("error while loading shared libraries...")
    libpython2.7 libbabeltrace-ctf1

# allows using submodules from docker container
RUN git config --global --add safe.directory /opt/vagrant_demo/qemu/source
RUN git config --global --add safe.directory /opt/vagrant_demo/linux/source

# use `--volume $(pwd):/opt/vagrant_demo` to build in host directory
RUN mkdir /opt/vagrant_demo
WORKDIR /opt/vagrant_demo

RUN mkdir /opt/vagrant_home
ENV VAGRANT_HOME=/opt/vagrant_home

ENV ROOT_DIR=/opt/vagrant_demo
ENV SHARED_VAGRANT_DIR=/opt/vagrant_demo
ENV VAGRANT_HOME=/opt/vagrant_demo/.vagrant.d
ENV APT_INSTALL="sudo apt-get install -y"
ENV APT_REMOVE="sudo apt-get purge -y"
ENV APT_UPDATE="sudo apt-get update -y"
ENV VAGRANT_UP="vagrant up --provider=libvirt"
ENV VAGRANT_SSH="vagrant ssh"
ENV VAGRANT_HALT="vagrant halt"
ENV VAGRANT_DESTROY="vagrant destroy --force"
ENV GIT_SUBMODULE_UPDATE="git submodule update --init"
ENV KCFLAGS="-fno-PIE -fno-stack-protector"
ENV KAFLAGS="-fno-PIE -fno-stack-protector"

CMD ["/usr/bin/make"]
