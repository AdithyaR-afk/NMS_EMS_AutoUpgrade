declare -A Localarr
allarr=$@

echo ${allarr[@]}

for ty in ${allarr[@]}
do
        yu=$(echo $ty | cut -d'=' -f2)
        jo=$(echo $ty | cut -d'=' -f1)
        Localarr[$jo]=$yu
done

for ui in ${!Localarr[@]}
do
        echo "Key: $ui and its value: ${Localarr[$ui]}"
done




#ethinter='ens18'
ethinter=${Localarr[interface]}
#Appmode=SDH
Appmode=${Localarr[Mode]}
#v=3
v=${Localarr[IMode]}
#md=1
md=${Localarr[NMSIMode]}
#pas=Tejas@123
pas=${Localarr[Mysqlpass]}
reconm=n
beenupg=y
Upgnow=y
Upgverno=7.5
Contupg=y
proceed=y
startn=y
starte=y
epass=${Localarr[emspass]}
#hot=y
hot=${Localarr[IsHot]}
#Subnettype=DifferentSubnet
Subnettype=${Localarr[Hotsubtype]}
#HotIP=192.168.3.24,192.168.228.31
HotIP=${Localarr[Hotips]}
HotPrio=${Localarr[Hotprio]}
HotDelay=120
Hoteth=$ethinter
HotMask=255.255.255.0
#HotVir=192.168.3.211
HotVir=${Localarr[VirIP]}
#MixedthisVir='192.168.3.211'
MixedthisVir=${Localarr[MixedthisVirIP]}
#thissubip=192.168.3.206,192.168.3.24
thissubip=${Localarr[MixedthisIPs]}
#MixedotherVir=10.124.0.211
MixedotherVir=${Localarr[MixedotherVirIP]}
#othersubip=10.124.0.74
othersubip=${Localarr[MixedotherIPs]}
#traplist=192.168.3.211,10.124.0.211
traplist=${Localarr[TrapList]}
startnown=n
SDHcon=n

#EMS settings
#emsname='EMS-x'
emsname=${Localarr[EMSname]}
Concurlogin=true
NBINAT=false
Map=''
buildd=${Localarr[Build]}
cd /home/ems/$buildd/
/usr/bin/expect -c "
set timeout -1

spawn ./install_all.sh 

expect  {
     \"Please choose the Ethernet Interface to be used\" 	 { send \"$ethinter\r\" 
	                                                          
								   exp_continue	
                                                                 } 
        
     \"Enter the value for installation from above options\"  { send \"$v\r\"
							          exp_continue
	          	                                          
	                                                        }                  
     \"Enter the Installation mode\"                          { send \"$md\r\"
								
								exp_continue
							       }
     \"Please specify root password for Database Server\"    { send \"$pas\r\"
                                                                
                                                                exp_continue
                                                               }
     \"Please specify new root password for Database Server\"   { send \"$pas\r\"

                                                                exp_continue
                                                               }
     \"Please re-enter the new root password for Database Server\"    { send \"$pas\r\"

                                                                exp_continue
                                                               }
	\"Already existing MySQL needs to be uninstalled. Do you want to proceed?\"      { send \"y\r\"

                                                                			exp_continue
                                                               				}
     \"Please enter unique EMS Name\"                          { send \"$emsname\r\"

                                                                exp_continue
                                                               }
     \"Please enter ems application mode\"                     { send \"$Appmode\r\"

                                                                exp_continue
                                                               }
     \"Do you wish to reconfigure the MySQL password? (y/n)\"  { send \"$reconm\r\"
                                                                
                                                                exp_continue
                                                               }
                                                                
     \"Do you want to Upgrade now?\"                           { send \"$Upgnow\r\"

                                                                exp_continue
                                                               } 
     \") been upgraded ?\"                                     { send \"$beenupg\r\"

                                                                exp_continue
                                                               }
    \"Please enter the upgraded version number\"               { send \"$Upgverno\r\"

                                                                exp_continue
                                                               }
    \"Do you want to continue NMS upgradation?\"               { send \"$Contupg\r\"

                                                                exp_continue
                                                               }
    \"Please enter nms application mode\"                      { send \"$Appmode\r\"

                                                                exp_continue
                                                               }
    \"You might lose the changes made in configuration files\" { send \"$proceed\r\"
                                                                 exp_continue
								}
       \"Application mode is configured to \"  { send \"$SDHcon\r\"

                                                                exp_continue
                                                               }
   
 \"Do you want NMS Services to run at Startup\"    { send \"$startn\r\"
                                                                sleep 1
                                                                exp_continue
                                                           }
   \"Please enter the password for user ems :\"          { send \"$epass\r\"
                                                               
                                                                exp_continue
                                                             }
   \"Do you want to install application in Hot Standby mode?\"  { send \"$hot\r\"
                                                                
                                                                exp_continue
                                                             }
   \"Type of HotStandby?\"                                   { send \"$Subnettype\r\"

                                                                exp_continue
                                                             }
  \"Type the Hot StandBy Machine IPs/Names separated by comma\"  { send \"$HotIP\r\"

                                                                exp_continue
                                                             }
   \"Enter the Hot standby priority of this Server\"         { send \"$HotPrio\r\"

                                                                exp_continue
                                                             }
  \"Enter the Hotstandby switchover delay\"                  { send \"$HotDelay\r\"

                                                                exp_continue
                                                             }
  \"Please enter the Ethernet Interface to be used for HotStandby\"    { send \"$Hoteth\r\"

                                                                exp_continue
                                                             }
  \"Please enter the Virtual IP to be used for HotStandby\"   { send \"$HotVir\r\"

                                                                exp_continue
                                                             }
 \"Please enter this Subnet's Virtual IP\"                   { send \"$MixedthisVir\r\"

                                                                exp_continue
                                                             }
   \"Type the Physical IPs of this Subnet's Virtual IP\"     { send \"$thissubip\r\"

                                                                exp_continue
                                                             }
  \"Please enter other Subnet's Virtual IP\"                 { send \"$MixedotherVir\r\"

                                                                exp_continue
                                                             }
   \"Type the Physical IPs of other Subnet's Virtual IP\"    { send \"$othersubip\r\"

                                                                exp_continue
                                                             }
   \"Please enter the Mask to be used for HotStandby\"       { send \"$HotMask\r\"

                                                                exp_continue
                                                             }
   \"Please enter the MAC Address of the NIC used for HotStandby\"     { send \"\r\"

                                                                exp_continue
                                                             }
   \"Please enter the Ethernet Interface Alias Number to be used for HotStandby\"  { send \"\r\"

                                                                exp_continue
                                                             }
   \"Please enter NMSTrap Server's Subnet's Virtual IP List\"  { send \"$traplist\r\"

                                                                exp_continue
                                                             }

   \"Do you want to start nms service now? (y/n)\"          { send \"$startnown\r\"
                                                                sleep 1
                                                                exp_continue
                                                             }
   \"Do you want to start ems\"                              { send \"$startnown\r\"
                                                                sleep 1
                                                                exp_continue
                                                             }
   
   \"Allow Concurrent User Login (true/false)\"            { send \"$Concurlogin\r\"
                                                                sleep 1
                                                                exp_continue
                                                             }
   \"Allow NBI over NAT (true/false)\"                     { send \"$NBINAT\r\"
                                                                sleep 1
                                                                exp_continue
                                                             }
   \"Do you want TJ5100 Services to run at Startup?\"      { send \"$starte\r\"
                                                                sleep 1
                                                                exp_continue
                                                             }
   \"Do you want EMS Services to run at Startup\"           { send \"$starte\r\"
                                                                sleep 1
                                                                exp_continue
                                                             }
   \"Input selection (1-5) for default map to use for all users\" { send \"$Map\r\"
                                                                sleep 1
                                                                exp_continue
                                                             } 
   \"license file under\"                         { send \"\r\"
                                                               
                                                                exp_continue
                                                             }  

\"Installation completed successfully\" { exit 1 }
\"Installation completed at\" { exit 1 }
}

"
