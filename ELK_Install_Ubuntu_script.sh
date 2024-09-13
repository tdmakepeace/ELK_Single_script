#!/bin/bash

base()
	{
		real_user=$(whoami)

		sudo apt-get update
		# sudo NEEDRESTART_MODE=a apt-get dist-upgrade --yes
		sudo NEEDRESTART_SUSPEND=1 apt-get dist-upgrade --yes

		sleep 5

		cd /
		sudo mkdir pensandotools
		sudo chown $real_user:$real_user pensandotools
		sudo chmod 777 pensandotools
		mkdir -p /pensandotools/elk
		mkdir -p /pensandotools/elk/elastiflow
		mkdir -p /pensandotools/scripts
		sudo mkdir -p /etc/apt/keyrings

		sudo  NEEDRESTART_SUSPEND=1 apt-get install curl gnupg ca-certificates lsb-release --yes
		sudo mkdir -p /etc/apt/keyrings
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

		sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt-get update
		sudo NEEDRESTART_SUSPEND=1 apt-get dist-upgrade --yes
		sudo NEEDRESTART_SUSPEND=1 apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin python3.11-venv --yes

		sudo usermod -aG docker $real_user
		
		sleep 5		
		echo "rebooting"
		
		sleep 5
		sudo reboot
		break
		
		}


elk()
	{
		sudo NEEDRESTART_SUSPEND=1 apt-get dist-upgrade --yes

		sleep 10
		
		cd /pensandotools/elk
		git clone https://github.com/amd/pensando-elk.git
		cd /pensandotools/elk/pensando-elk
		`git branch --all | cut -d "/" -f3 > gitversion.txt`
				echo "choose a branch "
						  git branch --all | cut -d "/" -f3 |grep -n ''
						  
						  echo " Select the line number
						  
						  "
						   read x
						   elkver=`sed "$x,1!d" gitversion.txt`
		#				   echo $elkver
								git checkout  $elkver
				
		
		sed -i.bak  's/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''false'\''/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''true'\''/' docker-compose.yml
		localip=`hostname -I | cut -d " " -f1`

		sed -i.bak -r "s/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: '$localip:9200'/" docker-compose.yml
		more docker-compose.yml |grep EF_OUTPUT_ELASTICSEARCH
		read -p "Press enter to continue"
		
		echo " Go and make a cup of Tea
This is going to take time to install and setup
					
					
					
					
					"
					
		cd /pensandotools/elk/pensando-elk/
		echo "TAG=8.13.4" >.env
		mkdir -p data/es_backups
		mkdir -p data/pensando_es
		mkdir -p data/elastiflow
		chmod -R 777 ./data
		sudo sysctl -w vm.max_map_count=262144
		echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf 
		clear 

		sleep 10 
				
		docker compose up --detach
		sleep 60
		curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_index_template/pensando-fwlog?pretty' -d @./elasticsearch/pensando_fwlog_mapping.json
		curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_snapshot/my_fs_backup' -d @./elasticsearch/pensando_fs.json
		curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_slm/policy/pensando' -d @./elasticsearch/pensando_slm.json
		curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/pensando' -d @./elasticsearch/pensando_ilm.json
		curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_slm/policy/elastiflow' -d @./elasticsearch/elastiflow_slm.json
		curl -XPUT -H'Content-Type: application/json' 'http://localhost:9200/_ilm/policy/elastiflow' -d @./elasticsearch/elastiflow_ilm.json
		sleep 60
		curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@./kibana/pensando-dss-syslog-10.14.0001.ndjson
		curl -X POST "http://localhost:5601/api/saved_objects/_import?overwrite=true" -H "kbn-xsrf: true" -H "securitytenant: global" --form file=@./kibana/kibana-8.2.x-flow-codex.ndjson 

		
		clear
		echo "					
Services setting up please wait

					"
		clear
		sleep 60	
		read -p "Press enter to continue, this will include a reboot."
		clear
		echo "					
					Access the UI - https://$localip:5601'
					once the server has rebooted. 
					"

		sleep 10	
		sudo reboot
		break

}

while true ;
do
  echo "cntl-c  or x to exit"
  echo ""    
  echo "The following will setup the ELK stack for the CX10k enviroment. 
you will need to do the host setup of dependencies and then the ELK. 
It is all scripted, you just need to select B the E.
After each section is a auto reboot.
  	
  	Set up Hosts (B) and Deploy ELK (E)"
	echo "B or E"
	read x
  
  clear

  	if  [ "$x" == "B" ]; then
				echo "
This is a one off process do not repeat.
	
		        "
				  echo "cntl-c  or x to exit"
				  echo ""    
				  echo "Enter 'C' to continue :"
				  read x
					  connection $x
					  clear
				   while [ $x ==  C ] ;
				    do
					  	base 
				  done
  		
	  elif [ "$x" == "E" ]; then
				echo "
This is a one off process do not repeat.
	
		        "
				  echo "cntl-c  or x to exit"
				  echo ""    
				  echo "Enter 'C' to continue :"
				  read x
					  connection $x
					  clear
				   while [ $x ==  C ] ;
				    do
					  	elk 
				  done
				    

	  elif [ "$x" == "x" ]; then
				break


  	else
    	echo "try again"
  	fi

done   