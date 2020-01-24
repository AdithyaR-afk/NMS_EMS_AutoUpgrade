#!/bin/bash
#This script the the starting point to install EMS, NMS and, EMS and NMS together in co-resident mode
isCoResident=CORESIDENT
UNTAR="tar -xzf"
EMS_INSTALLDIR="/opt/ems/release"
NMS_INSTALLDIR="/opt/nms/release"
RAS_INSTALLDIR="/opt/ras/release"
product="default"
product_number=0
option_key="NONE"
curtime=`date`
curtime_repl=`echo "$curtime" | sed "s/\s/_/ig" |  sed "s/:/./ig"`
INSTALL_TEMP_DIR="/opt/Installation_$curtime_repl"
OS_DISTRO_VERSION=`cut -d ' ' -f 7 /etc/redhat-release`
# get function for MAP created by associated array.
getFromMap() {
mapName=$1; key=$2
        map=${!mapName}
        for row in ${map[@]} ; do
                KEY=${row%%:*}
                if [ "$KEY" == "$2" ]
                then
                        VALUE=${row##*:}
                        echo $VALUE      
                fi
        done
}

# Choose one option for installation. 
function installationOptionDisplay() {

	op1=" Install EMS."
	op2=" Install NMS."
	op3=" Install RAS."
	op4=" Install EMS & NMS in co-residency."
	op5=" Install RAS & NMS in co-residency."
	op6=" Install RAS EMS & NMS in co-residency."
	op7=" Install DBServer EMS."
	op8=" Install DBServer NMS."
	op9=" Install DBServer co-residency."
	op10=" exit."

	option_map=("1:op1" "2:op2" "3:op3" "4:op4" "5:op5" "6:op6" "7:op7" "8:op8" "9:op9" "10:op10")	
	option_display_map=( "EMS:1,7,10" "NMS:2,8,10" "RAS:3,10" "EMS_NMS:1,2,4,7,8,9,10" "RAS_NMS:2,3,5,8,10" "EMS_RAS_NMS:1,2,3,4,5,6,7,8,9,10" )


# Finding available product in CD/DVD.
	if [ `ls -l | grep EMS |  wc -l ` -ne 0 -a `ls -l | grep NMS |  wc -l ` -ne 0 -a `ls -l | grep RAS |  wc -l ` -ne 0 ]
	then
		option_key="EMS_RAS_NMS"
	elif [ `ls -l | grep EMS |  wc -l ` -ne 0 -a `ls -l | grep NMS |  wc -l ` -ne 0 ]
	then
		option_key="EMS_NMS"
	elif [ `ls -l | grep NMS |  wc -l ` -ne 0 -a `ls -l | grep RAS |  wc -l ` -ne 0 ]
	then
		option_key="RAS_NMS"
	elif [ `ls -l | grep EMS |  wc -l ` -ne 0 ]
	then
		option_key="EMS"
	elif [ `ls -l | grep NMS |  wc -l ` -ne 0 ]
	then 
		option_key="NMS"
	elif [ `ls -l | grep RAS | wc -l ` -ne 0 ]
	then
		option_key="RAS"
	fi

	if [ "$option_key" == "NONE" ]
	then
		echo "Not found any product in the folder."
		exit 1;
	fi

	disp_val=$(getFromMap option_display_map[@] $option_key)
	disp_val=`echo $disp_val | sed -e 's;\,; ;g'`
	echo "Options :"
	count=1
	valid_opt=""
	for a in $disp_val
	do
		if [ $count -eq 1 ];then
			valid_opt=`echo $count`
		else
			valid_opt=`echo "$valid_opt,$count"`
		fi
		option_str=$(getFromMap option_map[@] $a)
		str_val=`echo ${!option_str}`
		echo "$count) $str_val" 2>&1 | tee -a $LOG_FILE;
		((count++))		
	done
	((count--))
	user_output="Enter the value for installation from above options :($valid_opt) [$count]:"
	echo -n $user_output 2>&1 | tee -a $LOG_FILE
	readUserInput $valid_opt "$user_output" $count
	lc=1
	for i in $disp_val
	do
		if [ "$lc" == "$user_input_provided" ];then
	    		product_number=$i
			break;
		fi
		((lc++))
	done
	unset user_input_provided
}

# Cleanup on completion
function installationComplete() {
	rm -rf "$INSTALL_TEMP_DIR"
	cd $THIS_DIR
	echo "Installation completed at `date`"
	unset LOG_FILE
}

#readUserInput [valid options separated by comma] [userQusetion] [defaultValue]
function readUserInput()
{

        validOptions=$1
	userQuestion=$2
	defaultValue=$3
        read user_input_provided
	optionArray=( `echo $validOptions | tr ',' ' '` )
	while [ true ]
	do
		if [ "$defaultValue" != "" -a "$user_input_provided" == "" ]
		then
			user_input_provided=$defaultValue
			echo "$user_input_provided" >> "$LOG_FILE"
			export user_input_provided
			return 0
		fi
                for option in ${optionArray[@]}
                do
                        if [ "$option" == "$user_input_provided" ]
                        then
				echo "$user_input_provided" >> "$LOG_FILE"
				export user_input_provided
                                return 0
                        fi
                done
                echo "Error: Invalid option entered."
		echo -n $userQuestion
		read user_input_provided
		echo "$user_input_provided" >> "$LOG_FILE"
	done
}

# Restore the databases 
# Asuming default case should be co-residency mode. 
function restoreDBBackup () {
	hostIP=`hostname -i`	
	get_db_password $hostIP
		
	case $1 in 
		'NMS')
			getDBBackupLocation NMS
			find_installer DBServer nms_install.sh
			$app_folder/bin/db_restore.sh root $db_passwd $hostIP $db_backup_location
		;;
		'EMS') 
			getDBBackupLocation EMS
			find_installer DBServer ems_install.sh
			$app_folder/bin/DBRestore.sh $db_backup_location
		;;
		'RAS') 
			getDBBackupLocation RAS
			find_installer DBServer ras_install.sh
			$app_folder/bin/rasbackup_script.sh "dbdump"
		
		;;
		'EMS_NMS')
			getDBBackupLocation NMS
			find_installer DBServer nms_install.sh
			$app_folder/bin/db_restore.sh root $db_passwd $hostIP $db_backup_location
			
			getDBBackupLocation EMS
			find_installer DBServer ems_install.sh
			$app_folder/bin/DBRestore.sh $db_backup_location
		;;
		'RAS_NMS')
			getDBBackupLocation NMS
			find_installer DBServer nms_install.sh
			$app_folder/bin/db_restore.sh root $db_passwd $hostIP $db_backup_location
		;;
		'RAS_EMS_NMS')
		;;
	esac
}

# Asking database location to restore
function getDBBackupLocation () {
	db_backup_location=""
	
	while [ true ]
	do
		echo -n "Enter the $1 DB location : "
		read db_backup_location
		if [ ! -f $db_backup_location ]
		then
			user_output="Backup file not found. Do you want to enter the $1 database location again ? (y/n) [y]:"
			echo -n $user_output
			readUserInput y,n "$user_output" y
			ui=$user_input_provided
			unset user_input_provided
			if [ "$ui" == "n" ]
			then
				installationComplete
				exit 0
			fi
			continue
		else
			break;
		fi
		done
}

#usage: is_licensePresent <dir> <appname>
function start_appService()
{
	if [ $2 != 'ras' ] && [ ! -e $1/license/license.dat ]
	then
		user_output="Copy $2 license file under $1/license/ before starting $2. Press Enter to continue..."
		echo -n $user_output
  		readUserInput y,n "$user_output" "y"
	else
	   user_input="y"
	   user_output="Do you want to start $2 service now? (y/n) [$user_input]:"
	   echo -n $user_output
	   readUserInput y,n "$user_output" "y"
	   if [ `echo $user_input_provided | grep ^y$ | wc -l ` -eq 1 ]
	   then
	      echo "Starting $2 services..."
	      #/sbin/service mysqld start > /dev/null 2>&1
	      if [ "$2" == "ems" ]
	      then
	      echo "Starting MySQL..."
	      start_mysql	
	      fi
	      nohup /sbin/service $2 start > /dev/null 2>&1
	     fi
	 fi

}

function start_emsandnmstogether()
{
	if [[ ! -e $EMS_INSTALLDIR/license/license.dat ]] ||  [[ ! -e $NMS_INSTALLDIR/license/license.dat ]]
	then
   		user_output="Copy ems license file under $EMS_INSTALLDIR/license/ and nms license file under $NMS_INSTALLDIR/license before starting ems and nms. Press Enter to continue..."
		echo -n $user_output
  		readUserInput y,n "$user_output" "y"
	else
	   user_input="y"
	   user_output="Do you want to start ems and nms services now? (y/n) [$user_input]:"
	   echo -n $user_output
	   readUserInput y,n "$user_output" "y"
	   if [ `echo $user_input_provided | grep ^y$ | wc -l ` -eq 1 ]
	   then
	      echo "Starting ems and nms services..."
	      #/sbin/service mysqld start > /dev/null 2>&1
	      start_mysql	
	     nohup /sbin/service emsnms start > /dev/null 2>&1
	     fi
	 fi

}

function start_rasandnmstogether()
{
	if [[ ! -e $NMS_INSTALLDIR/license/license.dat ]]
	then
   		user_output="Copy nms license file under $NMS_INSTALLDIR/license before starting ras and nms. Press Enter to continue..."
		echo -n $user_output
  		readUserInput y,n "$user_output" "y"
	else
	   user_input="y"
	   user_output="Do you want to start ras and nms services now? (y/n) [$user_input]:"
	   echo -n $user_output
	   readUserInput y,n "$user_output" "y"
	   if [ `echo $user_input_provided | grep ^y$ | wc -l ` -eq 1 ]
	   then
	      echo "Starting ras and nms services..."
	      #/sbin/service mysqld start > /dev/null 2>&1
	      start_mysql	
	     nohup /sbin/service rasnms start > /dev/null 2>&1
	     fi
	 fi

}

function start_rasemsandnmstogether()
{
	if [[ ! -e $NMS_INSTALLDIR/license/license.dat ]]
        then
                user_output="Copy nms license file under $NMS_INSTALLDIR/license before starting ras, ems and nms. Press Enter to continue..."
                echo -n $user_output
                readUserInput y,n "$user_output" "y"
	elif [[ ! -e $EMS_INSTALLDIR/license/license.dat ]]
        then
                user_output="Copy ems license file under $EMS_INSTALLDIR/license before starting ras, ems and nms. Press Enter to continue..."
                echo -n $user_output
                readUserInput y,n "$user_output" "y"
	else
		user_input="y"
	        user_output="Do you want to start ras, ems and nms services now? (y/n) [$user_input]:"
           	echo -n $user_output
           	readUserInput y,n "$user_output" "y"
           	if [ `echo $user_input_provided | grep ^y$ | wc -l ` -eq 1 ]
           	then
             		 echo "Starting ras, ems and nms services..."
              		#/sbin/service mysqld start > /dev/null 2>&1
              		start_mysql
             	nohup /sbin/service emsnmsras start > /dev/null 2>&1
             fi
         fi
}

#finds the directory where ems_install.sh or nms_install.sh is present
#usage: find_installer [EMS/NMS/RAS] [ems_installer.sh/nms_installer.sh/ras_installer.sh]
function find_installer()
{
app_name=$1
installer_name=$2
cd $INSTALL_TEMP_DIR
# Find EMS Folder.
found="false"
app_folder=""
dir_name=`find . -name "$installer_name"`
for installer_file in $dir_name
do
	if [ $found == "false" ]
	then			
		app_folder=${installer_file%%"/install/$installer_name"}
		found="true"
		echo "$found $installer_file"
	else
		echo "$installer_file"
		echo "1.Installation files are not proper. Found more than one copy of $installer_name file" > $LOG_FILE
		echo "2.Installation files are not proper. Pls chk log's for more Info. Exiting"
		return 1
	fi
done

if [ $found == "false" ]
then
	echo "3.Installation files are not proper. Could not find $installer_name file" > $LOG_FILE
	echo "4.Installation files are not proper. Pls chk log's for more Info. Exiting"
	return 1
fi

}

# This function installs the EMS
function install_ems()
{

find_installer EMS ems_install.sh
if [ $? -eq 1 ] ; then return 1 ; fi
if [ -d OEMData ]
    then
    echo "Data for customization available" 
    cp -rp OEMData $app_folder/ 
fi
cd $app_folder/install 
. ./ems_install.sh $1 
}

# This function installs the NMS
function install_nms()
{
find_installer NMS nms_install.sh
if [ $? -eq 1 ] ; then return 1 ; fi
cd $app_folder/install 
. ./nms_install.sh $1 
}

# This function installs the RAS
function install_ras()
{
find_installer RAS ras_install.sh
if [ $? -eq 1 ] ; then return 1 ; fi
cd $app_folder/install 
. ./ras_install.sh $1 $2 
}

# This function install DBServer for ems/nms/co-residency 
# Find only folder name of product after untar.
# dbserver_install.sh will be available both places that by I use product specefic file name in search.
function install_DBServer() {
	if [ "$1" == "NMS" ];then	
		find_installer DBServer nms_install.sh
	else
		find_installer DBServer ems_install.sh
	fi
	if [ $? -eq 1 ] ; then return 1 ; fi;
	cd $app_folder/install 
	. ./dbserver_install.sh $1
	user_output="Do you want to restore $1 database ? (y/n) [n]:"
	echo -n $user_output
	readUserInput y,n "$user_output" n
	ui=$user_input_provided
	unset user_input_provided
	if [ "$ui" == "y" ]
	then
		restoreDBBackup $1		
	fi
	
}

function isAppStartonMachineStartup()
{
	if [ -z "${product##*'EMS'*}" ]
	then
	STARTUP_QUESTION="Do you want EMS Services to run at Startup (y/n) [y]: "
	echo -n $STARTUP_QUESTION  2>&1 | tee -a $LOG_FILE
	readUserInput  y,n "$STARTUP_QUESTION" y 
	ems_user_selection_autostart=$user_input_provided
	fi
	unset user_input_provided
	if [ -z "${product##*'NMS'*}" ]
	then
	STARTUP_QUESTION="Do you want NMS Services to run at Startup (y/n) [y]: "
	echo -n $STARTUP_QUESTION  2>&1 | tee -a $LOG_FILE
	readUserInput  y,n "$STARTUP_QUESTION" y 
	nms_user_selection_autostart=$user_input_provided
	fi
	unset user_input_provided
	if [ -z "${product##*'RAS'*}" ] 		 
	then 		
	STARTUP_QUESTION="Do you want RAS Services to run at Startup (y/n) [y]: " 		 
	echo -n $STARTUP_QUESTION  2>&1 | tee -a $LOG_FILE 		 
	readUserInput  y,n "$STARTUP_QUESTION" y 		 
	ras_user_selection_autostart=$user_input_provided 		 
	fi

}

# This function untars the EMS and NMS tar file and trigger installation of the product based on user input
function untarAndInstall()
{
# TODO Untaring of data should be only for the product required argument.
echo "Copying the contents of the CD to $INSTALL_TEMP_DIR"
mkdir -p "$INSTALL_TEMP_DIR"
cp -rp *  $INSTALL_TEMP_DIR/
#for file in `ls *.tgz`
#do
# $UNTAR $file -C  $INSTALL_TEMP_DIR/
#done

cd $INSTALL_TEMP_DIR

#Untar tar files
tar_names=`ls *.tgz *.tar.gz 2>/dev/null`
c=2
for tarFile in $tar_names
do
        echo "Extracting the contents of $tarFile" 2>&1
        $UNTAR $tarFile 2>&1
	c+=1
done

#product=0
#if [ `ls -l | grep EMS |  wc -l ` -ne 0 -a `ls -l | grep NMS |  wc -l ` -ne 0 ]
#then
#	product=3
#elif [ `ls -l | grep EMS |  wc -l ` -ne 0 ]
#then
#	product=1
#elif [ `ls -l | grep NMS |  wc -l ` -ne 0 ]
#then 
#	product=2
#fi
echo "Product : $1"

case $1 in
	'EMS')	
		echo "Triggering installation of EMS"
		install_ems
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		;;
	'NMS')
		echo "Triggering installation of NMS" 
		install_nms
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		start_appService $NMS_INSTALLDIR nms
		;;
	'RAS')
		echo "Triggering installation of RAS"
		install_ras
		if [ $? -eq 1 ] ; then exit 1 ; fi ;
		start_appService $RAS_INSTALLDIR ras
		;;
	'EMS_NMS')
		echo "Triggering installation of both EMS and NMS" 
		isAppStartonMachineStartup $product
		install_ems $isCoResident 
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		install_nms $isCoResident
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		if [ "$user_selection_hotstandbySel" = "y" ]
		then
			start_emsandnmstogether
		else
			start_appService $EMS_INSTALLDIR ems
			start_appService $NMS_INSTALLDIR nms
		fi

		;;
	'RAS_NMS')
		echo "Triggering installation of both RAS and NMS" 
		isAppStartonMachineStartup $product
		install_ras $isCoResident $product
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		install_nms $isCoResident 
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		if [ "$user_selection_hotstandbySel" = "y" ]
		then
			start_rasandnmstogether
		else
			start_appService $RAS_INSTALLDIR ras
			start_appService $NMS_INSTALLDIR nms
		fi

		;;
	'RAS_EMS_NMS')
		echo "Triggering installation of RAS,EMS and NMS"
		isAppStartonMachineStartup $product
		install_ems $isCoResident
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		install_ras $isCoResident
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		install_nms $isCoResident
		if [ $? -eq 1 ] ; then exit 1 ; fi;
		if [ "$user_selection_hotstandbySel" = "y" ]
		then
			start_rasemsandnmstogether
		else
			start_appService $RAS_INSTALLDIR ras
			start_appService $EMS_INSTALLDIR ems
			start_appService $NMS_INSTALLDIR nms
		fi
		;;
	'DB_NMS')
		echo "Triggering DBServer installation for NMS" 
		install_DBServer "NMS"
		;;
	'DB_EMS') 
		echo "Triggering DBServer installation for NMS" 
		install_DBServer "EMS"
		;;	
	'DB_EMS_NMS')
		echo "Triggering DBServer installation for co-resident" 
		install_DBServer "EMS_NMS"
		;;
	*)
		echo "Wrong product name."
		;;
esac
}

#This method checks the /etc/hosts file and if it is not updated with the hostname, 
# then it checks the ifconfig and configure with the IP address if only 1 eth0/p4p1 ip_address is present,
# or else propmts user with all the eth0/p4p1 ipaddress for selection.
function checkandconfigurehostsFile()
{
   #If hostname contains localhost, that means user has not configured hostname
   if [ `hostname | grep 'localhost' | wc -l ` -eq 1 ]
   then
	hostnametext=`cat /etc/sysconfig/network | grep HOSTNAME`
	echo "Error:hostname not configured"
	userProvidedHostname=""
	while [ "$userProvidedHostname" == "" ]
	do
		echo -n "Enter the hostname: "
		read userProvidedHostname
		echo "$userProvidedHostname" >> "$LOG_FILE"
	done
	replace $hostnametext "HOSTNAME=$userProvidedHostname" -- /etc/sysconfig/network 
	hostname $userProvidedHostname
	echo "Changed hostname. Restarting network..."
	echo
	/sbin/service network restart
   fi
   if [ `hostname | grep '_' | wc -l ` -eq 1 ]
   then
	hostnametext=`cat /etc/sysconfig/network | grep HOSTNAME`
	echo "Error:hostname contains underscore \"_\" hence it need to be changed"
	userProvidedHostname=""
	while true;
	do
		echo -n "Enter the new hostname: "
		read userProvidedHostname
		if [ "$userProvidedHostname" == "" ]
		then
			echo "Hostname can't be empty"
		else
			if [ `echo $userProvidedHostname | grep "_" | wc -l` -eq 0 ]
			then
				echo "$userProvidedHostname" >> "$LOG_FILE"
				break
			else
				echo "Host name cannot contain underscore \"_\""
			fi
		fi
	done
	replace $hostnametext "HOSTNAME=$userProvidedHostname" -- /etc/sysconfig/network 
	hostname $userProvidedHostname
	echo "Changed hostname. Restarting network..."
	echo
	/sbin/service network restart
   fi  
  eth_iface_available=`/sbin/ifconfig -a  |grep -v "^ " | grep -v -i 'loopback'|grep -v "^$"|cut -d " " -f1|sed 's/\:$//'`
  eth_iface_count=` echo "$eth_iface_available" | wc -l`
  if [ $eth_iface_count -gt 1 ]
  then
  	default_iface=` echo "$eth_iface_available"  | head -n1`
  	all_eth_iface_present=`echo ""$eth_iface_available | sed 's/ /,/g'`
  	echo "Ethernet Interfaces present : "$all_eth_iface_present
  	eth_iface_available=`echo "$eth_iface_available" | grep -v ":"`
  	eth_iface_available=`echo ""$eth_iface_available | sed 's/ /,/g'`
  	user_output="Please choose the Ethernet Interface to be used ($eth_iface_available) [$default_iface] : "
	echo -n $user_output
  	readUserInput $eth_iface_available "$user_output" $default_iface
	nic_iface=$user_input_provided	
  else
	nic_iface=$eth_iface_available
  fi 
  ip=`ifconfig $nic_iface | grep inet | grep -v inet6 |sed -e 's/^[[:space:]]*//'|cut -d " " -f2|grep -o '[0-9].*'`
  hostIp=`hostname -i`
  if [ $? -ne 0 ]
  then
	if [ "$ip" == "" ]
	then
		echo "Ethernet interface is not configured. Please configure ethernet interface and make the ip address up.Exiting installation"
		exit 1;
	fi
	echo "$ip	`hostname`" >> /etc/hosts	
	echo  "/etc/hosts file is re-configured"
  fi

  hostIp=`hostname -i`
  if [ "$ip" != "$hostIp" ]
  then
	sed "s/$hostIp/$ip/ig" /etc/hosts > /tmp/hosts
	mv /tmp/hosts /etc/hosts
  else
	return 0 
  fi
}

# Starting point for this script.

USERNAME=`whoami`
echo ""
echo ""
echo -n "Verifying privileges..."
if [ "$USERNAME" != "root" ]
then
	echo "Unable to install. Permission denied..."
	echo "Please login with 'root' privileges"  2>&1 | tee -a $LOG_FILE
	exit 1
else
	echo " [OK]"
fi
#checking SELinux status
echo -n "Checking SELinux status... "
if [ `getenforce` == "Enforcing" ]
  then
        echo -e "SELinux has been enabled."
	echo -e "Disable SELinux by setting SELinux=disabled in /etc/selinux/config file."
	echo -e "Reboot and check selinux status again..Exiting installation"
        exit 1
else
	echo "[OK]"
fi
#checking firewall status
echo -n "Checking firewall status... "
case $OS_DISTRO_VERSION in
             7.*)    if [[ `systemctl status firewalld | grep -c "inactive"` -eq 0 ]]
                        then
                                echo -e "Firewall status has been enabled.."
                                echo -e "Disable firewall status --> systemctl disable firewalld.Exiting installation.."
                                exit 1
                        else
                                echo "[OK]"
                     fi
                     ;;
               *)   if [[ `/sbin/service iptables status` == "iptables: Firewall is not running." || `/sbin/service ip6tables status` == "ip6tables: Firewall is not running." ]]
                     then
                                echo "[OK]"
                     else
                                echo -e "Firewall status has been enabled."
                                echo -e "Disable firewall status --> service iptables stop OR service ip6tables stop.Exiting installation..."
                                exit 1
                      fi
                      ;;
esac

#TODO: check is OPT is k 
LOG_FILE="/opt/Installation_$curtime_repl.log"
export LOG_FILE
echo "Installation started at $curtime" 2>&1 | tee -a $LOG_FILE

# check host file settings. 
checkandconfigurehostsFile 2>&1 | tee -a $LOG_FILE
THIS_DIR=`pwd` 
# don't use | with this function.
installationOptionDisplay

case $product_number in
	1)
		product="EMS"
	;;
	2)
		product="NMS"
	;;
	3)
		product="RAS"
	;;
	4)
		product="EMS_NMS"
	;;
	5)
		product="RAS_NMS"
	;;
	6)
		product="RAS_EMS_NMS"
	;;
	7)
		product="DB_EMS"
	;;
	8)
		product="DB_NMS"
	;;
	9)
		product="DB_EMS_NMS"
	;;
	10)
		installationComplete
		echo "User exit from installation."
		exit 0
	;;
	*)
		installationComplete
		echo "Exit from installation"
		exit 0
	;;
esac
untarAndInstall $product 2>&1 | tee -a $LOG_FILE
installationComplete
exec $SHELL
