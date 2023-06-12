#!/bin/bash

# AMI_ID="ami-0c1d144c8fdd8d690"

COMPONENT=$1
HOSTEDZONEID="Z069258112MM0I3IYRYGR"

if [ -z "$1" ] ; then
    echo -e "COMPONENT NAME IS NEEDED"
    echo -e "Ex Usage : \n \t \t  bash create-ec2 componentName"
    exit 1
fi 

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId'|sed -e 's/"//g')
SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=allow-all-sg-b54 | jq '.SecurityGroups[].GroupID' | sed -e 's/"//g')

create_ec2() {

        echo -e "AMI ID is to launch the EC2 is \e[32m $AMI_ID \e[0m"
        echo -e "Security Group ID used to launch the EC2 is \e[35m $SG_ID \e[0m"
        echo -e  "*** Launching server **** "

        IPADDRESS=$(aws ec2 run-instances --image-id ami-0c1d144c8fdd8d690 --instance-type t3.micro --security-group-ids sg-08212398e8c9c44b6 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$COMPONENT}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

        echo -e  "*** Launching $COMPONENT server **** "
        echo -e "Private IP Address of $COMPONENT is $IPADDRESS"  
        echo -e "\e[36m **** Creating DNS Record for the $COMPONENT :  **** \e[0m"

        sed -e "s/COMPONENT/${COMPONENT}/" -e "s/IPADDRESS/${IPADDRESS}/" route53.json > /tmp/record.json
        aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONEID --change-batch file:///tmp/record.json.

        echo -e "\e[36m **** Creating DNS Record for the $COMPONENT :  **** \e[0m \n\n"

}



if [ "$1" = "all" ]; then    

    for component in frontend mongodb catalogue redis user cart shipping mysql rabbitmq payment ; do 
        COMPONENT=$component
        create_ec2
    done 

else 

    create_ec2

fi 

