var zlib = require('zlib');
var AWS = require('aws-sdk');
var rejects = 0;
var outbounds = 0;
var ntp = 0;
var portZero = 0;
var zeroIps="";
var ntpIps="";
var badIp="";
var badIps=0;
var logevents=null;

//Top 10 known bad IP addresses from Alert Logic in email from Nikhil Lulla, Weekly Threat Update, February 22
var badIpList=["115.28.143.60","106.187.96.51","123.59.53.219","46.101.249.156","200.143.189.254","223.105.1.35","183.3.202.103","185.12.7.111","223.105.0.130","103.21.70.138","81.183.56.217","46.109.168.179","188.118.2.26","195.191.158.226","66.168.36.140","117.41.229.196","101.200.79.204","40.84.225.81","118.170.130.207","188.212.103.169"];

exports.handler = function(input, context) {
    var payload = new Buffer(input.awslogs.data, 'base64');
    zlib.gunzip(payload, function(e, result) {
        if (e) { 
            context.fail(e);
        } else {
            result = JSON.parse(result.toString('ascii'));
            checkrejects(0, result, context);
        }
     });
};

function checkrejects(i, input, context) {
    
    reject=false;
    outbound=false;
    
    if (input.logEvents.length===0){
        console.log("No events to process");
        return;
    }
    
    if (logevents===null) logevents = input.logEvents.length-1;
    
    if (i===input.logEvents.length){
        //wait until the last item is processed
    	if (logevents > 0){
            console.log("still processing...log events:", logevents);
            checkrejects(i, input, context);
        }else{
           console.log("EVENTS:", input.logEvents.length, "| OUTBOUND ERRORS:", outbounds, " | REJECTS:", rejects, " | BAD IPS: ", badIps, "| NTP:", ntp, "NTP DST: ",ntpIps, "| PORT 0:", portZero,"PORT 0 DST: ",zeroIps);
           context.succeed();
        }
        return;
    }
    
    logevents--;
    
    var trafficError = "";
    var action=input.logEvents[i].extractedFields.action;
    var src = input.logEvents[i].extractedFields.srcaddr;
    var dstport = input.logEvents[i].extractedFields.dstport;
    var dst = input.logEvents[i].extractedFields.dstaddr;  
    
    for (var p = 0; p < badIpList.length; p++){
        if (badIpList[p]===src || badIpList[p]===dst){
            trafficError="BAD IP";
            badIp=true;
            badIps++;
        }
    }
    
    if (!badIp){
        if (action==='REJECT'){
            trafficError = "REJECT";
            reject=true;
            rejects++;
        }else{
            if (src.substring(0,3)==='10.'
                && parseInt(dstport)<1024 
                && dstport!=="0"
                && dstport!=="123"){
                trafficError="OUTBOUND"
                outbound=true;
                outbounds++;
            }else{   
                if (src.substring(0,3)==='10.'){
                    if (dstport==="123"){
                        ntp=ntp+1;
                        ntpIps=dst+", "+ntpIps;
                    }
                    else{
                        if (dstport==="0")
                            portZero=portZero+1;
                            zeroIps=dst+", "+zeroIps;
                    }
                }
                checkrejects(i + 1, input, context);
                return;
            }
        }   
    }

    var interfaceid = input.logEvents[i].extractedFields.interfaceid;
    var srcport = input.logEvents[i].extractedFields.srcport;
   
    var params = {
        Filters: [{
            Name: 'private-ip-address',
            Values: [ src ]
        }]
    };

    var ec2 = new AWS.EC2();

    ec2.describeInstances(params, function(err, data) {
        if (err) console.log("err", err, err.stack);
        else{
                var instanceid="";
                
                if (data.Reservations.length===0){
                    console.log("Instance may have been terminated");
                }else{
                    instanceid = data.Reservations[0].Instances[0].InstanceId;
                }
                
                console.log(trafficError, "source", src,"source port", srcport, "destination", dst, "destination port", dstport, "interface", interfaceid, "instanceid", instanceid);
                
                if (outbound===true || data.Reservations.length === 0){
                    checkrejects(i + 1, input, context);
                    return;
                }
                
                var volumeid=data.Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId;
                var params = { VolumeId: volumeid };
    
                ec2.createSnapshot(params, function(err, data) {
                
                if (err) console.log(err, err.stack); 
                else     console.log("Created snapshot for volumeid: ", volumeid, "snapshot id:", data.SnapshotId);    
                
                var params = { InstanceIds: [instanceid] };
                
                ec2.terminateInstances(params, function(err, data) {
                  if (err) console.log(err, err.stack); 
                  else     console.log("Terminated instance id: ", instanceid);           
                });
                
                checkrejects(i + 1, input, context);

            });
        }
    });
}