echo "--FLOWLOGS--"

if [ "$mode" == "NONE" ]
then
	echo "No Updates to Flowlogs"
	return
fi

flowloggroup=$uniqueresourceid
aws ec2  describe-flow-logs --filter "Name=log-group-name,Values=$flowloggroup" > flowlog.txt
flowlogid="$(./resources/get_value.sh flowlog.txt FlowLogId)"


if [ "$mode" == "DELETE" ]
then

	aws logs delete-log-group --log-group-name $flowloggroup
	
	if [ "$flowlogid" == "" ]
	then
		echo "$flowlogid does not exist"
		return
	else
		echo "--Delete flowlogs--"
		aws ec2 delete-flow-logs --flow-log-ids $flowlogid > flowlogs.txt 2>&1
		cat flowlogs.txt
		err="$(cat flowlogs.txt | grep Errno)"
		
	fi
	
fi

honeyvpcid=$(./resources/get_output_value.sh $networkstack HoneyVpc)

echo "waiting for flowlogrole to be created..."
role=$(./resources/get_output_value.sh FlowLogRole FlowLogRole)
flowlogrole="arn:aws:iam::$accountid:role/$role"

if [ "$flowlogrole" == "" ]
then
	echo "Flow log role does not exist"
	return
else
	echo "Flow Log Group: " $flowloggroup
	echo "Flow Log Role: " $flowlogrole
fi

if [ "$mode" == "CREATE" ]
then

	if [ "$flowlogid" != "" ]
	then
		echo "Flow Logs Exist: " $flowlogid
		return
	fi

	echo "--Create Flowlogs for $honeyvpcid--"
	aws ec2 create-flow-logs --resource-type VPC --resource-ids $honeyvpcid --traffic-type ALL --log-group-name $flowloggroup --deliver-logs-permission-arn $flowlogrole > flowlogs.txt 2>&1
	
fi

cat flowlogs.txt
err="$(cat flowlogs.txt | grep error)"
rm flowlogs.txt