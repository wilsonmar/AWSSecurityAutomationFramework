#!/bin/sh
echo "--ROLES--"
capabilities="--capabilities CAPABILITY_IAM"

stack="FlowLogRole"
template="file://resources/role-flowlog.json"
parameters=
. ./resources/run_template.sh $mode $stack $template $capabilities

if [ "$err" != "" ]
then
	return
fi