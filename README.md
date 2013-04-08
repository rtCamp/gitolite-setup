Gitolite Setup
==============

Gitolite v3 setup scripts for Ubuntu, Debian, CentOS & RHEL

### Installation Guide

```shell
curl -Ls http://rt.cx/gitlab | sudo bash -s GITUSER WEBUSER ACDOMAIN ACLICENSE
```

###DESCRIPTION
**GITUSER:**	The username for gitolite setup, GITUSER must not exist on your system.
	 

**WEBUSER:**	The username who run the php process for your systems, WEBUSER must exist on your system.

**ACDOMAIN:**	The domain name of your activeCollab url without http:// and wwww.

**ACLICENSE:**	ActiveCollab first 5 digit of license key


## Example

```shell
sudo bash install.sh git www-data ac.example.com xaVCf
```

