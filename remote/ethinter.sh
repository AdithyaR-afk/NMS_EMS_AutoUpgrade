ethlist=$(/sbin/ifconfig -a  |grep -v "^ " | grep -v -i 'loopback'|grep -v "^$"|cut -d " " -f1|sed 's/\:$//')
ethcount=` echo "$ethlist" | wc -l`
argflagint=0
thisip=`hostname -i`
if [[ $ethcount -gt 1 ]]
  then
      Maineth=$(/sbin/ifconfig -a  |grep -B 1 $thisip | grep -v "^ " | grep -v -i 'loopback'| grep -v "^$"| cut -d " " -f1| sed 's/\:$//') 
      argflagint=1
fi
echo $Maineth


if [[ $argflagint -eq 1 ]]  #modify argument array to be passed on to install.sh if more than one eth interface is present
then
LocalARGAR(interface)=$Maineth
#clear
#echo "options here"
#echo "Enter ur options 1/2"
#read op
#clear
#if [[ $op -eq 1 ]]
#then
#echo "Fisrt option $op" > log.txt
#else
#echo "second option $op" > log.txt
#fi

