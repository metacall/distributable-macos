#!/bin/bash

# Image disk size
SIZE=50G

# Script for creating a MacOs ISO (from Linux or Docker)
apt-get update
apt-get install -y --no-install-recommends git qemu-utils #dmg2img
git clone --depth 1 https://github.com/acidanthera/OpenCorePkg
cd OpenCorePkg/Utilities/macrecovery
python3 ./macrecovery.py -b Mac-E43C1C25D4880AD6 -m 00000000000000000 download # Big Sur(11)
qemu-img convert BaseSystem.dmg -O qcow2 -p -c BaseSystem.img
qemu-img create -f qcow2 /home/arch/OSX-KVM/mac_hdd_ng.img "${SIZE}"
qemu-img check -r all mac_hdd_ng.img
# dmg2img BaseSystem.dmg mac_hdd_ng.img
# mv mac_hdd_ng.img /output
