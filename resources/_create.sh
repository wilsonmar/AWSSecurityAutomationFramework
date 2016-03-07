#!/bin/sh
. ./resources/run_bucket.sh $mode

if [ "$err" != "" ]
then
	return
fi

. ./resources/run_network.sh $mode

if [ "$err" != "" ]
then
	return
fi

. ./resources/run_roles.sh $mode

if [ "$err" != "" ]
then
	return
fi

. ./resources/run_lambda.sh $mode

if [ "$err" != "" ]
then
	return
fi

. ./resources/run_instances.sh $mode

if [ "$err" != "" ]
then
	return
fi

. ./resources/run_flow_logs.sh $mode

if [ "$err" != "" ]
then
	return
fi

. ./resources/run_subscription_lambda.sh $mode

