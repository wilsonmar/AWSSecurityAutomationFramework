# README #


### What is this repository for? ###

* Test environment for SANS Paper on automated intrusion detection & response

* This code installs a honeypot and some instances in a VPC with Flow Logs enabled.

* An AWS Lambda function automatically makes a snapshot and terminates instances that match  undesirable traffic patterns. 

* NOTE: This code is not production ready nor is it fully tested.

* Use at your own risk.

* The Honey VPC Network is wide open to the Internet but blocks traffic within the VPC. Do not deploy this and open rules in that network that expose your other networks within your account.

### How do I get set up? ###

* Create an AWS account: https://aws.amazon.com/getting-started/

* Set up an account and the AWS CLI: http://docs.aws.amazon.com/cli/latest/userguide/installing.html

* You may or may not want to generate an AWS SSH Key (not required): http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html

* Install git https://git-scm.com/

* Clone this repo: https://git-scm.com/docs/git-clone

git clone https://github.com/tradichel/AWSSecurityAutomationFramework.git 

* Change the accountid value in run.sh to your AWS account id. This is used to generate unique resource names and some ARNs (Amazon's unique resource identifier) for some resources that require it.

* To run the stack execute this code once. Follow the last line of instructions. Run it again.

	./run.sh CREATE [optional AWS SSH key name, without .pem at the end]

* To delete the stack execute:

	./run.sh DELETE
	
* To run a ping test that generates a REJECT and terminates instance execute:

	./run.sh PINGTEST

* The scripts are re-runnable. If something fails to create due to dependency issue you can run it again

### Known Issues ###

* Need to only create one snap then stop if it exists (tag).
* Need to delete snapshot + all logs in DELETE mode.

### Who do I talk to? ###

* @teriradichel

### Resources ###

Subscriptions - to copy data from CloudWatch to Lambda
http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/Subscriptions.html

Lookup latest AMI with lambda function
http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/walkthrough-custom-resources-lambda-lookup-amiids.html

Terminate EC2 instances:
https://github.com/raweng/Builtio-DevOps/blob/master/scale-down-poc-with-lambda/second-lambda.js

Launch an instance with AWS CLI
http://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ec2-cli-launch-instance.html

Making requests to AWS APIs using node.js
http://docs.aws.amazon.com/AWSJavaScriptSDK/guide/node-making-requests.html

Node.js callbacks in loops
http://www.richardrodger.com/2011/04/21/node-js-how-to-write-a-for-loop-with-callbacks/#.Vsp_JpMrKqB

EC2 Node JS AWS SDK
http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/EC2.html

Traffic on port 0:
http://www.pcworld.com/article/2061080/spike-in-traffic-with-tcp-source-port-zero-has-some-researchers-worried.html

Some NTP info
http://koltsoff.com/pub/securing-centos/

Flow Log Reocords
http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/flow-logs.html#flow-log-records

AWS IP ranges - JSON
https://ip-ranges.amazonaws.com/ip-ranges.json

Top 10 known bad IP addresses from Alert Logic in email from Nikhil Lulla, Weekly Threat Update, February 22

115.28.143.60,
106.187.96.51,
123.59.53.219,
46.101.249.156,
200.143.189.254,
223.105.1.35,
183.3.202.103,
185.12.7.111,
223.105.0.130,
103.21.70.138,
81.183.56.217,
46.109.168.179,
188.118.2.26,
195.191.158.226,
66.168.36.140,
117.41.229.196,
101.200.79.204,
40.84.225.81,
118.170.130.207,
188.212.103.169
