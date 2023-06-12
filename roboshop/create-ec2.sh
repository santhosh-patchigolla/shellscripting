#!/bin/bash

# AMI_ID="ami-0c1d144c8fdd8d690"

COMPONENT=$1

if [ -z "$1" ] ; then
    echo -e "COMPONENT NAME IS NEEDED"
    echo -e "Ex Usage : bash create-ec2 componentName"
    exit 1
fi 


AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId'|sed -e 's/"//g')
SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=allow-all-sg-b54 | jq '.SecurityGroups[].GroupID' | sed -e 's/"//g')

echo -e "AMI ID is to launch the EC2 is \e[32m $AMI_ID \e[0m"
echo -e "Security Group ID used to launch the EC2 is \e[35m $SG_ID \e[0m"

echo -e  "*** Launching server **** "

IPADDRESS=$(aws ec2 run-instances --image-id ami-0c1d144c8fdd8d690 --instance-type t3.micro --security-group-ids sg-08212398e8c9c44b6 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$COMPONENT}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

echo -e "Private IP Address of $COMPONENT is $IPADDRESS"        
