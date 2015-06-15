#!/bin/bash

stat(){
	stat_time=`date +%Y-%m-%d" "%H:%M:%S`
	cpu_group=(`awk '/Average/{print $3,$4,$5,$6,$7,$8}' $1`)

	if [ ! -e "$out_name" ];then
		printf "%-25s%-10s%-10s%-10s%-10s%-10s%-10s\n" \
			"        time" "%user" "%nice" "%system" "%iowait" "%steal" "%idle" > $out_name
	fi
	printf "%-25s%-10s%-10s%-10s%-10s%-10s%-10s\n" \
		"$stat_time" ${cpu_group[0]} ${cpu_group[1]} ${cpu_group[2]} ${cpu_group[3]} ${cpu_group[4]} ${cpu_group[5]}  >> $out_name
	return 0
}

dir=$(dirname `readlink -f "$0"`)
tmp_name=${dir}"/.cpu.log"
out_name=${dir}"/cpu_stat.log"

if [[ "$#" == 1 ]] && [[ "$1" == "clear" ]];then
	if  [[ -e "$out_name" ]];then
		rm $out_name
	fi
elif [[ "$#" == 0 ]];then
	sar -u 1 1 > $tmp_name
	stat $tmp_name
	exit $?
else
	echo "invalid parameter"
	exit 1
fi
