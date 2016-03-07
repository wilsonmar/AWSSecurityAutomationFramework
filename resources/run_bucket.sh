echo "--S3 BUCKET--"

bucket=$uniqueresourceid

if [ "$mode" == "DELETE" ]
then
	echo "force delete bucket"
	aws s3 rb s3://$bucket --force  
fi

stack="TestBucket"
template="file://resources/bucket.json"
parameters="--parameters  ParameterKey=BucketName,ParameterValue=$bucket"
. ./resources/run_template.sh $mode $stack $template

stack="TestBucketPolicy"
template="file://resources/bucket-policy.json"
parameters="--parameters  ParameterKey=BucketName,ParameterValue=$bucket ParameterKey=FirehoseRole,ParameterValue=$fhrole"
. ./resources/run_template.sh $mode $stack $template

