function DBuild #First argument is radius flag then Take input as ip and then build if radius flag = 1 take two builds
{
rflag=$1
ix=$2
bld=$3

if [[ $rflag -eq 1 ]]
then
	rbld=$4
	echo $rbld
fi

sec=$(echo $bld | cut -d'a' -f 2)
fir=$(echo $bld | cut -d'a' -f 1)
fir=${fir::-1}
echo $fir

content=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/~checkout~/ReleaseNotes/NMSreleases/REL_$fir/a_x/rn_ax.html#Releases)


echo $content | grep $bld

if [[ $? -ne 0 ]]
then

	echo 'Error : No such build. Re-enter build'
	read bld

else
	echo 'Build found'

fi

NMSLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/NMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'build/NMS_Rel')
echo "NMSLink: $NMSLink"

#Get EMS Release
EMSLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/EMS_Rel')
echo "EMSLink: $EMSLink"

#Get Install_all.sh

InstallLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/install')
echo "Installlink: $InstallLink"

#Get Dependent Software link

DependLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/EMSreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'builds/Dependent')
echo "Depend: $DependLink"




if [[ $rflag -eq 1 ]]
then
	sec=$(echo $rbld | cut -d'a' -f 2)
	fir=$(echo $rbld | cut -d'a' -f 1)
	fir=${fir::-1}
	RASLink=$(curl -L -K conf_file http://tn100build/cgi-bin/cvsweb.nms/%7Echeckout%7E/ReleaseNotes/RASreleases/REL_$fir/a_x/a$sec/builds.html  | grep -Po '(?<=href=")[^"]*' | grep 'build/RAS')
	echo "RAS link: $RASLink"
fi


bflag=0 #Check if complete build present or not



if [ sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$ix "[ -d /home/ems/$bld ]" ]
then
echo 'build directory exists'

	if [[ $rflag -eq 0 ]]
	then
	sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$ix "test -f  /home/ems/$bld/EMS* -a -f /home/ems/$bld/Dep* -a -f /home/ems/$bld/inst* -a -f /home/ems/$bld/NMS*"
		if [[ $? -ne 0 ]]
		then
		bflag=1
		echo "some files missing"
		fi
	else
	sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$ix "test -f  /home/ems/$bld/EMS* -a -f /home/ems/$bld/Dep* -a -f /home/ems/$bld/inst* -a -f /home/ems/$bld/NMS* -a -f /home/ems/$bld/RAS*"
	if [[ $? -ne 0 ]]
                then
                bflag=1
		echo "some files missing"
                fi
	fi

else
echo 'build directory not present'
sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$ix "mkdir /home/ems/$bld"
bflag=1
fi

if [[ $bflag -eq 1 ]]
then


echo "Downloading Builds..Please wait"
sshpass -f fsshpass scp -o StrictHostKeyChecking=no -r conf_file root@$ix:/home/ems

sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$ix << EOF
cd /home/ems/$bld
rm -rf RAS*
curl -L -K /home/ems/conf_file -O $InstallLink &
curl -L -K /home/ems/conf_file -O $NMSLink &
curl -L -K /home/ems/conf_file -O $EMSLink &
curl -L -K /home/ems/conf_file -O $DependLink &
wait
chmod a+x install_all.sh
EOF

	if [[ $rflag -eq 1 ]]
	then
	sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$ix << EOF
	cd /home/ems/$bld
	curl -L -K /home/ems/conf_file -O $RASLink &
	wait
EOF
	fi
fi
echo "Download Complete"
}
