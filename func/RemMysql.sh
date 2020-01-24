function fRemMysql
{
sshpass -f fsshpass ssh -o stricthostkeychecking=no root@$1 "service mysqld stop &"
sleep 5
sshpass -f fsshpass ssh -o stricthostkeychecking=no root@$1 << EOF
yum -y remove mysql*
rm -rf /var/log/mysqld.log
rm -rf /var/lib/mysql/
rm -rf /etc/my.cnf
EOF
}
