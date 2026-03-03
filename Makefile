.PHONY: build clean menuconfig qemu release validate

BR_DIR := buildroot
OUT_DIR := out/x86_64-tiny

build:
	sh scripts/validate.sh
	sh scripts/bootstrap-buildroot.sh
	sh scripts/build-x86_64-tiny.sh

clean:
	rm -rf out output build host staging target .config 2>/dev/null || true
	@if [ -d "$(BR_DIR)" ]; then $(MAKE) -C $(BR_DIR) O=$(abspath $(OUT_DIR)) clean; fi

menuconfig:
	sh scripts/bootstrap-buildroot.sh
	$(MAKE) -C $(BR_DIR) O=$(abspath $(OUT_DIR)) BR2_DEFCONFIG=$(abspath configs/roro_defconfig) defconfig
	$(MAKE) -C $(BR_DIR) O=$(abspath $(OUT_DIR)) menuconfig

qemu:
	sh qemu/run.sh

release:
	sh scripts/artifact-manifest.sh out/x86_64-tiny/images
	@echo "Release artifacts prepared under out/x86_64-tiny/images"

validate:
	sh scripts/validate.sh
