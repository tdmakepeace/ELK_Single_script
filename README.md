# ELK_Single_script


This is a single script to install the ELK stack, and all it dependencies. 

Based on Ubuntu 22.04 or 24.04, but should work on other Ubuntu versions. 

Option B - sets up all the dependencies and installs base services and requires a reboot. \
Option E - Installs the ELK, the logstash passer and dashboards. This also requires a reboot to start the service on boot up. 
Option U - upgrade and change versions.

Option P - to set up proxy access if in a closed enviroment.


### To run directly off Github run the following command.
```
wget -O ELK_Install_Ubuntu_script.sh  https://raw.githubusercontent.com/tdmakepeace/ELK_Single_script/refs/heads/main/ELK_Install_Ubuntu_script.sh && chmod +x ELK_Install_Ubuntu_script.sh  &&  ./ELK_Install_Ubuntu_script.sh
```

You should re run the command above for script updates as well.
