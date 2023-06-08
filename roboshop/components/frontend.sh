#!/bin/bash 

COMPONENT=frontend

source components/common.sh

echo -e "*********** \e[35m $COMPONENT Installation has started \e[0m ***********"

echo -n "Installing Nginx :"
yum install nginx -y  &>> $LOGFILE
stat $?

echo -n "Downloading the ${COMPONENT} component :"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo -n "Performing Cleanup: "
cd /usr/share/nginx/html
rm -rf *    &>> $LOGFILE
stat $?

echo -n "Extracting ${COMPOMENT} component :"
unzip /tmp/${COMPONENT}.zip   &>> $LOGFILE
mv $COMPONENT-main/*  .
mv static/* . 
rm -rf ${COMPONENT}-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf
stat $? 

echo -n "Updating the Backend component reveseproxy details : "
for component in catalogue user cart shipping payment; do
    sed -i -e "/$component/s/localhost/$component.roboshop.internal/"  /etc/nginx/default.d/roboshop.conf
done 
stat $? 

echo -n "Starting $COMPONENT service: "
systemctl daemon-reload &>> $LOGFILE
systemctl enable nginx  &>> $LOGFILE
systemctl restart nginx   &>> $LOGFILE
stat $?

echo -e "*********** \e[35m $COMPONENT Installation has Completed \e[0m ***********"