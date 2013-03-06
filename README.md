Gitolite Setup
==============

Setup scripts for Gitolite v3 

### Installation Guide

wget https://raw.github.com/rtCamp/gitolite-setup/master/install.sh
sudo bash install.sh GITUSER WEBUSER ACDOMAIN ACLICENSE

###DESCRIPTION

GITUSER:	The username for gitolite setup
		The GITUSER must not exist on your system.
	 

WEBUSER:	The username who run the php process for your systems
		The WEBUSER must exist on your system.

ACDOMAIN:	The domain name of your activeCollab url without http:// and wwww.

ACLICENSE:	ActiveCollab first 5 digit of license key


## Example

sudo bash install.sh git www-data ac.example.com xaVCf

