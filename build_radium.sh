#!/bin/bash

set -e 
date
ps axjf
NPROC=$(nproc)
echo "nproc: $NPROC"

#################################################################
# Update Ubuntu and install prerequisites for running Radium #
#################################################################

time apt-get update
time apt-get install -y ntp wget git miniupnpc build-essential libssl-dev libdb++-dev libboost-all-dev libqrencode-dev libtool autotools-dev autoconf pkg-config

#################################################################
# Build config file                                             #
#################################################################

file=$HOME/.Radium
if [ ! -e "$file" ]
then
sudo mkdir $HOME/.Radium
fi

sudo printf 'rpcuser=%s\n' $2  >> $HOME/.Radium/radium.conf
sudo printf 'rpcpassword=%s\n' $3 >> $HOME/.Radium/radium.conf
sudo printf 'rpcport=%s\n' $4 >> $HOME/.Radium/radium.conf
sudo printf 'rpcallowip=%s\n' $5 >> $HOME/.Radium/radium.conf
sudo printf 'server=1' >> $HOME/.Radium/radium.conf


#################################################################
# Git Clone Radium Source                                       #
#################################################################

cd /usr/local
time git clone https://github.com/tm2013/Radium.git
chmod -R 777 /usr/local/Radium/

#################################################################
# Build Radium from source                                      #
#################################################################

cd /usr/local/Radium/src 
make -f makefile.unix USE_UPNP=-
cp /usr/local/Radium/src/radiumd /usr/bin/radiumd

################################################################
# Configure Radium node to auto start at boot       #
#################################################################

printf '%s\n%s\n' '#!/bin/sh' '/usr/bin/radiumd --rpc-endpoint=127.0.0.1:8090 -d /usr/local/Radium/programs/radiumd/'>> /etc/init.d/radium
chmod +x /etc/init.d/radium
update-rc.d radium defaults
/usr/bin/radiumd --rpc-endpoint=127.0.0.1:8090  & exit 0
