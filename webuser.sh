#!/bin/bash



WEBSERVER=$(curl -I localhost | grep -i server | cut -d':' -f2 | cut -d'/' -f1 | cut -d' ' -f2)
echo Webserver = $WEBSERVER
if [ ! -z $WEBSERVER ]
then

	if [ $WEBSERVER == nginx ] || [ $WEBSERVER == Nginx ] || [ $WEBSERVER == NGINX ]
	then
		echo -e "\033[34m $WEBSERVER Detected  \e[0m"
		for i in `locate nginx.conf`
		do
			echo -e "\033[34m Processing $i \e[0m"
			grep user $i >> /tmp/a80863deadcfe1161ab0d9ef7aba81c9
		done

		echo
		echo -e "\033[34m List Of Users: \e[0m"
		cat /tmp/a80863deadcfe1161ab0d9ef7aba81c9 | sort | uniq

	elif [ $WEBSERVER == apache ] || [ $WEBSERVER == Apache ] || [ $WEBSERVER == APACHE ]
	then
		echo -e "\033[34m $WEBSERVER Detected  \e[0m"
		for i in `locate httpd.conf`
		do
			echo -e "\033[34m Processing $i \e[0m"
			grep user $i >> /tmp/a80863deadcfe1161ab0d9ef7aba81c9
		done

		echo
		echo -e "\033[34m List Of Users: \e[0m"
		cat /tmp/a80863deadcfe1161ab0d9ef7aba81c9 | sort | uniq
	else
		echo -e "\033[31m Script Only Support For Apache & Nginx Servers \e[0m"
	fi

else
	echo -e "\033[31m WebServer Not Running \e[0m"
	echo -e "\033[31m Start Webserver By Running Following Commands \e[0m"
	echo -e "\033[31m sudo /etc/init.d/nginx restart \e[0m"
	echo -e "\033[31m sudo /etc/init.d/httpd restart \e[0m"
	echo -e "\033[31m sudo /etc/init.d/apache2 restart \e[0m"
	
fi
