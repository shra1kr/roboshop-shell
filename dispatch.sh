#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGO_HOST=mongodb.daws78s.online

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install golang -y &>> $LOGFILE
VALIDATE $? "Installing golang"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exist...$Y SKIPPING $N"
fi

mkdir /app &>> $LOGFILE
VALIDATE $? "Creating app Directory"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> $LOGFILE
VALIDATE $? "Downloading the Dispatch code"

cd /app &>> $LOGFILE
VALIDATE $? "Moving to app Directory"

unzip /tmp/dispatch.zip &>> $LOGFILE
VALIDATE $? "Unzipping the code into app Directory"

cd /app &>> $LOGFILE
VALIDATE $? "Moving to app Directory"

go mod init dispatch &>> $LOGFILE
VALIDATE $? "Initializing the Dependencies"

go get &>> $LOGFILE
VALIDATE $? "Getting the Dependencies"

go build &>> $LOGFILE
VALIDATE $? "Biuiding the Dependencies"

cp /home/ec2-user/roboshop-shell/dispatch.service /etc/systemd/system/dispatch.service &>> $LOGFILE

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading the Dispatch"

systemctl enable dispatch &>> $LOGFILE
VALIDATE $? "Enabaling the Dispatch"

systemctl start dispatch &>> $LOGFILE
VALIDATE $? "starting the Dispatch"
