#!/bin/sh
echo "--NETWORK--"

flowloggroup=$uniqueresourceid

echo "Waiting for flow log role creation to complete"
rolearn="$(./resources/get_output_value.sh $flowlogrolestack FlowLogRoleArn)"
echo "Role ARN:" $rolearn

mode=$mode
stack=$networkstack
parameters="--parameters ParameterKey=FlowLogGroupName,ParameterValue=$flowloggroup ParameterKey=FlowLogRoleArn,ParameterValue=$rolearn"
template="file://resources/network.json"
. ./resources/run_template.sh $mode $stack $template $parameters
