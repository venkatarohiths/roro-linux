# Quickstart

1. Clone: `git clone https://github.com/venkatarohiths/roro-linux && cd roro-linux`
2. Install deps: `sudo apt-get update && sudo apt-get install -y build-essential cpio rsync bc bison flex libssl-dev libelf-dev qemu-system-x86`
3. Build: `make build`
4. Test: `make qemu`
5. Flash: `dd if=out/x86_64-tiny/images/roro-linux.img of=/dev/sdX bs=4M status=progress conv=fsync`
