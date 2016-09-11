#!/bin/sh
echo "--NETWORK--"

flowloggroup=$uniqueresourceid

echo "Waiting for flow log role creation to complete"
rolearn="$(./resources/get_output_value.sh $flowlogrolestack FlowLogRoleArn)"

mode=$mode
stack=$networkstack
parameters=FlowLogRoleArn
parameters="--parameters ParameterKey=FlowLogRoleArn,ParameterValue=$rolearn,ParameterKey=FlowLogGroupName,ParameterValue=$flowloggroup"
template="file://resources/network.json"
. ./resources/run_template.sh $mode $stack $template $parameters
