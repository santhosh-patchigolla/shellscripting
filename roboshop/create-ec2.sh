#!/bin/bash

# AMI_ID="ami-0c1d144c8fdd8d690"

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId'|sed -e 's/"//g')
SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=allow-all-sg-b54 | jq '.SecurityGroups[].GroupID' | sed -e 's/"//g')

echo -e "AMI ID is to launch the EC2 is \e[32m $AMI_ID \e[0m"
echo -e "Security Group ID used to launch the EC2 is \e[35m $SG_ID \e[0m"

echo -e  "*** Launching server **** "
aws ec2 run-instances --image-id $(AMI_ID) --instance-type t2.micro
