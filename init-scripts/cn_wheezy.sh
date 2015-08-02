#!/bin/bash
#
# This helper script will install Debian Wheezy to the container file-system.
#
# Author: narunask
# License: MIT license (MIT).
# Original license can be obtained from: http://opensource.org/licenses/MIT
#

_time0=$(date +%s)

_system='wheezy'

# Container root path
_cnroot=$1

# Source URI
_cnsrc="${2:-http://mirror.bytemark.co.uk/debian}"

# If cnroot hasn't been provided - exit code 1
test -z "${_cnroot}" && { echo error 1; exit 1; }

# If provided but doesn't exist - exit code 2
test -d "${_cnroot}" || { echo error 2; exit 2; }

# Lookup required files and dirs
_mnt=$(find ${_cnroot} -maxdepth 1 -type d -name "mount")
_fs=$(for fs in ext4 ext3; do find ${_cnroot} -maxdepth 1 -type f -name "*.$fs"; done | head -1)

# If either of these files cannot be acquired - exit code 3
test -z "${_mnt}" -o -z "${_fs}" && { echo error 3; exit 3; }

# If container image is not mounted - exit code 4
_fstype=$(egrep -o '[[:alnum:]]+$' <<< "${_fs}")
df -hTP | grep "${_fstype}" | egrep -q "$(readlink -e ${_mnt})" || { echo error 4; exit 4; }

## If all went well then we are ready to install
echo "# Initial checks all seem OK"
echo "# Commencing base system installation:"
echo -e "# debootstrap --include=openssh-server,rsync \"${_system}\" \"${_mnt}\" \"${_cnsrc}\"\n" && sleep 1
debootstrap --include=openssh-server,rsync "${_system}" "${_mnt}" "${_cnsrc}"

echo -e "\n## Configuring network on wheezy..."
echo -e '\nauto eth0' >> "${_mnt}"/etc/network/interfaces
echo 'iface eth0 inet dhcp' >> "${_mnt}"/etc/network/interfaces

echo -e "\n## Updating root password..."
sed -i '1s#.*#root:$6$/kNlNCC1$wmH1E9LGth/sCl2L13q2YBQVL/vtMZrhGEFJ6iFwYPA6B5SoYS/Zk7bA/jE3PvAF8ES6K1VYxK8sICxGf3WAa/:16649:0:99999:7:::#' "${_mnt}"/etc/shadow


echo -e "\n## Creating lxc configuration file..."
read -r -d '' _lx_conf << EOF_lxc_conf
# For additional config options, please look at lxc.container.conf(5)
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.hwaddr = 4a:49:43:49:79:44
lxc.rootfs = $(readlink -e ${_mnt})

# Common configuration
lxc.include = /usr/share/lxc/config/debian.common.conf

# Container specific configuration
lxc.utsname = ubnt
lxc.arch = amd64
lxc.autodev = 1
lxc.kmsg = 0
EOF_lxc_conf

echo "${_lx_conf}" >> ${_cnroot}/lxc.conf


_time1=$(date +%s)
echo -e "\n## Completed in $((_time1 - _time0)) seconds\n"

echo "LXC users - you can start this container with the following commands:"
echo "-> lxc-start -dn ubnt -f ${_cnroot}/lxc.conf"
echo "-> lxc-console -n ubnt"
echo "When prompted - Username: root, password: root"
echo "You can abandon LXC console at any time by pressing CTRL+a+q"
echo "To kill virtual machine: lxc-stop -kn ubnt"
echo
echo "Systemd users - you can start this container with the following commands:"
echo "-> systemd-nspawn -D ${_mnt}"
echo "Press ^] three times within 1s to kill container."
