#!/bin/sh
echo "--LAMBDA TRANSFORM--"
	
if [ "$mode" == "CREATE" ]
then

	echo "Waiting for bucket stack to complete"
	bucketurl="$(./resources/get_output_value.sh TestBucket BucketURL)"
	bucket=$uniqueresourceid
	aws s3 cp resources/lambdatransform.zip s3://$bucket/lambdatransform.zip	
fi

stack="LambdaTransform"
template="file://resources/lambda_transform.json"
parameters="--parameters ParameterKey=S3Bucket,ParameterValue=$bucket"
. ./resources/run_template.sh $mode $stack $template $parameters

if [ "$mode" == "CREATE" ]
then

	echo "waiting for lambda function to add permissions"
	functionname="$(./resources/get_output_value.sh LambdaTransform LambdaFunction)"
	
	aws lambda add-permission \
	    --function-name $functionname \
	    --statement-id "lambdatransform" \
	    --principal "logs.$region.amazonaws.com" \
	    --action "lambda:InvokeFunction" \
	    --source-arn "arn:aws:logs:$region:$accountid:log-group:$uniqueresourceid:*" \
	    --source-account "$accountid"
	    
fi    
