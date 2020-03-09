function fzip
{
test -d "$path/DB"
if [[ $? -ne 0 ]]
then
echo "DB Directory not present.Move sql files or their archives to DB/ . Exiting"
exit 1
fi

p=0
for z in $path/DB/*.zip
do
echo 'r' > arg.txt
echo "${p}DBDump.sql" >> arg.txt
as=$(echo `unzip -l $z | grep  .sql` | cut -d' ' -f4)
unzip -j $z  $as -d sql/ < arg.txt
p=$((p+1))
done

for x in $path/DB/*.gz
do
sqlfile=$(echo $x | cut -d'.' -f3 --complement)
gunzip $x
mv $sqlfile sql/
done
}
