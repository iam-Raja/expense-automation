#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo please enter db password
read -s my_sql_root_password

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

dnf module disable nodejs -y &>>$log_file
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$log_file
VALIDATE $? "enabling nodejs:20"

dnf install nodejs -y &>>$log_file
VALIDATE $? "installing nodejs"

id expense &>>$log_file
if [ $? -ne 0 ]
then 
useradd expense &>>$log_file
VALIDATE $? "expense user added"
else 
echo -e "user already exists......$Y skipping $N"
fi

mkdir -p /app &>>$log_file
VALIDATE $? "creating the dir app"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$log_file
VALIDATE $? "downloading the code"

cd /app &>>$log_file
VALIDATE $? "switch to the dir app"

unzip /tmp/backend.zip &>>$log_file
VALIDATE $? "unzipping the code"

cd /app &>>$log_file
VALIDATE $? "switch the dir app"

npm install &>>$log_file
VALIDATE $? "installing dependicies"

cp /root/expense-automation/backend.service  /etc/systemd/system/backend.service &>>$log_file
VALIDATE $? "moving backend svc"

systemctl daemon-reload &>>$log_file 
VALIDATE $? "daemon-reload"

systemctl start backend &>>$log_file
VALIDATE $? "starting backend"

systemctl enable backend &>>$log_file
VALIDATE $? "enabling backend"

dnf install mysql -y &>>$log_file
VALIDATE $? "installing mysql"

mysql -h db.daw78s.online uroot -p${my_sql_root_password} < /app/schema/backend.sql &>>$log_file
VALIDATE $? "setting db passord"

systemctl restart backend &>>$log_file
VALIDATE $? "restarting backend"
