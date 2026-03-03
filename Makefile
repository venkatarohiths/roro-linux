.PHONY: bootstrap build smoke manifest qemu

bootstrap:
	bash scripts/bootstrap-buildroot.sh

build:
	bash scripts/build-x86_64-tiny.sh

smoke:
	bash scripts/smoke-artifacts.sh --out-dir out/x86_64-tiny/images --require-iso 0

manifest:
	bash scripts/artifact-manifest.sh out/x86_64-tiny/images

qemu:
	bash qemu/run.sh
