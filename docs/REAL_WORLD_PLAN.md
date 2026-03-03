# Roro Linux Real-World Plan

## Target real-world uses (v1)
1. Thin edge node (SSH + network tools)
2. Recovery/diagnostic VM
3. Automation runner appliance

## Productized profiles
- tiny-core: minimum shell + init
- tiny-net: tiny-core + ssh + ip tools + dhcp
- tiny-edge: tiny-net + curl + ca-certificates + rsyslog-lite (next)

## Reliability requirements
- deterministic build artifacts
- bootable ISO output for VirtualBox/VMware
- artifact checksum + manifest validation
- preflight checks for host dependencies

## Security defaults
- root login warning banner
- optional ssh key-only auth profile
- minimal attack surface package set

## Next concrete milestones
1) Bootable live ISO confirmed in VirtualBox
2) tiny-net profile defconfig + docs
3) first-boot setup script for hostname/timezone/network defaults
4) release v0.1.0-alpha artifact set
