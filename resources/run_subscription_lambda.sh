#!/bin/sh
echo "--SUBSCRIPTION--"
if [ "$mode" == "NONE" ]
then
	echo "No Updates"
	return
fi

filtername=$uniqueresourceid
flowloggroup=$uniqueresourceid
deliverystreamname=$uniqueresourceid

if [ "$mode" == "DELETE" ]
then

	echo "Delete subscription"
	
	aws logs delete-subscription-filter \
    --log-group-name $flowloggroup \
    --filter-name $filtername  > subscription.txt 2>&1 
	
	err="$(cat subscription.txt | grep ResourceNotFound)"
	if [ "$errno" != "" ] 
	then
		echo "Resource does not exist"
	else
		cat subscription.txt
	fi
    
	return
fi


if [ "$mode" == "CREATE" ]
then

	
	aws logs describe-log-groups --log-group-name $flowloggroup > loggroups.txt
	
	if [ "$(cat loggroups.txt | grep "\[\]")" != "" ]
	then
		echo "The subscription cannot be created until logs exist. "
		echo "To check for logs: Log into AWS console, click CloudWatch, click logs on left, then click on this log group: " $flowloggroup
		echo "Once logs appear run this script again"
		return
	fi
		
	echo "--Create Lambda Subscription for $flowloggroup to $functionname --"

	#http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/flow-logs.html#flow-log-records
    columns="version, accountid, interfaceid, srcaddr, dstaddr, srcport, dstport, protocol, packets, bytes, start, endtime, action, logstatus"
    
	aws logs put-subscription-filter \
    --log-group-name "$flowloggroup" \
    --filter-name "$filtername" \
    --filter-pattern "[$columns]
    " \
    --destination-arn arn:aws:lambda:$region:$accountid:function:$functionname > subscription.txt 2>&1
    
	cat subscription.txt
	
	err="$(cat subscription.txt | grep error)"
	
	if [ "$errno" != "" ] 
	then
		echo "Note: You must existing logs in CloudWatch before this command will work even if the group exists"
	fi

	#verify subscription
	#aws logs describe-subscription-filters --log-group-name $flowloggroup
	
fi