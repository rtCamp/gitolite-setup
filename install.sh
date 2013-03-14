#!/bin/bash

# @VERSION 1.0
# @AUTHOR  rtCamp Solutions Pvt. Ltd. (admin@rtcamp.com)
#	   Mitesh Shah (mitesh.shah@rtcamp.com)

# This script is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at (http://www.gnu.org/licenses/) for
# more details.



# Variables
BASEPATH=$(dirname $0 )
LOGFILE=/var/log/gitolite.sh.log


# Checking Permissions
Permission=$(id -u)
if [ $Permission -ne 0 ] 
then
        echo
        echo -e "\033[31m Root Privilege Required... \e[0m" #| tee -ai $LOGFILE
        echo -e "\033[31m Usage: sudo bash $0 [git-username] [php-username] \e[0m" #| tee -ai $LOGFILE
        exit 100
fi

# Capture Errors
OwnError()
{
        echo | tee -ai $LOGFILE
        echo -e "[ $0 ][ `date` ] \033[31m $@ \e[0m" | tee -ai $LOGFILE
        exit 101 
}

# Makes Log File Easy To Read
echo &>> $LOGFILE
echo &>> $LOGFILE
echo &>> $LOGFILE
echo -e "\033[34m Gitolite Admin Installation Started At `date` \e[0m" | tee -ai $LOGFILE

# Detect Linux Distro
KERNEL=`uname -s`
KERNELRELEASE=`uname -r`


if [ "$KERNEL" = "Linux" ]
then
	if [ -f /etc/centos-release ]
	then
		LINUXDISTRO=CentOS

	elif [ -f /etc/redhat-release ]
	then
		LINUXDISTRO=RedHat


	elif [ -f /etc/lsb-release ]
	then
		LINUXDISTRO=Ubuntu

	elif [ -f  /etc/debian_version ]
	then
		LINUXDISTRO=Debian

	else
        	echo | tee -ai $LOGFILE
	       	echo -e "\033[31m Currently This Script Supports Only \
		CentOS, Redhat, Ubuntu and Debian Linux Distro \e[0m"
       		exit 200
	fi
fi

if [ "$LINUXDISTRO" = "Debian" ] || [ "$LINUXDISTRO" = "Ubuntu" ]
then
        echo | tee -ai $LOGFILE
        echo -e "\033[34m $LINUXDISTRO Detected... \e[0m" | tee -ai $LOGFILE

	# Checking Installed Packages
	dpkg --list | grep openssh-server &>> $LOGFILE
	OPENSSH=$(echo $?)
	dpkg --list | grep git-core &>> $LOGFILE
	GITCORE=$(echo $?)
	dpkg --list | grep curl &>> $LOGFILE
	CURL=$(echo $?)
	dpkg --list | grep sudo &>> $LOGFILE
	SUDO=$(echo $?)

	echo Checking Installed Packages = $GITCORE $OPENSSH $CURL $SUDO &>> $LOGFILE


	# Install Git, Curl & Open SSH If It Not Installed
	if [ $OPENSSH -ne 0 ] || [ $GITCORE -ne 0 ] || [ $CURL -ne 0 ] || [ $SUDO -ne 0 ]
	then
		# Update Cache
		echo -e "\033[34m Updating APT Cache... \e[0m" | tee -ai $LOGFILE
		apt-get update || OwnError "Unable To Update APT Cache"

		# Install Open SSH Server And Git
		echo -e "\033[34m Installing Open SSH Server, Git and Curl... \e[0m"
		apt-get -y install openssh-server git-core curl sudo &>> $LOGFILE \
		|| OwnError "Unable To Install Open SSH Server, Git, Curl And Sudo "
	fi
elif [ "$LINUXDISTRO" = "RedHat" ] || [ "$LINUXDISTRO" = "CentOS" ] 
then
        echo | tee -ai $LOGFILE
        echo -e "\033[34m $LINUXDISTRO Detected... \e[0m" | tee -ai $LOGFILE

	# Checking Installed Packages
	rpm -qa | grep openssh-server &>> $LOGFILE
	OPENSSH=$(echo $?)
	rpm -qa | grep git-core &>> $LOGFILE
	GITCORE=$(echo $?)
	rpm -qa | grep curl &>> $LOGFILE
	CURL=$(echo $?)
	rpm -qa | grep perl-Time-HiRes &>> $LOGFILE
	PERL=$(echo $?)
	echo Checking Installed Packages = $GITCORE $OPENSSH $CURL $PERL &>> $LOGFILE


	# Install Git, Curl & Open SSH If It Not Installed
	if [ $OPENSSH -ne 0 ] || [ $GITCORE -ne 0 ] || [ $CURL -ne 0 ] || [ $PERL -ne 0 ]
	then
		# Install Open SSH Server And Git
		echo -e "\033[34m Installing Open SSH Server, Git and Curl... \e[0m"
		yum -y install openssh-server git-core curl perl-Time-HiRes &>> $LOGFILE \
		|| OwnError "Unable To Install Open SSH Server, Git, Curl And perl-Time-HiRes"
	fi
fi





# Ask User If Script Run Withour ARGS
if [ $# -lt 1 ]
then
	echo -e "\033[34m An User Account Will Be Created For Gitolite Admin Setup... \e[0m" \
	| tee -ai $LOGFILE
	read -p "Enter The Username [git]: " GITUSER

	# Enter Then Used Default Git
	if [[ $GITUSER = "" ]]
	then
		GITUSER=git 
		echo GITUSER = $GITUSER &>> $LOGFILE
	fi

else            
	GITUSER=$1
	echo GITUSER = $GITUSER &>> $LOGFILE
fi

# Check Passwd File For Exsiting User        
grep ^$GITUSER: /etc/passwd &>> $LOGFILE
if [ $? -eq 0 ]
then
	echo -e "\033[31m The $GITUSER User Already Exists !! \e[0m" | tee -ai $LOGFILE
	echo -e "\033[31m Please Select A Different Username !! \e[0m" | tee -ai $LOGFILE
        exit 102
fi

# Create Git User
if [ "$LINUXDISTRO" = "Debian" ] || [ "$LINUXDISTRO" = "Ubuntu" ]
then
	echo -e "\033[34m Creating $LINUXDISTRO System User [$GITUSER]  \e[0m" | tee -ai $LOGFILE
	sudo adduser --system --home /home/$GITUSER --shell /bin/bash --group \
	--disabled-login --disabled-password --gecos 'git version control' $GITUSER &>> $LOGFILE \
	|| OwnError "Unable To Create $GITUSER"
elif [ "$LINUXDISTRO" = "RedHat" ] || [ "$LINUXDISTRO" = "CentOS" ]
then
	echo -e "\033[34m Creating $LINUXDISTRO System User [$GITUSER]  \e[0m" | tee -ai $LOGFILE
	sudo adduser --home /home/$GITUSER --create-home --shell /bin/bash \
	-c 'git version control' $GITUSER

	# Redhat Is More Secure Than Debian and Ubuntu
	# So Need To Set Read & Execute Permission For Groups/Others
	sudo chmod 750 /home/$GITUSER
fi

# Copy Skeleton Contents
echo -e "\033[34m Copying System Files...  \e[0m" | tee -ai $LOGFILE
sudo -H -u $GITUSER cp /etc/skel/.profile /etc/skel/.bash_profile /etc/skel/.bashrc /etc/skel/.bash_logout /home/$GITUSER/ 2> /dev/null

# Create a bin Directory For Git User
echo -e "\033[34m Creating bin Directory \e[0m" | tee -ai $LOGFILE
sudo -H -u $GITUSER mkdir /home/$GITUSER/bin || OwnError "Unable To Create bin Directory"




# Create a setup Directory For Gitolite Repository
echo -e "\033[34m Creating setup Directory \e[0m" | tee -ai $LOGFILE
sudo -H -u $GITUSER mkdir /home/$GITUSER/setup \
|| OwnError "Unable To Create setup Directory"

cd /home/$GITUSER/setup || OwnError " Unable To Change Directory"

echo | tee -ai $LOGFILE
echo -e "\033[34m Cloning Gitolite Server Repository... \e[0m" | tee -ai $LOGFILE
sudo -H -u $GITUSER git clone git://github.com/sitaramc/gitolite  &>> $LOGFILE \
|| OwnError "Unable to clone gitolote repository"

# Create a Symbolic Link For Gitolite in /home/git/bin Directory
echo -e "\033[34m Creating Gitolite Symbolic Link  \e[0m" | tee -ai $LOGFILE
sudo -H -u $GITUSER gitolite/install -to /home/$GITUSER/bin \
|| OwnError "Unable To Create Symbolic Link For Gitolite"




# Ask User If Script Run Withour ARGS
if [ $# -lt 2 ]
then
	echo -e "\033[34m PHP Username Is Given At Gitolite Settings [Need Help Section] \e[0m" \
	| tee -ai $LOGFILE
	read -p " Enter The PHP Username [www-data]:  " WEBUSER

	if [[ $WEBUSER = "" ]]
	then
		WEBUSER=www-data
		echo WEBUSER = $WEBUSER &>> $LOGFILE
	fi
else
	WEBUSER=$2
	echo WEBUSER = $WEBUSER &>> $LOGFILE
fi


# Add Web User to Git Group
echo -e "\033[34m Adding $WEBUSER to $GITUSER Group  \e[0m" | tee -ai $LOGFILE
if [ "$LINUXDISTRO" = "Debian" ] || [ "$LINUXDISTRO" = "Ubuntu" ]
then
	sudo adduser $WEBUSER $GITUSER &>> $LOGFILE
elif [ "$LINUXDISTRO" = "RedHat" ] || [ "$LINUXDISTRO" = "CentOS" ]
then
	sudo usermod -a -G $GITUSER $WEBUSER
fi

# Get The Web User Home Dir Path
WEBUSERHOME=$(grep $WEBUSER: /etc/passwd | cut -d':' -f6 | head -n1)
echo WEBUSERHOME = $WEBUSERHOME &>> $LOGFILE
if [ -z $WEBUSERHOME ]
then
	echo | tee -ai $LOGFILE
	echo -e "\033[31m Unable To Detect $WEBUSER Home Directory !! \e[0m" | tee -ai $LOGFILE
	read -p "Enter The Home Directory Path For [$WEBUSER]: " WEBUSERHOME
fi

# Checks .ssh Directory Exist
ls $WEBUSERHOME/.ssh &>> tee -ai $LOGFILE
if [ $? -ne 0 ]
then
	echo -e "\033[34m Creating .ssh Directory \e[0m" | tee -ai $LOGFILE
	sudo mkdir -p $WEBUSERHOME/.ssh || OwnError "Unable To Create $WEBUSERHOME/.ssh"
	sudo chown -R $WEBUSER:$WEBUSER $WEBUSERHOME/.ssh \
	|| OwnError "Unable To Change Ownership (chown) .ssh"
fi

# Checks Weather id_rsa Key Exist
sudo ls  $WEBUSERHOME/.ssh/id_rsa &>> $LOGFILE
if [ $? -eq 0 ]
then
	echo -e "\033[34m The SSH Key id_rsa Already Exists \e[0m" | tee -ai $LOGFILE
else

	# Generate SSH Keys For Web User
	echo -e "\033[34m Generating SSH Keys For $WEBUSER \e[0m" | tee -ai $LOGFILE
	sudo -H -u $WEBUSER ssh-keygen -q -N '' -f $WEBUSERHOME/.ssh/id_rsa \
	|| OwnError "Unable To Create SSH Keys For $WEBUSER"
fi


# Create known_hosts file if not exist
# Or if known_hosts exist update timestamp 
sudo touch $WEBUSERHOME/.ssh/known_hosts || OwnError "Unable To Create known_hosts"

# Give 666 Permission To Add SSH Server Fingerprint
sudo chmod 666 $WEBUSERHOME/.ssh/known_hosts || OwnError "Unable To chmod 666 known_hosts"

# Use Wildcard For Match All The Domains
sudo echo -n "* " >> $WEBUSERHOME/.ssh/known_hosts \
|| OwnError "Unable To Add wildcard As Server-name"

# Copy The SSH Server Fingerprint
cat /etc/ssh/ssh_host_rsa_key.pub >> $WEBUSERHOME/.ssh/known_hosts \
|| OwnError "Unable To Add SSH Server Fingerprint"


# Give Back 644 Permission To Add SSH Server Fingerprint
sudo chmod 644 $WEBUSERHOME/.ssh/known_hosts || OwnError "Unable To chmod 644 known_hosts"
sudo chown $WEBUSER:$WEBUSER $WEBUSERHOME/.ssh/known_hosts \
|| OwnError "Unable To Chnage Ownership (chown) known_hosts"


# Setup Gitolite Admin
echo | tee -ai $LOGFILE
echo -e "\033[34m Setup Gitolite Admin...  \e[0m" | tee -ai $LOGFILE

sudo cp $WEBUSERHOME/.ssh/id_rsa.pub /home/$GITUSER/$WEBUSER.pub \
|| OwnError "Unable To Copy $WEBUSER Pubkey"
	
sudo chown $GITUSER:$GITUSER /home/$GITUSER/$WEBUSER.pub \
|| OwnError "Unable To Change Ownership Of $WEBUSER"

cd /home/$GITUSER

sudo -H -u $GITUSER /home/$GITUSER/bin/gitolite setup -pk $WEBUSER.pub &>> $LOGFILE \
|| OwnError "Unable To Setup Gitolite Admin (Key)"

# Change UMASK Value
echo -e "\033[34m Changing UMASK Value  \e[0m" | tee -ai $LOGFILE
sudo -H -u $GITUSER sed -i 's/0077/0007/g' /home/$GITUSER/.gitolite.rc \
|| OwnError "Unable To Change UMASK"


# Installing Post Receive Hooks
echo -e "\033[34m Creating post-receive Hooks \e[0m" | tee -ai $LOGFILE
cd $BASEPATH

cd ../../../public/ 2> /dev/null 2> /dev/null #|| OwnError "Unable To Change Directory For Hookspath"
if [ -f .hookspath.rt ]
then
	HOOKSPATH=$(cat .hookspath.rt)
       	echo HOOKSPATH = $HOOKSPATH &>> $LOGFILE

	CURLPATH=$(whereis curl | cut -d' ' -f2)

	sudo -H -u $GITUSER echo "$CURLPATH -s -L \"$HOOKSPATH\" > /dev/null " \
	&>> /home/$GITUSER/.gitolite/hooks/common/post-receive

	sudo chmod a+x /home/$GITUSER/.gitolite/hooks/common/post-receive
	sudo chown $GITUSER:$GITUSER /home/$GITUSER/.gitolite/hooks/common/post-receive
	sudo -H -u $GITUSER /home/$GITUSER/bin/gitolite setup --hooks-only
else
	if [ $# -lt 3 ]
	then
		echo -e "\033[34m Enter Your AC Domain Name: \e[0m"
		read -p " Enter The AC Domain Name: " DOMAIN
		ACDOMAIN=$(echo $DOMAIN | sed "s'http://''" | sed "s'www.''")
		echo "ActiveCollab Domain Name = $ACDOMAIN" &>> $LOGFILE
	else
		DOMAIN=$3
		ACDOMAIN=$(echo $DOMAIN | sed "s'http://''" | sed "s'www.''")
		echo "ActiveCollab Domain Name = $ACDOMAIN" &>> $LOGFILE
	fi
			

	if [ $# -lt 4 ]
	then
		echo -e "\033[34m Enter Your Active Collab First Five Letter Of License Key: \e[0m"
		read -p " Enter Your Active Collab First Five Letter Of License Key: " LICENSE
		ACLICENSE=$(echo -n $LICENSE | cut -c1-5)
		echo "ActiveCollab License Code = $ACLICENSE" &>> $LOGFILE
	else
		LICENSE=$4
		ACLICENSE=$(echo -n $LICENSE | cut -c1-5)
		echo "ActiveCollab License Code = $ACLICENSE" &>> $LOGFILE
		
	fi

	HOOKSPATH=$(echo "http://$ACDOMAIN/public/index.php?path_info=frequently&code=$ACLICENSE")
       	echo HOOKSPATH = $HOOKSPATH &>> $LOGFILE

	CURLPATH=$(whereis curl | cut -d' ' -f2)

	sudo -H -u $GITUSER echo "$CURLPATH -s -L \"$HOOKSPATH\" > /dev/null " \
	&>> /home/$GITUSER/.gitolite/hooks/common/post-receive

	sudo chmod a+x /home/$GITUSER/.gitolite/hooks/common/post-receive
	sudo chown $GITUSER:$GITUSER /home/$GITUSER/.gitolite/hooks/common/post-receive
	sudo -H -u $GITUSER /home/$GITUSER/bin/gitolite setup --hooks-only

	#echo | tee -ai $LOGFILE
	#echo -e "\033[31m Can't create post-receive Hooks !!  \e[0m" | tee -ai $LOGFILE
	#echo
fi


# Log Messages
echo | tee -ai $LOGFILE
echo -e "\033[34m For Detailed Installation Messages Use The Following Command \e[0m" \
| tee -ai $LOGFILE
echo -e "\033[34m cat $LOGFILE \e[0m" | tee -ai $LOGFILE

echo
echo -e "\033[34m Gitolite Admin Is Successfully Installed On `date` \e[0m" | tee -ai $LOGFILE
echo -e "\033[34m Please Go Back To Gitolite Admin, Test Connection And Save Settings. \e[0m" \
| tee -ai $LOGFILE


