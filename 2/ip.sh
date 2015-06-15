#!/bin/bash
b=(`ifconfig |awk 'BEGIN{i=0;}{i++;}/Link encap/{print NR}END{print i}'`)

[ -e ".out1.txt" ] && rm .out1.txt 
[ -e ".out2.txt" ] && rm .out2.txt 
[ -e ".out.txt" ] && rm .out.txt 


ifconfig | awk '/Link encap/{print $1}' > .out1.txt
for((i=0;i<$[${#b[@]}-1];i++));do
	ifconfig | sed -n ${b[i]},${b[$[i+1]]}p | awk -F '[ :]+' '/inet addr/{print $4;flag=1} END{if(flag!=1){print "NULL"}}' >> .out2.txt 
done 

paste -d ":" .out1.txt .out2.txt > .out.txt
rm .out1.txt .out2.txt
