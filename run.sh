#!/bin/sh
##############################################################
# 
# Run Security Automation Demo
#
# Before running this script make sure you have set up the
# AWS CLI and verified it is working:
# http://docs.aws.amazon.com/cli/latest/userguide/installing.html
#
# Pass in "mode" argument: CREATE, DELETE, PINGTEST or NONE
#
# Pass in aws ssh keyname as second argument if ssh to instances
# is required (better to not add keys if not required)
#
###############################################################

echo "----BEGIN----"
date

############################################
# CHANGE PARAMETERS TO MATCH ENVIRONMENT
############################################

#resources are named with account to keep names
#unique across anyone who runs these scripts
<<<<<<< HEAD
accountid=694817512225
=======
accountid=##Change Me To Something Unique##
>>>>>>> 02f1e527a6f2a5b9fa0e102f2f105357af994900
honeypotname=autosec
uniqueresourceid=$honeypotname$accountid

#name of stack which can be seen after running scripts
#in the AWS console "CloudFormation" service page
networkstack="TestNetwork"

############################################
# RUN
############################################

#get region aws cli is configure to use
region=$(aws configure get region)
echo "* Your CLI is configured to create resources in this region: " $region
echo "* http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html"

uniqueresourceid=$uniqueresourceid$region

#mode is the only parameter required on the command line
#./run.sh with no parameter will explain.
mode=$1
if [ "$mode" == "PINGTEST" ]
then 
	mode=CREATE
	pingtest=true
else
	pingtest=false
fi

#pem file without .pem file extension
#a key is not required unless you want to log into the instances
keyname=$2

if [ "$mode" == "" ]
then
	echo "* First argument must specify mode: CREATE, DELETE, PINGTEST, or NONE"
	echo "* example: ./run.sh CREATE [keyname (optional)]"
else

	if [ "$keyname" == "" ]
	then 
		echo "* No AWS EC2 keyname was supplied in the second argument so SSH into instances created will not be possible (which is desirable in a production environment)"
		echo "http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html"
	else
		echo "* keyname: " $keyname
	fi
	
	echo "* Mode = $mode"
	
	if [ "$mode" == "CREATE" ] 
	then
		. ./resources/_create.sh $mode
	else
		if [ "$mode" == "DELETE" ] 
		then
			. ./resources/_delete.sh $mode
		else
			echo "* Nothing was run because mode is not CREATE or DELETE"
		fi
	fi
fi

echo "done" > test.txt
rm *.txt

echo "----END----"
date
