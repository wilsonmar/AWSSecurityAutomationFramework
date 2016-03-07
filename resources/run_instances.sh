#!/bin/sh
echo "--INSTANCES--"

if [ "$mode" == "CREATE" ]
then

	bucket=$uniqueresourceid
	aws s3 cp "resources/amilookup.zip" s3://$bucket/amilookup.zip

	sg1="$(./resources/get_output_value.sh $networkstack HoneySecurityGroup)"
	
	subnet1="$(./resources/get_output_value.sh $networkstack HoneySubnet1)"
	subnet2="$(./resources/get_output_value.sh $networkstack HoneySubnet2)"
	
	echo "Security Group 1: " $sg1
	
	echo "Subnet 1: " $subnet1
	echo "Subnet 2: " $subnet2
	
fi

if [ "$mode" == "DELETE" ]
then

	loggroupname="$(./resources/get_output_value.sh Instances LambdaFunction)"
	
	if [ "$loggroupname" != "" ]
	then
		aws logs delete-log-group --log-group-name=$loggroupname
	fi
fi

stack="Instances"
template="file://resources/instances.json"
parameters="--parameters ParameterKey=S3Bucket,ParameterValue=$bucket ParameterKey=S3ZipFile,ParameterValue=amilookup.zip ParameterKey=SecurityGroup,ParameterValue=$sg1 ParameterKey=Subnet1,ParameterValue=$subnet1 ParameterKey=Subnet2,ParameterValue=$subnet2 ParameterKey=KeyName,ParameterValue=$keyname ParameterKey=PingMe,ParameterValue=$pingtest" 
. ./resources/run_template.sh $mode $stack $template $parameters