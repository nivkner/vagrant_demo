##### Constants #####

LINUX_SOURCE_DIR := $(ROOT_DIR)/linux/source
LINUX_BUILD_DIR := $(ROOT_DIR)/linux/build
LINUX_INSTALL_DIR := $(ROOT_DIR)/linux/install
# choose a specific linux kernel version with "cd linux/source && git checkout tags/v5.4"
LINUX_OFFICIAL_GIT_REPO := https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git

##### Targets (== files) #####

LINUX_MAKEFILE := $(LINUX_SOURCE_DIR)/Makefile
LINUX_CONFIG := $(LINUX_BUILD_DIR)/.config
LINUX_DEB_PACKAGE := $(LINUX_BUILD_DIR)/../linux-image-$(LOCALVERSION)-1_amd64.deb
BZIMAGE := $(LINUX_BUILD_DIR)/arch/x86/boot/bzImage
VMLINUZ := $(LINUX_INSTALL_DIR)/vmlinuz-$(LOCALVERSION)
INITRD := $(LINUX_INSTALL_DIR)/initrd.img-$(LOCALVERSION)
PERF_TOOL := $(LINUX_BUILD_DIR)/tools/perf/perf
INSTALLED_PERF_TOOL := /usr/lib/linux-tools/$(LOCALVERSION)/perf

##### Scripts and commands #####

MAKE_LINUX := make -C $(LINUX_SOURCE_DIR) --jobs=$$(nproc) O=$(LINUX_BUILD_DIR)

##### Recipes #####

.PHONY: linux linux/clean linux/fetch-upstream

linux: $(VMLINUZ) $(INITRD) $(PERF_TOOL)

$(INSTALLED_PERF_TOOL): $(PERF_TOOL)
	sudo mkdir -p $(dir $@)
	sudo cp -f $< $@

$(PERF_TOOL): $(LINUX_CONFIG)
	$(MAKE_LINUX) tools/perf

$(INITRD): $(VMLINUZ)
	cd $(VANILLA_VM_DIR)
	$(VAGRANT_UP)
	$(VAGRANT_SSH) -c "cp /boot/$(notdir $@) $@"
	$(VAGRANT_HALT)

$(VMLINUZ): $(LINUX_DEB_PACKAGE) | $(LINUX_INSTALL_DIR)
	cd $(VANILLA_VM_DIR)
	$(VAGRANT_UP)
	$(VAGRANT_SSH) -c "sudo dpkg --install $<"
	$(VAGRANT_SSH) -c "cp /boot/$(notdir $@) $@"
	$(VAGRANT_HALT)

$(LINUX_DEB_PACKAGE): $(BZIMAGE)
	$(MAKE_LINUX) bindeb-pkg

$(BZIMAGE): $(LINUX_CONFIG) | $(linux_prerequisites)
	$(MAKE_LINUX)

$(LINUX_CONFIG): $(VANILLA_VM_LINUX_CONFIG) $(LINUX_MAKEFILE) | $(LINUX_BUILD_DIR)
	# take the config of vanilla_vm as the baseline
	cp -f $< $@
	# change dir before calling the config script (it works only from the source dir)
	cd $(LINUX_SOURCE_DIR)
	# edit the config as you wish, e.g., set the kernel name:
	./scripts/config --file $@ --set-str LOCALVERSION "-$(LOCALVERSION)"
	# disable the kernel module signing facility. Learn more at:
	# https://www.kernel.org/doc/html/v5.4/admin-guide/module-signing.html
	# https://lists.debian.org/debian-kernel/2016/04/msg00579.html
	./scripts/config --file $@ --set-val SYSTEM_TRUSTED_KEYS ""
	./scripts/config --file $@ --set-val MODULE_SIG_KEY ""
	./scripts/config --file $@ --disable MODULE_SIG_ALL
	./scripts/config --file $@ --disable CONFIG_LOCALVERSION_AUTO
	yes '' | make O=$(LINUX_BUILD_DIR) oldconfig # sanitize the .config file

$(LINUX_MAKEFILE):
	git submodule update --init --progress linux

# create the required directories when we need them (same recipe for multiple targets)
$(LINUX_BUILD_DIR) $(LINUX_INSTALL_DIR):
	mkdir -p $@

linux/clean:
	$(MAKE_LINUX) mrproper
	rm -rf $(LINUX_BUILD_DIR)
	rm -rf $(LINUX_INSTALL_DIR)
	cd linux && rm -f *1_amd64.deb *1_amd64.buildinfo *1_amd64.changes # the files created by "make bindeb-pkg"

linux/fetch-upstream:
	cd $(LINUX_SOURCE_DIR)
	if [[ $$(git remote | grep upstream) == "" ]] ; then
		git remote add upstream $(LINUX_OFFICIAL_GIT_REPO)
	fi
	$(FETCH_UPSTREAM)

