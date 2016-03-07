if [ "$stack" == "" ] 
then
	echo "stack name is required."
	return
fi

if [ "$mode" == "NONE" ] 
then
	echo "No Updates to stack: $stack"
	return
fi

if [ "$1" == "DELETE" ] 
then

	echo "Delete stack: $stack"
	aws cloudformation delete-stack --stack-name $2 > $stack.txt  2>&1
	
	if [ "$(cat $stack.txt | grep error)" != "" ]
	then
		echo "Error deleting stack: " $(cat $stack.txt | grep error)
		break
	fi
	
fi

echo "aws cloudformation call: " $stackmode $stack $template

if [ "$1" == "UPDATE" ] 
then

	if [ "$template" == "" ] 
	then
		echo "stack template is required in parameter template in form file://filename.json."
	else
		echo "Update stack: $stack"
	    aws cloudformation update-stack --stack-name $stack --template-body $template $capabilities $parameters > $stack.txt 2>&1
		
	fi

fi
	
if [ "$1" == "CREATE" ] 
then
	
	if [ "$template" == "" ] 
	then
		echo "stack template is required in parameter template in form file://filename.json."
	else
	
		aws cloudformation describe-stacks --stack-name $stack > $stack1.txt  2>&1		
		exists=$(./resources/get_value.sh $stack1.txt "StackId")
		
		if [ "$exists" != "" ] 
		then
			echo $stack "exists"
			return
		fi

		echo "Create stack: $stack"
					
		aws cloudformation create-stack --stack-name $stack --template-body $template $capabilities $parameters > $stack.txt 2>&1
	fi
fi

cat $stack.txt
err="$(cat $stack.txt | grep 'error')"
rm $stack.txt

