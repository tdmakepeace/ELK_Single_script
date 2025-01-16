#!/bin/bash

###
### This script has been build to install and configure the ELK stack on a default Ubuntu 22.04/24.04 servers install.
### The only packages needing to be installed as part of the deployment of the Ubuntu servers is openSSH.
###
### you can do a minimun install, but i would just stick with the servers install.
###
### Also it is recommended that you run a static-IP configuration, with a single or dual network interface.
### The script should be run as the first user create as part of the install, and uses SUDO for the deployment process.


### wget -O ELK_Install_Ubuntu_script.sh  https://raw.githubusercontent.com/tdmakepeace/ELK_Single_script/refs/heads/main/ELK_Install_Ubuntu_script.sh && chmod +x ELK_Install_Ubuntu_script.sh  &&  ./ELK_Install_Ubuntu_script.sh


###	

ELK="TAG=8.16.1"
gitlocation="https://github.com/amd/pensando-elk.git"
basefolder="pensando-elk"
rootfolder="pensandotools"

###
	
rebootserver()
{
		echo "rebooting"
		
		sleep 5
		sudo reboot
		break
}

updates()
{
		
		sudo apt-get update 
		sudo NEEDRESTART_SUSPEND=1 apt-get dist-upgrade --yes 

		sleep 10
}

updatesred()
{
		subscription-manager attach --auto
		subscription-manager repos
		sudo yum update -y -q 

		sleep 10
}


basenote()
{
		## Update all the base image of Ubuntu before we progress. 
		## then installs all the dependencies and sets up the permissions for Docker
		clear
		echo " This script will run unattended for 5-10 minutes to do the 
base setup of the server enviroment ready for the Elastic stack. 
It might appear to have paused, but leave it until the host reboots.

It is recommended to be a static IP configuration.

Press Cntl-C to exit if you need to set static IP.

	"
		read -p "Press enter to continue"


	}

elknote()
{
				## Update all the base image of Ubuntu before we progress. 
		
		echo " This script will require some input for the first 2 minutes, and then run unattended for 5-10 minutes to do the 
ELK setup of the enviroment.

It might appear to have paused, but leave it until to complete.

	"
		read -p "Press enter to continue"
	
	
}

dockerupnote()
{

		clear
		echo "					
					Access the UI - https://$localip:5601'
					
					If the server is rebooted allow 5 minutes for all the service to come up
					before you attemp to access the Kibana dashboards. 
					
					"
		read -p "Services setup. any key to continue"
		exit 0	
}

base()
	{
		real_user=$(whoami)


		os=`more /etc/os-release |grep PRETTY_NAME | cut -d  \" -f2 | cut -d " " -f1`
		if [ "$os" == "Ubuntu" ]; then 
				updates
				cd /
				sudo mkdir $rootfolder
				sudo chown $real_user:$real_user $rootfolder
				sudo chmod 777 $rootfolder
				mkdir -p /$rootfolder/
				mkdir -p /$rootfolder/scripts
				sudo mkdir -p /etc/apt/keyrings

				sudo  NEEDRESTART_SUSPEND=1 apt-get install curl gnupg ca-certificates lsb-release --yes 
				sudo mkdir -p /etc/apt/keyrings
				curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg  
				
				sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
				sudo apt-get update --allow-insecure-repositories
				sudo NEEDRESTART_SUSPEND=1 apt-get dist-upgrade --yes 
				
				version=` more /etc/os-release |grep VERSION_ID | cut -d \" -f 2`
				if  [ "$version" == "24.04" ]; then
		# Ubuntu 24.04
					sudo NEEDRESTART_SUSPEND=1 apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin python3.12-venv tmux python3-pip python3-venv --yes 

		  	elif [ "$version" == "22.04" ]; then
		# Ubuntu 22.04
					sudo NEEDRESTART_SUSPEND=1 apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin python3.11-venv tmux python3-pip python3-venv --yes 
		  	elif [ "$version" == "20.04" ]; then
		# Ubuntu 20.04
					sudo NEEDRESTART_SUSPEND=1 apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin python3.9-venv tmux python3-pip python3-venv --yes 
		   	else
		  		sudo NEEDRESTART_SUSPEND=1 apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin python3.8-venv tmux python3-pip python3-venv --yes 
		   	fi

				sudo usermod -aG docker $real_user
		
		elif [ "$os" == "Red" ]; then
			
					echo " still to be written 	"
				cd /
				sudo mkdir $rootfolder
				sudo chown $real_user:$real_user $rootfolder
				sudo chmod 777 $rootfolder
				mkdir -p /$rootfolder/
				mkdir -p /$rootfolder/scripts
				sudo dnf -y install dnf-plugins-core
				sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
				sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
				sudo systemctl enable --now docker
				sudo yum install -y git
				sudo usermod -aG docker $real_user
				
		fi 
		
		}




elk()
	{
		
		cd /$rootfolder/
		git clone $gitlocation
		
		cd /$rootfolder/$basefolder
		clear 
		`git branch --all | cut -d "/" -f3 > gitversion.txt`
		echo "choose a branch "
		git branch --all | cut -d "/" -f3 |grep -n ''

		echo " Select the line number

		"
		read x
		elkver=`sed "$x,1!d" gitversion.txt`
		#				   echo $elkver
		git checkout  $elkver
		echo $elkver >installedversion.txt
				
		cp docker-compose.yml docker-compose.yml.orig
		sed -i.bak  's/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''false'\''/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''true'\''/' docker-compose.yml
		localip=`hostname -I | cut -d " " -f1`

		sed -i.bak -r "s/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: '$localip:9200'/" docker-compose.yml
		sed -i.bak -r "s/#EF_OUTPUT_ELASTICSEARCH_INDEX_PERIOD: 'daily'/EF_OUTPUT_ELASTICSEARCH_INDEX_PERIOD: 'daily'/" docker-compose.yml

		echo "Do you want to install a Elastiflow licence.
  	
  	Yes (y) and No (n) "
		echo "y or n "
		read x
	  
	  clear

  	if  [ "$x" == "y" ]; then
				echo "Paste the AccountID:
				
		        "
			  read a
			echo "Paste the licence key:
				
		        "
			  read b
			
		
		sed -i.bak -r "s/#EF_ACCOUNT_ID: ''/EF_ACCOUNT_ID: '$a'/" docker-compose.yml
		sed -i.bak -r "s/#EF_FLOW_LICENSE_KEY: ''/EF_FLOW_LICENSE_KEY: '$b'/" docker-compose.yml
		

  	else
    	echo "Continue"
  	fi
  			
	echo " Just to show you the changes we have made to the docker compose files
	 Was:
	 EF_OUTPUT_ELASTICSEARCH_ENABLE: 'false'
	 EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'
	 
	 Now:
	 "
				
		more docker-compose.yml |egrep -i 'EF_OUTPUT_ELASTICSEARCH_ENABLE|EF_OUTPUT_ELASTICSEARCH_ADDRESSES|EF_ACCOUNT_ID|EF_FLOW_LICENSE_KEY'
		read -p "Press enter to continue"
		
		echo " 
		
Go and make a cup of Tea
This is going to take time to install and setup
					
					
					"
					
		cd /$rootfolder/$basefolder/
		echo $ELK >.env
		mkdir -p data/es_backups
		mkdir -p data/pensando_es
		mkdir -p data/elastiflow
		chmod -R 777 ./data
		sudo sysctl -w vm.max_map_count=262144
		echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf 
	
#call next part.
	# dockerup	
	
}

dockerdown()
{
			cd /$rootfolder/$basefolder/
			docker compose down
			
}

dockerup()
{		
		cd /$rootfolder/$basefolder/
		echo "					
				
Services setting up please wait
5%
					"
					
		sleep 10 
				
		docker compose up --detach
		
		echo "					
		
Services setting up please wait
15%

-- This is a 100 second delay for the services to start before we import the config - Please wait
					"
		installedversion=`more installedversion.txt`
		
		if [ "$installedversion" == "aoscx_10.13" ]; then 
				
				sleep 100
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog?pretty' -d @./elasticsearch/pensando_fwlog_mapping.json

				echo "					
		Services setting up please wait
		70%
							"
									
				sleep 10
				pensandodash=`ls -t ./kibana/pen* | head -1`
				elastiflowdash=`ls -t  ./kibana/kib* | head -1`
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$pensandodash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$elastiflowdash
				
				
		elif [ "$installedversion" == "aoscx_10.13.1000" ]; then 
				
				sleep 100
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog?pretty' -d @./elasticsearch/pensando_fwlog_mapping.json

				echo "					
		Services setting up please wait
		70%
							"
									
				sleep 10
				pensandodash=`ls -t ./kibana/pen* | head -1`
				elastiflowdash=`ls -t  ./kibana/kib* | head -1`
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$pensandodash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$elastiflowdash
				
		elif [ "$installedversion" == "aoscx_10.14" ]; then 
				
				sleep 100
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog?pretty' -d @./elasticsearch/pensando_fwlog_mapping.json
				echo "					
		Services setting up please wait
		70%
							"
									
				sleep 10
				pensandodash=`ls -t ./kibana/pen* | head -1`
				elastiflowdash=`ls -t  ./kibana/kib* | head -1`
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$pensandodash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$elastiflowdash
				
				
		elif [ "$installedversion" == "aoscx_10.14.0001" ]; then 
				
				sleep 100
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog?pretty' -d @./elasticsearch/pensando_fwlog_mapping.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_snapshot/my_fs_backup' -d @./elasticsearch/pensando_fs.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_slm/policy/pensando' -d @./elasticsearch/pensando_slm.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando' -d @./elasticsearch/pensando_ilm.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_slm/policy/elastiflow' -d @./elasticsearch/elastiflow_slm.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/elastiflow' -d @./elasticsearch/elastiflow_ilm.json
				echo "					
		Services setting up please wait
		70%
							"
									
				sleep 10
				pensandodash=`ls -t ./kibana/pen* | head -1`
				elastiflowdash=`ls -t  ./kibana/kib* | head -1`
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$pensandodash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$elastiflowdash

		elif [ "$installedversion" == "aoscx_10.15" ]; then 
				
				sleep 100
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog?pretty' -d @./elasticsearch/pensando_fwlog_mapping.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_snapshot/my_fs_backup' -d @./elasticsearch/pensando_fs.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_slm/policy/pensando' -d @./elasticsearch/pensando_slm.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando' -d @./elasticsearch/pensando_ilm.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_slm/policy/elastiflow' -d @./elasticsearch/elastiflow_slm.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/elastiflow' -d @./elasticsearch/elastiflow_ilm.json
				echo "					
		Services setting up please wait
		70%
							"
									
				sleep 10
				pensandodash=`ls -t ./kibana/pen* | head -1`
				elastiflowdash=`ls -t  ./kibana/kib* | head -1`
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$pensandodash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$elastiflowdash
				
		elif [ "$installedversion" == "aoscx_10.15.0001" ]; then 
			
				sleep 100
				curl -X DELETE "localhost:9200/_index_template/pensando-fwlog"
				curl -X DELETE 'http://localhost:9200/_slm/policy/pensando'
				curl -X DELETE'http://localhost:9200/_ilm/policy/pensando' 
				curl -X DELETE 'http://localhost:9200/_slm/policy/elastiflow'
				curl -X DELETE 'http://localhost:9200/_ilm/policy/elastiflow'
				
				
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando_empty_delete' -d @./elasticsearch/policy/pensando_empty_delete.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando_allow_create' -d @./elasticsearch/policy/pensando_allow_create.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando_allow_delete' -d @./elasticsearch/policy/pensando_allow_delete.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando_deny_create' -d @./elasticsearch/policy/pensando_deny_create.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/elastiflow_maintenance' -d @./elasticsearch/policy/elastiflow_maintenance.json
				
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog-empty-delete?pretty' -d @./elasticsearch/template/pensando-fwlog-empty-delete.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog-allow-create?pretty' -d @./elasticsearch/template/pensando-fwlog-allow-create.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog-allow-delete?pretty' -d @./elasticsearch/template/pensando-fwlog-allow-delete.json
				curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog-deny-create?pretty' -d @./elasticsearch/template/pensando-fwlog-deny-create.json
				
				
				

				echo "					
		Services setting up please wait
		70%
							"
									
				sleep 10
				pensandodash=`ls -t ./kibana/pen* | head -1`
				elastiflowdash=`ls -t  ./kibana/kib* | head -1`
				fragdash=ls -t  ./kibana/Frag* | head -1`
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$pensandodash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$elastiflowdash
				curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@$fragdash
				
			


		fi 
		
		
		echo "					
Services setting up please wait
80%
					"

		sleep 20	


}

proxy()
	{
		echo " Do you require proxy config for:
			Authenticated (a) or No Auth (n)
			"
		read p
		clear

  	if  [ "$p" == "a" ]; then
  	 	echo " Paste your proxy configuration address.
 
 example: 
yourproxyaddress.co.uk
or 
a.b.c.d 

		"
		read url
		
		clear 
		echo " Port number for Proxy 
		"
		read port
		clear 
		echo " Username for Proxy 
		"
		read user
		clear 
		echo " Password for Proxy 
		"
		read pass
		
		sudo rm -f -- /etc/apt/apt.conf
		sudo touch /etc/apt/apt.conf
		sudo chmod 777 /etc/apt/apt.conf
		echo "Acquire::http::Proxy \"http://$user:$pass@$url:$port\";" >>  /etc/apt/apt.conf
#read -p "test"
		
		git config --global http.proxy http://$user:$pass@p$url:$port
#read -p "test"
		### docker
		sudo mkdir -p /etc/systemd/system/docker.service.d
		sudo rm -f -- /etc/systemd/system/docker.service.d/proxy.conf
		sudo touch /etc/systemd/system/docker.service.d/proxy.conf
		sudo chmod 777 /etc/systemd/system/docker.service.d/proxy.conf
		echo "[Service]
		EnvironmentFile=/etc/system/default/docker
" >> /etc/systemd/system/docker.service.d/proxy.conf
#read -p "test"
		sudo mkdir -p /etc/system/default/
		sudo chmod 777 /etc/system/default/
		sudo rm -f -- /etc/system/default/docker
		sudo touch /etc/system/default/docker
		sudo chmod 777 /etc/system/default/docker
		echo "http_proxy='http%3A%2F%2F$user%3A$pass%40$url%3A$port%2F'" >/etc/system/default/docker
#read -p "test"
#  		sudo systemctl daemon-reload
#  		sudo systemctl restart docker.service
	
	elif  [ "$p" == "n" ]; then
	 	echo " Paste your proxy configuration address.

 example: 
yourproxyaddress.co.uk
or 
a.b.c.d 

		"
		read url
		
		clear 
		echo " Port number for Proxy 
		"
		read port  		
		
		sudo rm -f -- /etc/apt/apt.conf
		sudo touch /etc/apt/apt.conf
		sudo chmod 777 /etc/apt/apt.conf
		echo "Acquire::http::Proxy \"http://$url:$port\";" >>  /etc/apt/apt.conf
		git config --global http.proxy http://$url:$port

		### docker
		sudo mkdir -p /etc/systemd/system/docker.service.d
		sudo rm -f -- /etc/systemd/system/docker.service.d/proxy.conf
		sudo touch /etc/systemd/system/docker.service.d/proxy.conf
		sudo chmod 777 /etc/systemd/system/docker.service.d/proxy.conf
		echo "[Service]
Environment=\"HTTP_PROXY=http://$url:$port\"
Environment=\"HTTPS_PROXY=https://$url:$port\"
Environment=\"NO_PROXY=localhost,127.0.0.1,::1\"
" >> /etc/systemd/system/docker.service.d/proxy.conf
#  		sudo systemctl daemon-reload
#  		sudo systemctl restart docker.service
			
			
		else 
		 	echo "try again"
		
		fi
		
		
}

upgrade()
{
		cd /$rootfolder/$basefolder/
			
		docker compose down

		if [ "$os" == "Ubuntu" ]; then 	
				updates
		elif [ "$os" == "Red" ]; then	
				updatesred
		fi 
		
		echo $ELK >.env
		
		cd /$rootfolder/$basefolder/
		clear 
		git branch --all | cut -d "/" -f3 > gitversion.txt
		echo "choose a branch "
		git branch --all | cut -d "/" -f3 |grep -n ''

		echo " Select the line number

		"
		read x
		orig=`sed "1,1!d" gitversion.txt|cut -d ' ' -f 2`
		elkver=`sed "$x,1!d" gitversion.txt`
		#				   echo $elkver
		sudo cp docker-compose.yml docker-compose.yml.$orig
		git checkout  $elkver --force
		git pull
 		localip=`hostname -I | cut -d " " -f1`
		
		olddocker=`ls -t docker*aos* |head -1`
		
		
		EFaccount=`more $olddocker |grep EF_ACCOUNT_ID| cut -d ":" -f 2|cut -d " " -f2  `
		EFLice=`more $olddocker |grep EF_FLOW_LICENSE_KEY| cut -d ":" -f 2|cut -d " " -f2  `
		sed -i.bak  's/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''false'\''/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''true'\''/' docker-compose.yml
		sed -i.bak -r "s/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: '$localip:9200'/" docker-compose.yml
		sed -i.bak -r "s/#EF_ACCOUNT_ID: ''/EF_ACCOUNT_ID: $EFaccount/" docker-compose.yml
		sed -i.bak -r "s/#EF_FLOW_LICENSE_KEY: ''/EF_FLOW_LICENSE_KEY: $EFLice/" docker-compose.yml
		
		echo " Just to show you the changes we have made to the docker compose files
		Was:
		EF_OUTPUT_ELASTICSEARCH_ENABLE: 'false'
		EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'

		Now:
		EF_OUTPUT_ELASTICSEARCH_ENABLE: 'true'
		EF_OUTPUT_ELASTICSEARCH_ADDRESSES: '<YourIP>:9200'

		Live:
		"
				
		more docker-compose.yml |egrep -i 'EF_OUTPUT_ELASTICSEARCH_ENABLE|EF_OUTPUT_ELASTICSEARCH_ADDRESSES|EF_ACCOUNT_ID|EF_FLOW_LICENSE_KEY'
		read -p "Press enter to continue"
		
		echo " Go and make a cup of Tea
This is going to take time to install and setup
					
					
					
					"
					
		cd /$rootfolder/$basefolder/
		echo $ELK >.env
		
		
}


testcode()
{
		echo " 
		Space for testing
					"

					dockerupnote
					
}

while true ;
do
	clear
  echo "press cntl-c  or x to exit at any time.
  
  
  
  "
  echo "
This following script will setup Elastic and install the CX10k Visualization project on a clean install of Ubuntu with a static IP.

It will update the host to setup all dependencies and then install Elastic.
It is all scripted, you just need to run option B then E.

From the host you wish to install the project on run the following steps:

1. Select 'B' for the base install.
2. The host will reboot, run the script again from the local directory on the host.
3. Select 'E' for the ELK install.


  	Setup options Hosts (B) and Deploy ELK (E) and Update ELK (U) 

  	If you need to configure a Proxy select (P)
  		
  		
  	"
	echo "B or E or U or P"
	read x
  x=${x,,}
  
  clear

  	if  [ $x == "b" ]; then
				echo "
This should be a one off process do not repeat unless you have cancelled it for some reason.
	
		        "
				  echo "cntl-c  or x to exit"
				  echo ""    
				  echo "Enter 'C' to continue :"
				  read x
				    x=${x,,}
					  clear
				   while [ $x ==  "c" ] ;
				    do
				    	basenote
					  	base 
					  	rebootserver
					  	x="done"
				  done
  		
	  elif [  $x == "e" ]; then
	  		clear
  			echo "press cntl-c  or x to exit at any time.
  
  
  
  			"
    
				echo "
This is a one off process do not repeat, as it will default the setting in the ELK stack.
	
		        "
				  echo "Enter 'C' to continue :"
				  read x
				  x=${x,,}

 					
 					  clear
				   while [  $x ==  "c" ] ;
				    do
				    	elknote
					  	elk 
					  	dockerup
					  	dockerupnote
					  	x="done"
					  exit 0
				  done
				  
				    
			elif [  $x == "P" ]; then
					  		clear
  			echo "press cntl-c  or x to exit at any time.
  
  
  
  			"
    
    
				echo "
This is a one off process do not repeat.
	
		        "
  
				  echo "Enter 'C' to continue :"
				  read x
				  x=${x,,}

					  clear
				   while [  $x ==   "c" ] ;
				    do
					  	proxy 
					  	x="done"
				  done
				  

			elif [  $x ==  "u" ]; then
					  		clear
  			echo "press cntl-c  or x to exit at any time.
  
  
  
  			"
    
    
				echo "
This process is designed to update the base OS packages and allow you to select a upgrade on the ELK enviroment.
	
		        "
 
				  echo "Enter 'C' to continue :"
				  read x
				  x=${x,,}

				  clear
				   while [  $x ==   "c" ] ;
				    do
					  	upgrade
					  	dockerup
					  	dockerupnote
					  	rebootserver
					  	x="done"
				  done
				  

			elif [  $x ==  "t" ]; then
					testcode
				  

	  elif [  $x ==  "x" ]; then
				break


  	else
    	echo "try again"
  	fi

done   
