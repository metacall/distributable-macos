#!/bin/bash

# SSH credentials
USR=user
PASS=alpine

# # Sudo
# SUDO=

# if [ "$EUID" -ne 0 ]; then
# 	SUDO=sudo
# fi

# # Install KVM (TODO: it needs reboot, not suitable for CI/CD)
# ${SUDO} apt-get install -y qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager libguestfs-tools
# ${SUDO} systemctl enable --now libvirtd
# ${SUDO} systemctl enable --now virtlogd
# ${SUDO} mkdir -p /sys/module/kvm/parameters
# echo 1 | ${SUDO} tee /sys/module/kvm/parameters/ignore_msrs
# ${SUDO} modprobe kvm
# ${SUDO} usermod -aG docker $(id -u -n)
# ${SUDO} usermod -aG libvirt $(id -u -n)
# ${SUDO} usermod -aG kvm $(id -u -n)

# TODO: Check if this is different from 0 for correctness (Nested Hardware Virtualization)
# egrep -c '(svm|vmx)' /proc/cpuinfo

# # Build MacOs image
# docker run --rm -w /workdir -v $(pwd)/iso:/iso -v $(pwd)/iso/output:/output -it python:3.10-slim-bullseye /iso/iso.sh

# TODO: Shared folder for output
# FOLDER=~/somefolder
# -v "${FOLDER}:/mnt/hostshare" \
# -e EXTRA="-virtfs local,path=/mnt/hostshare,mount_tag=hostshare,security_model=passthrough,id=hostshare" \
# !!! Open Terminal inside macOS and run the following command to mount the virtual file system
# sudo -S mount_9p hostshare

# Boot MacOs image
docker run --rm --name metacall-distributable-macos -it \
	--device /dev/kvm \
	--device /dev/snd \
	-p 50922:10022 \
	-e "USERNAME=${USR}" \
	-e "PASSWORD=${PASS}" \
	-e GENERATE_UNIQUE=true \
	-e CPU_STRING=$(nproc) \
	-e NETWORKING=vmxnet3 \
	-e NOPICKER=true \
	-e MASTER_PLIST_URL=https://raw.githubusercontent.com/sickcodes/Docker-OSX/master/custom/config-nopicker-custom.plist \
	-e TERMS_OF_USE=i_agree \
	sickcodes/docker-osx:auto

# docker exec -it containerid ssh -i ~/.ssh/id_docker_osx user@127.0.0.1 -p 10022
# ssh ${USR}@localhost:50922 /bin/sh <<\EOF
# mdutil -i off -a

# defaults write com.apple.loginwindow autoLoginUser -bool true

# defaults write com.apple.Accessibility DifferentiateWithoutColor -int 1
# defaults write com.apple.Accessibility ReduceMotionEnabled -int 1
# defaults write com.apple.universalaccess reduceMotion -int 1
# defaults write com.apple.universalaccess reduceTransparency -int 1
# defaults write com.apple.Accessibility ReduceMotionEnabled -int 1

# defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
# defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
# defaults write com.apple.commerce AutoUpdate -bool false
# defaults write com.apple.commerce AutoUpdateRestartRequired -bool false
# defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 0
# defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 0
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 0
# defaults write com.apple.SoftwareUpdate AutomaticDownload -int 0

# defaults write com.apple.universalaccessAuthWarning /System/Applications/Utilities/Terminal.app -bool true
# defaults write com.apple.universalaccessAuthWarning /usr/libexec -bool true
# defaults write com.apple.universalaccessAuthWarning /usr/libexec/sshd-keygen-wrapper -bool true
# defaults write com.apple.universalaccessAuthWarning com.apple.Messages -bool true
# defaults write com.apple.universalaccessAuthWarning com.apple.Terminal -bool true

# defaults write com.apple.loginwindow DisableScreenLock -bool true

# defaults write com.apple.loginwindow TALLogoutSavesState -bool false
# EOF


# docker stop metacall-distributable-macos
