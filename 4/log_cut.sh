#!/bin/bash
# by yanyunchao
# This is a shell script of linux user login log cutter
#
# USAGE:
# [-s 10k]        :cut access.log and remaining 10k  ||||such as [-s 123k/K/m/M/g/G]
# [-u yanyunchao] :cut yanyunchao login log  
# [-d 20150610]   :cut date 2015-06-03 log           ||||such as [-d 2015/06/03]/[-d 2015-06-03]/[-d 06/03/2015]
# [-n 50]         :cut last 50 lines log
# [-u yanyunchao -d 20150610 -n 10] :cut yanyunchao on 2015-06-03 and late  50 times
#

# parameter check
if [ $# -lt 1 ];then
	echo "USAGE:`basename $0` [-s size] [-u user] [-d date] [-n line]"
	exit 1
fi

while getopts "s:u:d:n:" arg
do
	case $arg in
	s)
		for((i=0; i<${#OPTARG}; i++))
		do
			if [[ ${OPTARG:$i:1} != [0-9] ]] && [[ ${OPTARG:$i:1} != [kKmMgGtT] ]]; then
				echo "invalid parameter:$OPTARG"
				exit 1
			fi
		done
		size_para=$OPTARG
		cut_size_byte=$[`echo $size_para | sed 's/[kK]$/*1024/;s/[mM]$/*1024*1024/;s/[gG]$/*1024*1024*1024/'`]
		;;
	u)
		if [[ ${OPTARG:0:1} == "-" ]]; then 
			echo "invalid parameter:$OPTARG"
			exit 1
		fi
		username=$OPTARG
		;;
	n)
		for((i=0; i<${#OPTARG}; i++))
		do
			if [[ ${OPTARG:$i:1} != [0-9] ]]; then
				echo "invalid parameter:$OPTARG"
				exit 1
			fi
		done
		echo $cut_line
		;;
	d)
		date_cut=`date -d $OPTARG +%Y-%m-%d`

		if [[ $? != 0 ]]; then 
			echo "invalid parameter:$OPTARG"
			exit 1
		fi
		;;
	?)
		echo "invalid parameter"
		exit 1
		;;
	esac
done

#
# 	username cut
#	input log and output a specify size log
#
LogSizeCut()
{
	local log_file_name=$1
	local cut_size=$2
	
	local file_size=`wc -c $log_file_name | awk '{print $1}'`
	if [ $cut_size -gt $file_size ];then
		echo "[ stop ] : the log file is greater than the size of the input!"
		exit 0
	fi
	local split_size=$[$file_size - $cut_size]
	
	split -C $split_size $log_file_name .cutlog_
	cp $log_file_name  ${log_file_name}"_bak"
	tail -n $[`wc -l $log_file_name | awk '{print $1}'` - `wc -l .cutlog_aa |awk '{print $1}'`] $log_file_name > ${log_file_name}"_cut"
	
	mv ${log_file_name}"_cut" $log_file_name 
	rm .cutlog_[a-z]?
#	echo "cut log finished!"
}

#
# 	username cut
#	input log and output a specify user log
#
UserLogCut()
{
	local log_file_name=$1
	local user_name=$2
	local out_name=$3

	grep "$user_name" $log_file_name > $out_name

	if [[ $? != 0 ]];then
		echo "I can't find name:$user_name"
		rm $out_name
		return 1
	fi
}

#
# 	date cut 
#	input log and output a specify date log
#
DateLogCut()
{
	local log_file_name=$1
	local cut_date=$2
	local out_name=$3

	grep "$cut_date" $log_file_name > $out_name

	if [[ $? != 0 ]];then
		echo "I can't find date:$cut_date"
		rm $out_name
		return 1
	fi
}

LineLogCut()
{
	local log_file_name=$1
	local line_cut=$2
	local out_name=$3

	if [[ "$log_file_name" == "$out_name" ]];then
		cp $log_file_name ${log_file_name}"_tmp_"
		tail -n $line_cut ${log_file_name}"_tmp_" > $out_name
		rm ${log_file_name}"_tmp_"
	else
		tail -n $line_cut $log_file_name > $out_name
	fi
}


log_file="access.log"
out_log_file=$log_file

who /var/log/wtmp > $out_log_file	# read linux user login

if [[ -n "$date_cut" ]];then

	DateLogCut $out_log_file  $date_cut  ${date_cut}"_"${out_log_file}
	
	if [[ $? == 0 ]];then
		if [[ -n "$cut_line" ]];then
			rm $out_log_file
		fi
		out_log_file=${date_cut}"_"${out_log_file}
	else
		echo "cut stop!"
		exit 1
	fi
fi

if [[ -n "$username" ]];then
	UserLogCut  $out_log_file  $username  ${username}"_"${out_log_file}
	if [[ $? == 0 ]];then
		if [[ -n "$cut_line" ]] || [[ -n "$date_cut" ]];then
			rm $out_log_file
		fi
		out_log_file=${username}"_"${out_log_file}
	else
		echo "cut stop!"
		exit 1
	fi
fi


if [[ -n $cut_size_byte ]];then
	LogSizeCut $log_file  $cut_size_byte
fi

if [[ -n "$cut_line" ]];then
	LineLogCut $out_log_file $cut_line $out_log_file 
fi
cp $out_log_file ${out_log_file}"_tmp_"
cat ${out_log_file}"_tmp_" | tr -s [:space:] | sort -k3r -k4r | awk '{printf "%-15s%-10s%-11s%-8s%-15s\n",$1,$2,$3,$4,$5}' > $out_log_file
rm ${out_log_file}"_tmp_"
