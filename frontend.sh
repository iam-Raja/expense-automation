#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
    echo -e "$2 ..... $R Failed $N"
    exit 1
    else 
    echo -e "$2 ..... $G success $N"
    fi
}
if [ $USERID -ne 0 ]
then 
echo "switch to super user"
exit 1
else
echo "u r super user"
fi

dnf install nginx -y &>>$log_file
VALIDATE $? "installing nginx"

systemctl enable nginx &>>$log_file
VALIDATE $? "enabling nginx"

systemctl start nginx &>>$log_file
VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/* &>>$log_file
VALIDATE $? "removing default html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$log_file
VALIDATE $? "downloading code"

cd /usr/share/nginx/html &>>$log_file
VALIDATE $? "moving html"

unzip /tmp/frontend.zip &>>$log_file
VALIDATE $? "unzipping code"

#place correct filepath
cp /home/ec2-user/expense-automation/expense.config  /etc/nginx/default.d/expense.conf &>>$log_file
VALIDATE $? "moving expense.conf"

systemctl restart nginx &>>$log_file
VALIDATE $? "restarting nginx"
