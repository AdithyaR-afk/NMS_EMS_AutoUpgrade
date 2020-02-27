function fCheckDependency
{
uip=$1

if command -v sshpass >/dev/null 2>&1 ; then
    echo "sshpass found"
   # gjj=$(yum info sshpass)
       # echo $gjj
else
    echo "sshpass not found"
    echo Installing sshpass""

   #wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

   # rpm -ivh epel-release-6-8.noarch.rpm


    #yum  -y install sshpass
#wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/sshpass-1.05-1.el7.rf.x86_64.rpm &
#wait

	rpm -i sshpass-1.05-1.el7.rf.x86_64.rpm
	if command -v sshpass >/dev/null 2>&1
	then
	echo "sshpass installed successfully"
	else
	echo "sshpass install failed for ip:`hostname -i`"
	exit 1
	fi
fi

sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$uip << EOF 
echo "checking for expect"
if command -v expect >/dev/null 2>&1
then
	echo "expect found"
else
	echo "expect not found"
    echo "Installing expect"
	exit 11
fi
EOF
if [[ $? -eq 11 ]]
then
	sshpass -f fsshpass scp -r tcl-8.5.13-8.el7.x86_64.rpm expect-5.45-14.el7_1.x86_64.rpm root@$uip:/home/ems/
	sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@$uip << EOF
rpm -i /home/ems/tcl-8.5.13-8.el7.x86_64.rpm
rpm -i /home/ems/expect-5.45-14.el7_1.x86_64.rpm

	if command -v expect >/dev/null 2>&1
	then
        echo "expect installed successfully"
	else
        echo "expect install failed for ip:$uip"
        exit 24
	fi
EOF
fi

if [[ $? -eq 24 ]]
then
exit 1
fi
}
