#!/bin/sh
value=""

until [ "$value" != "" ]
do
		
	aws cloudformation describe-stacks --stack-name $1 > "$1$2.txt" 2>&1 
	
	if [ "$(cat $1$2.txt | grep "DELET")" != "" ]
	then
	
		if [ "$(cat $1$2.txt | grep error)" != "" ]
		then
			value="stack_delete"
			break
		fi
		
	else

        if [ "$(cat $1$2.txt | grep ValidationError)" != "" ]
        then
        	value=""
        	break
        else
        
			if [ "$(cat $1$2.txt | grep error)" != "" ]
			then
				value="$(cat $1$2.txt | grep error)"
				break
			else
				value="$(cat $1$2.txt | grep "\"OutputKey\": \"$2\"" -A1 | tail -n 1 | cut -d ':' -f 2- | sed -e 's/^[ \t]*//' -e 's/"//' -e 's/"//' -e 's/,//')"
			
				if [ "$value" == "" ]
				then
					sleep 10
				fi	
			fi
		fi
	fi
done

echo $value

rm $1$2.txt