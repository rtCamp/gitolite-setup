#!/bin/bash
rsync webuser.sh root@192.168.0.201:. 
echo $?
rsync webuser.sh root@192.168.0.202:.
echo $?
rsync webuser.sh root@192.168.0.203:.
echo $?
