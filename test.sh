. ./valid_ip.sh
while true
do
echo "enter ip"
read uip

if valid_ip $uip
then
echo "$uip is a proper ip"
else
echo "$uip is not a proper ip"
fi
done
