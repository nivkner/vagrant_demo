#! /bin/bash

# use "bash strict mode" (http://redsymbol.net/articles/unofficial-bash-strict-mode/)
set -euo pipefail

# add the apt repository given in https://www.vagrantup.com/downloads
#curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
#sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" --update

# install the libvirt plugin: https://github.com/vagrant-libvirt/vagrant-libvirt
if [ -z "$VAGRANT_HOME" ]; then
    echo "Error: VAGRANT_HOME is undefined (but running vagrant implicitly assumes it is defined)"
fi
vagrant_plugin=vagrant-libvirt
if [[ $(vagrant plugin list) == *"$vagrant_plugin"* ]] ; then
    echo "$vagrant_plugin is installed"
else
    echo "$vagrant_plugin is currently not installed"
    echo "going to install it via:"
    vagrant plugin install $vagrant_plugin
fi

