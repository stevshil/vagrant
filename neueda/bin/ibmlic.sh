#!/bin/bash

# Script to build an IBM Rational License Server

# Documentation
# See https://www-01.ibm.com/support/docview.wss?uid=swg24035648#INSTALL
# https://www.ibm.com/support/knowledgecenter/SSSTWP_8.1.4/com.ibm.rational.license.doc/topics/t_before_install_lic_server_unix.html
# Install http://www-01.ibm.com/support/docview.wss?uid=swg21663924
# http://www-01.ibm.com/support/docview.wss?uid=swg21615142
# https://www.ibm.com/support/knowledgecenter/en/SSSTWP_8.1.4/com.ibm.rational.license.doc/topics/t_install_lic_unix.html

# Install program
yum -y update libgcc
yum -y install unzip libgcc.i686 glibc.i686 redhat-lsb redhat-lsb.i686

if [[ ! -e /vagrant/files/ibm-license/IBM_RLKS_Administration_And_Reporting_Tool_8154.zip ]]
then
	# Add dropbox link
fi

if [[ ! -e /vagrant/files/ibm-license/IBM_RLKS_Administration_And_Reporting_Agent_8154.zip ]]
then
	# Add dropbox link
fi


# Install app
cd /opt
unzip /vagrant/files/ibm-license/IBM_RLKS_Administration_And_Reporting_Tool_8154.zip
