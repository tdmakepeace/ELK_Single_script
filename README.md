# ELK_Single_script


This is a single script to install the ELK stack, and all it dependencies. 

Based on Ubuntu 20.04, 22.04 or 24.04, but should work on other Ubuntu versions. 

Option B - sets up all the dependencies and installs base services and requires a reboot. \
Option E - Installs the ELK, the logstash passer and dashboards. \
Option U - upgrade and change versions.

Option P - to set up proxy access if in a closed enviroment.


### To run directly off Github run the following command.
```
wget -O ELK_Install_Ubuntu_script.sh  https://raw.githubusercontent.com/tdmakepeace/ELK_Single_script/refs/heads/main/ELK_Install_Ubuntu_script.sh && chmod +x ELK_Install_Ubuntu_script.sh  &&  ./ELK_Install_Ubuntu_script.sh
```

You should re run the command above for script updates as well.


### Run
You need to run the command a few times, once to do the base install. Secondaly to do the install or ELK.
1. Option B - will reboot.
2. Option E - will provide access to the dashboard after the script finishes. 



### OVA option ###
OVA image prebuilt
``` 
https://www.dropbox.com/scl/fi/iwqll9q185gq1lyaskecv/HPELABS_ELK.ova?rlkey=xcal9lt2lnnyrlcvvh3oguiw7&st=04bhdpnw&dl=1
```

OVA image details
``` 
https://www.dropbox.com/scl/fi/5hkg1407qwy0iqbl6ohdd/HPELABS_ELK.txt?rlkey=db0yu22vwtq7qq414park3m0o&st=s6wfxdwq&dl=1 
```
An image has been prebuilt with everything installed and upto date as off the 8th Oct 2024.
The image details link, has the username and password settings.

