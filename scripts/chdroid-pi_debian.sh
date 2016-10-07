#!/bin/bash

DEBVERSION=testing


/debootstrap/debootstrap --second-stage
echo "
deb http://ftp.debian.org/debian $DEBVERSION main contrib non-free
deb http://ftp.debian.org/debian $DEBVERSION-updates main contrib non-free
deb http://security.debian.org/  $DEBVERSION/updates main contrib non-free
deb ftp://ftp.deb-multimedia.org $DEBVERSION main non-free
" > etc/apt/sources.list
apt-get update
apt-get install -y --force-yes deb-multimedia-keyring
apt-get update

apt-get upgrade -y
apt-get install -y $ALLPACKAGE

dpkg-reconfigure tzdata



#apt-get install aptitude tasksel
# aptitude install ~t^desktop$ ~t^kde-desktop$
#apt-get  --no-install-recommends install -y $ALLPACKAGE