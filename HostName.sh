#!/bin/bash
# The script has been create to set up the machines for testing the CX10K.


connection()
{
	export Gateway192="10.99.0.1"
	export Subnet="24"
	export Domian="lab.local"
	
  if [ "$1" == "1" ]; then
   export VM_Name="lg01-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.201.99"
   export DNS="10.250.201.9"
	 export Gateway="10.250.201.1"
   elif  [ "$1" == "2" ]; then
   export VM_Name="lg02-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.202.99"
   export DNS="10.250.202.9"
   export Gateway="10.250.202.1"
   elif  [ "$1" == "3" ]; then
   export VM_Name="lg03-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.203.99"
   	export DNS="10.250.203.9"
	export Gateway="10.250.203.1"
   elif  [ "$1" == "4" ]; then
   export VM_Name="lg04-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.204.99"
   	export DNS="10.250.204.9"
	export Gateway="10.250.204.1"
   elif  [ "$1" == "5" ]; then
   export VM_Name="lg05-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.205.99"
   	export DNS="10.250.205.9"
	export Gateway="10.250.20.1"
   elif  [ "$1" == "6" ]; then
   export VM_Name="lg06-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.206.99"
   	export DNS="10.250.206.9"
	export Gateway="10.250.206.1"
   elif  [ "$1" == "7" ]; then
   export VM_Name="lg07-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.207.99"
   	export DNS="10.250.207.9"
	export Gateway="10.250.207.1"
   elif  [ "$1" == "8" ]; then
   export VM_Name="lg08-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.208.99"
   export DNS="10.250.208.9"
	export Gateway="10.250.208.1"
   elif  [ "$1" == "9" ]; then
   export VM_Name="lg09-elk"
   export ens192="10.99.0.200"
   export DNS="10.250.209.9"
   export Gateway="10.250.209.1"
   export ens224="10.250.209.99"
   elif  [ "$1" == "10" ]; then
   export VM_Name="lg10-elk"
   export ens192="10.99.0.200"
   export ens224="10.250.210.99"
   export DNS="10.250.210.9"
	 export Gateway="10.250.210.1"
   elif  [ "$1" == "11" ]; then
   export VM_Name="toby-elk"
   export ens192="10.99.0.200"
   export ens224="192.168.102.100"
   export DNS="192.168.102.1"
	 export Gateway="192.168.102.1"   
	 export Domian="makepeacehouse.uk"	 

   elif [ "$1" == "x" ]; then
	  exit 0
  else
    echo "try again"
  fi
}



setmachineid()
{			chars=abcdef1234567890
			prefix=19e2010d4ff249cf

			for i in {1..16} ;
			 do
			    prefix="${prefix}${chars:RANDOM%${#chars}:1}"
			done

			sudo hostnamectl
			 rm /etc/machine-id
			sudo echo ${prefix} > /etc/machine-id
			sudo more /etc/machine-id
			

	}
	
sethostname()
{			# sudo rm /etc/hostname
			sudo hostnamectl set-hostname --static "${VM_Name}.hpelab.com"
			# read -p "test"
			sudo hostnamectl set-hostname --pretty "${VM_Name}"
			# read -p "test"
			# sudo hostnamectl set-hostname --transient "${VM_Name}.hpelab.com"

			# sudo hostnamectl set-hostname ${VM_Name} --static
			# sudo hostnamectl set-hostname ${VM_Name} --transient
			# sudo echo ${VM_Name} > /etc/hostname
	}	
	
	
setnetplan()
{ 
	sudo rm  /etc/netplan/00-installer-config.yaml
		
	echo "network: "  > /tmp/00-installer-config.yaml
	echo "  ethernets: "  >> /tmp/00-installer-config.yaml
	echo "    ens192:  "  >> /tmp/00-installer-config.yaml
	echo "      addresses: "  >> /tmp/00-installer-config.yaml
	echo "      - ${ens192}/${Subnet} "  >> /tmp/00-installer-config.yaml
#	echo "      routes:  "  >> /tmp/00-installer-config.yaml
#	echo "      - to: 10.1.1.1 "  >> /tmp/00-installer-config.yaml
#	echo "        via: ${Gateway192} "  >> /tmp/00-installer-config.yaml	
	echo "    ens224:  "  >> /tmp/00-installer-config.yaml
	echo "      addresses: "  >> /tmp/00-installer-config.yaml
	echo "      - ${ens224}/${Subnet} "  >> /tmp/00-installer-config.yaml
	echo "      nameservers: "  >> /tmp/00-installer-config.yaml
	echo "        addresses: "  >> /tmp/00-installer-config.yaml
	echo "        - ${DNS}  "  >> /tmp/00-installer-config.yaml
	echo "        search: "  >> /tmp/00-installer-config.yaml
	echo "        - ${Domian}  "  >> /tmp/00-installer-config.yaml
	echo "      routes:  "  >> /tmp/00-installer-config.yaml
	echo "      - to: default "  >> /tmp/00-installer-config.yaml
	echo "        via: ${Gateway} "  >> /tmp/00-installer-config.yaml	
	echo "  version: 2"  >> /tmp/00-installer-config.yaml	
	
#	echo $variable > /tmp/00-installer-config.yaml
	sudo mv /tmp/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
	# sudo echo $variable > /etc/netplan/00-installer-config.yaml
  sudo more /etc/netplan/00-installer-config.yaml
  sudo chown root:root /etc/netplan/00-installer-config.yaml
  sudo chmod 600 /etc/netplan/00-installer-config.yaml
  sudo netplan apply
	}


readdr()
{
		cd /pensandotools/pensando-elk/
		cp docker-compose.yml docker-compose.yml.backup
		rm docker-compose.yml
		cp docker-compose.yml.orig docker-compose.yml
		localip=$ens192
		localip2=$ens224
		
		sed -i.bak  's/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''false'\''/EF_OUTPUT_ELASTICSEARCH_ENABLE: '\''true'\''/' docker-compose.yml
		localip=`hostname -I | cut -d " " -f1`

		sed -i.bak -r "s/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'/EF_OUTPUT_ELASTICSEARCH_ADDRESSES: '$localip:9200'/" docker-compose.yml
		
	echo " Just to show you the changes we have made to the docker compose files
	 Was:
	 EF_OUTPUT_ELASTICSEARCH_ENABLE: 'false'
	 EF_OUTPUT_ELASTICSEARCH_ADDRESSES: 'CHANGEME:9200'
	 
	 Live:
	 "

		
		more docker-compose.yml |egrep -i 'EF_OUTPUT_ELASTICSEARCH_ENABLE|EF_OUTPUT_ELASTICSEARCH_ADDRESSES'
		read -p "Press enter to continue"
		
		echo " Reboot to take effect 
					
					
					
					"
		read -p "Services setup, We require a reboot. any key to continue"
		clear
		echo "					
					Access the UI - https://$localip2:5601'
					once the server has rebooted. 
					"

		sleep 10	
		sudo reboot
		break
}
	
command()
{
  if  [ "$1" == "a" ]; then
		# setmachineid
		sethostname
		setnetplan

	  


  elif [ "$1" == "x" ]; then
	  echo "" 
	  x=0
	  exit 0
  else
    echo "try again"
  fi
}
	


while true ;
do
  echo "cntl-c  or X to exit"
  echo ""    
	echo "This sets up the hostname and machineID"
	echo ""      
	echo "Set up Hosts IP (H) or update elk if already deployed (E) or exit (x)"
	echo "H or E or x"
	read x
  
  clear

  	if  [ "$x" == "H" ]; then
				echo "
		***************************************************************************************
		HostID    VM Name                 ens192 address        ens224 address       Pod Network 
		***************************************************************************************
		1         lg01-elk                10.99.0.200/24        10.250.201.99/24     POD1		
		2         lg01-elk                10.99.0.200/24        10.250.202.99/24     POD2
		3         lg03-elk                10.99.0.200/24        10.250.203.99/24     POD3
		4         lg04-elk                10.99.0.200/24        10.250.204.99/24     POD4
		5         lg05-elk                10.99.0.200/24        10.250.205.99/24     POD5
		6         lg06-elk                10.99.0.200/24        10.250.206.99/24     POD6
		7         lg07-elk                10.99.0.200/24        10.250.207.99/24     POD7
		8         lg08-elk                10.99.0.200/24        10.250.208.99/24     POD8
		9         lg09-elk                10.99.0.200/24        10.250.209.99/24     POD9
		10        lg10-elk                10.99.0.200/24        10.250.210.99/24     POD10
		        
		        
		        
		        "
				  echo "cntl-c  or x to exit"
				  echo ""    
				  echo "Enter the host ID you want to setup:"
				  read x
					  connection $x
					  clear
				   while [ $x -ge 1 ] ;
				    do
						  echo ""
							echo " ALL Machines"
						  echo "a - Set Hostname and IP"
						  echo ""
						  echo "x - previous menu"
						  echo ""
						  
						  echo "Command you want to run:"
						  read y
					  	command $y
				  done
  		
  		

	  elif [ "$x" == "E" ]; then
				echo "


		***************************************************************************************
		HostID    VM Name                 ens192 address        ens224 address       Pod Network 
		***************************************************************************************
		1         lg01-elk                10.99.0.200/24        10.250.201.99/24     POD1		
		2         lg01-elk                10.99.0.200/24        10.250.202.99/24     POD2
		3         lg03-elk                10.99.0.200/24        10.250.203.99/24     POD3
		4         lg04-elk                10.99.0.200/24        10.250.204.99/24     POD4
		5         lg05-elk                10.99.0.200/24        10.250.205.99/24     POD5
		6         lg06-elk                10.99.0.200/24        10.250.206.99/24     POD6
		7         lg07-elk                10.99.0.200/24        10.250.207.99/24     POD7
		8         lg08-elk                10.99.0.200/24        10.250.208.99/24     POD8
		9         lg09-elk                10.99.0.200/24        10.250.209.99/24     POD9
		10        lg10-elk                10.99.0.200/24        10.250.210.99/24     POD10
		        
		        
		        
		               
		        
		        "
				echo "cntl-c  or x to exit"
				echo ""    
				echo "Enter the host ID you want to setup:"
				read x
				connection $x
				clear
		  
				readdr

		elif [ "$x" == "x" ]; then
				break


  	else
    	echo "try again"
  	fi

done   

