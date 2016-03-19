#!/bin/bash

set -e 

date
ps axjf

#################################################################
# Update Ubuntu and install prerequisites for running Radium #
#################################################################
time apt-get update
time apt-get install -y ntp wget git miniupnpc build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libtool autotools-dev autoconf pkg-config


#################################################################
# Build Radium from source                                   #
#################################################################
NPROC=$(nproc)
echo "nproc: $NPROC"
#################################################################
# Install all necessary packages for building Radium         #
#################################################################

echo "lib install done"
rm -rf /usr/local/Radium
echo "remove done" 
cd /usr/local
time git clone https://github.com/tm2013/Radium.git
echo "clone done"
chmod -R 777 /usr/local/Radium/
echo "starting make"
cd /usr/local/Radium/src 
make -f makefile.unix USE_UPNP=-
 cp /usr/local/Radium/src/Radiumd /usr/bin/Radiumd

################################################################
# Configure BitShares witeness node to auto start at boot       #
#################################################################
sudo printf '%s\n%s\n' '#!/bin/sh' '/usr/bin/Radiumd --rpc-endpoint=127.0.0.1:8090 -d /usr/local/Radium/programs/radiumd/'>> /etc/init.d/radium

chmod +x /etc/init.d/radium
update-rc.d radium defaults

/usr/bin/radiumd --rpc-endpoint=127.0.0.1:8090 -d /usr/local/Radium/programs/radiumd/ & exit 0
