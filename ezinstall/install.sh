#!/bin/bash

source /etc/os-release
if [[ $PRETTY_NAME =~ *"Fedora"* ]]; then
	echo "This script is for Fedora only."
	echo "No other distro is supported. You will have to adapt packages and commands for your distro."
	exit 1
fi

if [ ! -d "./.git" ]; then
	echo ".git folder is not present. This is not a git repo, and could contain other files (I don't wanna check)."
	echo "Please confirm you are in the directory you want to be ($PWD)"
	read -p "Continue? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi

if [ ! -d "qemu" ] || [ ! -d "seabios" ]; then
	echo "Cloning Missing Upstream Repos..."
fi

if [ ! -d "qemu" ]; then
	echo "Cloning qemu..."
	git clone https://github.com/qemu/qemu.git
	cd qemu
	git reset --hard 87b9ae38d045b0228accf1135f2696fc274f07af
	mv .git .git.original
	cd ..
fi; if [ ! -d "seabios" ]; then
	echo "Cloning Seabios"
	git clone https://git.seabios.org/seabios.git
	cd seabios
	git reset --hard ec0bc256ae0ea08a32d3e854e329cfbc141f07ad
	mv .git .git.original
	cd ..
fi

read -p "Append .gitignore? (y/n): " appendgi
if [[ $appendgi == [yY] || $appendgi == [yY][eE][sS] ]]; then
	echo "Bringing down .gitignore files from upstream repos..."
	awk '{print "qemu/" $0}' qemu/.gitignore >> .gitignore
	echo >> .gitignore
	awk '{print "seabios/" $0}' seabios/.gitignore >> .gitignore
	sed -i -e s,//,/,g .gitignore # Fixes double slashes in .gitignore from qemu's .gitignore starting with /
fi

read -p "Install packages? (y/n): " installpkgs
if [[ $installpkgs == [yY] || $installpkgs == [yY][eE][sS] ]]; then
	sudo dnf install python3-pip -y

	pip3 install sphinx
	pip3 install sphinx_rtd_theme
	pip3 install Ninja

	sudo dnf install git glib2-devel libfdt-devel pixman-devel zlib-devel bzip2 ninja-build python3 \
		libaio-devel libcap-ng-devel libiscsi-devel capstone-devel \
		gtk3-devel SDL2-devel vte291-devel ncurses-devel \
		libseccomp-devel nettle-devel libattr-devel libjpeg-devel \
		brlapi-devel libgcrypt-devel lzo-devel snappy-devel \
		librdmacm-devel libibverbs-devel cyrus-sasl-devel libpng-devel \
		libuuid-devel pulseaudio-libs-devel curl-devel libssh-devel \
		systemtap-sdt-devel libusbx-devel \
		dtc indent fuse3 libbpf libslirp-devel libslirp \
		flex bison -y
fi

echo "Done."
