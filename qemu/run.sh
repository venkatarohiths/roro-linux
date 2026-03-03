#!/bin/sh
set -eu

MEM=512
CPUS=1
IMG="out/x86_64-tiny/images/roro-linux.img"

usage() {
  cat <<'EOF'
Usage: qemu/run.sh [--memory <MB>] [--cpus <N>] [--image <path>]

Options:
  --memory <MB>   Guest memory in MB (default: 512)
  --cpus <N>      Number of virtual CPUs (default: 1)
  --image <path>  Disk image path (default: out/x86_64-tiny/images/roro-linux.img)
  --help          Show this help and exit
EOF
}

require_arg() {
  if [ "$#" -lt 2 ]; then
    echo "ERROR: missing value for $1" >&2
    usage >&2
    exit 1
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --memory)
      require_arg "$@"
      MEM="$2"
      shift 2
      ;;
    --cpus)
      require_arg "$@"
      CPUS="$2"
      shift 2
      ;;
    --image)
      require_arg "$@"
      IMG="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$MEM" in
  *[!0-9]*|"")
    echo "ERROR: --memory must be a positive integer in MB" >&2
    exit 1
    ;;
esac

case "$CPUS" in
  *[!0-9]*|"")
    echo "ERROR: --cpus must be a positive integer" >&2
    exit 1
    ;;
esac

if [ "$MEM" -le 0 ] || [ "$CPUS" -le 0 ]; then
  echo "ERROR: --memory and --cpus must be greater than zero" >&2
  exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "ERROR: qemu-system-x86_64 not found in PATH"
  exit 1
fi

if [ ! -f "$IMG" ]; then
  echo "ERROR: disk image not found at $IMG"
  echo "Run 'make build' first."
  exit 1
fi

KVM=""
[ -e /dev/kvm ] && KVM="-enable-kvm"
qemu-system-x86_64 $KVM -m "$MEM" -smp "$CPUS" -drive file="$IMG",if=virtio,format=raw -nic user,model=virtio-net-pci -serial mon:stdio
