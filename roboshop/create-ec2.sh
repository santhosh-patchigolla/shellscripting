#!/bin/bash

# AMI_ID="ami-0c1d144c8fdd8d690"

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId'|sed -e 's/"//g')

echo "AMI ID is $AMI_ID"


aws ec2 run-instances --image-id $(AMI_ID) --instance-type t2.micro