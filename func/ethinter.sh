function fethinter #take argument as ip
{
echo $1
#declare -A Mainarr
inter=$(sshpass -f fsshpass ssh -o StrictHostKeyChecking=no root@192.168.3.204 'ifconfig -a | grep -B 1 `hostname -i` |  grep -v "^ " | grep -v -i 'loopback' | grep -v "^$"| cut -d':' -f1')
Mainarr[interface]="interface=$inter"
echo ${Mainarr[interface]}
}
