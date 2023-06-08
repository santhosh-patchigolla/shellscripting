#!/bin/bash 

LOGFILE="/tmp/${COMPONENT}.log"
APPUSER="roboshop"

ID=$(id -u)

if [ $ID -ne 0 ] ; then 
    echo -e "\e[31m This script is expected to be run by a root user or with a sudo privilege \e[0m"
    exit 1
fi 

stat() {
    if [ $1 -eq 0 ] ; then 
        echo -e "\e[32m success \e[0m"
    else 
        echo -e "\e[31m failure \e[0m"
        exit 2
    fi 
}

CREATE_USER() {

    id $APPUSER &>> $LOGFILE
    if [ $? -ne 0 ] ; then 
        echo -n "Creating the Service Account :"
        useradd $APPUSER  &>> $LOGFILE
        stat $?
    fi 

}

DOWNLOAD_AND_EXTRACT() {

    echo -n "Downloading the $COMPONENT component :"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
    stat $? 

    echo -n "Copying the $COMPONENT to $APPUSER home directory :"
    cd /home/${APPUSER}/
    rm -rf  ${COMPONENT}  &>> $LOGFILE
    unzip -o /tmp/${COMPONENT}.zip  &>> $LOGFILE
    stat $?

    echo -n "Modifying the ownership :"
    mv $COMPONENT-main/ $COMPONENT
    chown -R $APPUSER:$APPUSER /home/roboshop/$COMPONENT/
    stat $?

}

NPM_INSTALL() {

    echo -n "Generating npm $COMPONENT artifacts :"
    cd /home/${APPUSER}/${COMPONENT}/
    npm install  &>> $LOGFILE
    stat $?

}

CONFIGURE_SVC() {

    echo -n "Updating the $COMPONENT systemd file :"
    sed -i -e 's/AMQPHOST/rabbitmq.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/${APPUSER}/${COMPONENT}/systemd.service  
    mv /home/${APPUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
    stat $? 

    echo -n "Starting ${COMPONENT} service :"
    systemctl daemon-reload   &>> $LOGFILE
    systemctl enable $COMPONENT  &>> $LOGFILE
    systemctl restart $COMPONENT &>> $LOGFILE
    stat $? 

    echo -e "*********** \e[35m $COMPONENT Installation has Completed \e[0m ***********"

}

NODEJS() {

    echo -e "*********** \e[35m $COMPONENT Installation has started \e[0m ***********"

    echo -n  "Configuring the $COMPONENT repo :"
    curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -  &>> $LOGFILE
    stat $?

    echo -n "Installing NodeJS :"
    yum install nodejs -y   &>> $LOGFILE 
    stat $?

    CREATE_USER                 

    DOWNLOAD_AND_EXTRACT       

    NPM_INSTALL                  

    CONFIGURE_SVC               e.

}

MVN_PACKAGE() {
    echo -n "Preparing $COMPONENT artifacts :"
    cd /home/${APPUSER}/${COMPONENT}
    mvn clean package   &>> $LOGFILE
    mv target/shipping-1.0.jar shipping.jar 
    stat $?
}

JAVA() {
    echo -e "*********** \e[35m $COMPONENT Installation has started \e[0m ***********"

    echo -n "Installing Maven  :"
    yum install maven -y   &>> $LOGFILE 
    stat $?    

    CREATE_USER                 

    DOWNLOAD_AND_EXTRACT        

    MVN_PACKAGE

    CONFIGURE_SVC

}


PYTHON() {
    echo -n "Installing Python and its dependencies :"
    yum install python36 gcc python3-devel -y   &>> $LOGFILE 
    stat $? 

    CREATE_USER                 

    DOWNLOAD_AND_EXTRACT         

    echo -n "Installing $COMPONENT"
    cd /home/${APPUSER}/${COMPONENT}/
    pip3 install -r requirements.txt    &>> $LOGFILE 
    stat $?

    USERID=$(id -u roboshop)
    GROUPID=$(id -g roboshop) 

    echo -n "Updating the uid and gid in the $COMPONENT.ini file"
    sed -i -e "/^uid/ c uid=${USERID}" -e "/^gid/ c gid=${GROUPID}"  /home/${APPUSER}/${COMPONENT}/${COMPONENT}.ini
    
    CONFIGURE_SVC

}