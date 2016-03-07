#!/bin/sh
echo "--NETWORK--"

mode=$mode
stack=$networkstack
parameters=
template="file://resources/network.json"
. ./resources/run_template.sh $mode $stack $template $parameters
