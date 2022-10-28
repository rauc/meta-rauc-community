#!/bin/bash

#####################################################################################

# Run a yocto image in qemu with network access
#
#This script was create by  Ignacio Nunez Hernanz and Minko Simon re-edit it for 
#Personal use case.
####################################################################################
#
# Copyleft 2017 by Ignacio Nunez Hernanz <nacho _a_t_ ownyourbits _d_o_t_ com>
# GPL licensed (see end of file) * Use at your own risk!
#
# Usage:
#      launch qemu image and create a bridge on host
#####################################################################################
function usage 
{
  echo "[  INFO ] : This script create a virtual NIC and launch qemu yocto image "
  echo "            wit valid parameters"
  exit 1
}

function delete_interface_br0
{
  echo "[  INFO ] : delete interface br0 is already exists"
  sudo ip link delete br0 type bridge
  
}

function create_virtual_nic
{
  echo "[  INFO ] : Start to create a virtual interface network named : dummy0"
  sudo modprobe dummy
  sudo ip link add dummy0 type dummy

  [[ -z $(ip a |grep dummy) ]] && { echo "[ ERROR ] : failed to create virtual network interface";exit 1; }
  echo "[  INFO ] : Set a mac adress to dummy0 network interface (C8:D7:4A:4E:47:50)"
  sudo ifconfig dummy0 hw ether C8:D7:4A:4E:47:50 || { echo "[ ERROR ] : Failed to set MAC adress"; exit 1; }

  echo "[  INFO ] : Set a IP adress to dummy0 network interface (10.0.3.100/24)"
  sudo ip addr add 10.0.3.100/24 brd + dev dummy0 label dummy0:0 
  #sudo ifconfig dummy0 10.0.3.100/24/24

  echo "[  INFO ] : Set a virtual interface network UP (dummy0)"
  sudo ifconfig dummy0 up

}

function delete_virtual_nic
{

  if [[ ! -z $(ip a |grep dummy) ]];then
    echo "[  INFO ] : delete network interface dummy0"
    sudo ip addr del 10.0.3.100/24 brd + dev dummy0 label dummy0:0
    sudo ip link delete dummy0 type dummy
    sudo rmmod dummy
    [ ! -z $(ip a |grep dummy) ] && { echo "[ ERROR ] : failed to delete interface dummy0";exit 1; } 
  else
    echo "[  INFO ] : network interface dummy0 is already deleted"
  fi

}

[[ "$EUID" -ne 0 ]] && { echo "[ ERROR ] : Please run as root";exit 1;}
#[[ -z "$1" ]] && { echo "[ ERROR ] : script $0 no parameters";usage; exit 1;}

delete_virtual_nic
create_virtual_nic



NO_NETWORK=0           # set to 1 to skip network configuration
BRIDGE=br0              # name for the bridge we will create to share network with the raspbian img
MAC='52:54:be:36:42:a9' # comment this line for random MAC (maybe annoying if on DHCP)
BINARY_PATH=/usr/bin    # path prefix for binaries
NO_GRAPHIC=0            # set to 1 to start in no graphic mode


# sanity checks
type qemu-system-arm &>/dev/null || { echo "[ ERROR ] : QEMU ARM not found"       ; exit 1; }


check_IFACE="$( ip r | grep "default via" | awk '{ print $5 }' | grep $BRIDGE )"
[[ ! -z $check_IFACE ]] && delete_interface_br0

IFACE="dummy0"
[[ "$IFACE" == "" ]] || [[ "$BRIDGE" == "" ]] && NO_NETWORK=1

# some more checks
[[ "$NO_NETWORK" != "1" ]] && {
    IP=$( ip address show dev "$IFACE" | grep global | grep -oP '\d{1,3}(.\d{1,3}){3}' | head -1 )
    [[ "$IP" == "" ]]      && { echo "[ ERROR ] : no IP found for $IFACE"; NO_NETWORK=1; exit 1; }
    type brctl &>/dev/null || { echo "[ ERROR ] : brctl is not installed"; NO_NETWORK=1; exit 1;}
    modprobe tun &>/dev/null
    echo "[ INFO ] : IP $IP of Interface ($IFACE)"
    #grep -q tun <(lsmod)   || { echo "need tun module"       ; NO_NETWORK=1; exit 1;}
}

# network configuration
[[ "$NO_NETWORK" != "1" ]] && {
  test -f /etc/qemu-ifup   && cp -nav /etc/qemu-ifup   /etc/qemu-ifup.bak
  test -f /etc/qemu-ifdown && cp -nav /etc/qemu-ifdown /etc/qemu-ifdown.bak

  cat > /etc/qemu-ifup <<EOF
#!/bin/sh
echo "[ INFO ] : Executing /etc/qemu-ifup"
echo "[ INFO ] : Bringing up \$1 for bridged mode..."
sudo ip link set \$1 up promisc on
echo "[ INFO ] : Adding \$1 to $BRIDGE..."
sudo brctl addif $BRIDGE \$1
sleep 2
EOF

  cat > /etc/qemu-ifdown <<EOF
#!/bin/sh
echo "[ INFO ] : Executing /etc/qemu-ifdown"
sudo ip link set \$1 down
sudo brctl delif $BRIDGE \$1
sudo ip link delete dev \$1
EOF

  chmod 750 /etc/qemu-ifdown /etc/qemu-ifup
  chown root:kvm /etc/qemu-ifup /etc/qemu-ifdown

  IPFW=$( sysctl net.ipv4.ip_forward | cut -d= -f2 )
  sysctl net.ipv4.ip_forward=1

  echo "[ INFO ] : IPFW = $IPFW"
  echo "[ INFO ] : Getting routes for interface: $IFACE"
  ROUTES=$( ip route | grep $IFACE )
  echo "[ INFO ] : Changing those routes to bridge interface: $BRIDGE"
  BRROUT=$( echo "$ROUTES" | sed "s=$IFACE=$BRIDGE=" )
  echo "[ INFO ] : Creating new bridge: $BRIDGE"
  brctl addbr $BRIDGE
  echo "[ INFO ] : Adding $IFACE interface to bridge $BRIDGE"
  brctl addif $BRIDGE $IFACE
  echo "[ INFO ] : Setting link up for: $BRIDGE"
  ip link set up dev $BRIDGE
  echo "[ INFO ] : Flusing routes to interface: $IFACE"
  ip route flush dev $IFACE
  echo "[ INFO ] : Adding $IP address to bridge: $BRIDGE"
  ip address add $IP dev $BRIDGE
  echo "[ INFO ] : Adding routes to bridge: $BRIDGE"
  echo "$BRROUT" | tac | while read l; do ip route add $l; done
  echo "[ INFO ] : Routes to bridge $BRIDGE added"

  precreationg=$(ip tuntap list | cut -d: -f1 | sort)
  ip tuntap add user $USER mode tap
  postcreation=$(ip tuntap list | cut -d: -f1 | sort)
  TAPIF=$(comm -13 <(echo "$precreationg") <(echo "$postcreation"))
  [[ "$MAC" == "" ]] && printf -v MAC "52:54:%02x:%02x:%02x:%02x" \
    $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff ))

  NET_ARGS="-net nic,macaddr=$MAC -net tap,ifname=$TAPIF"
}

echo "[ INFO ] : NET_ARGS = $NET_ARGS"


QEMU_MAJOR=$( qemu-system-arm --version | grep -oP '\d+\.\d+\.\d+' | head -1 | cut -d. -f1 )
QEMU_MINOR=$( qemu-system-arm --version | grep -oP '\d+\.\d+\.\d+' | head -1 | cut -d. -f2 )

if [[ $QEMU_MAJOR == 2 ]] && [[ $QEMU_MINOR < 8 ]]; then sed -i '/^[^#].*libarmmem.so/s/^\(.*\)$/#\1/' tmpmnt/etc/ld.so.preload; fi
if [[ $QEMU_MAJOR <  2 ]]                         ; then sed -i '/^[^#].*libarmmem.so/s/^\(.*\)$/#\1/' tmpmnt/etc/ld.so.preload; fi

#umount -l tmpmnt
#rmdir tmpmnt &>/dev/null

PARAMS_KERNEL="root=/dev/sda2 panic=1"
if [[ "$NO_GRAPHIC" == "1" ]]; then
  PARAMS_QEMU="-nographic"
  PARAMS_KERNEL="$PARAMS_KERNEL vga=normal console=ttyAMA0"
fi

#echo "[ INFO ] : qemu-system-arm command : qemu-system-arm -kernel $KERNEL -cpu arm1176 -m 256 -k fr -M versatilepb $NET_ARGS $PARAMS_QEMU -no-reboot -drive format=raw,file=$IMG -append \"$PARAMS_KERNEL\""
echo "[ INFO ] : qemu-system-arm -M vexpress-a9 -m 1024 -kernel u-boot.elf -nographic -sd sd.img $NET_ARGS $PARAMS_QEMU"
# do it
qemu-system-arm -M vexpress-a9 -m 1024 -kernel u-boot.elf -nographic -sd sd.img $NET_ARGS $PARAMS_QEMU

sleep 2

# restore network to what it was
[[ "$NO_NETWORK" != "1" ]] && {
  ip link set down dev $TAPIF
  ip tuntap del $TAPIF mode tap
  sysctl net.ipv4.ip_forward="$IPFW"
  ip link set down dev $BRIDGE
  brctl delbr $BRIDGE
  echo "$ROUTES" | tac | while read l; do ip route add $l; done
}

delete_virtual_nic

# License
#
# This script is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this script; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA

