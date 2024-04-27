#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "please DB password"
read  mysql_root_password

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

dnf install mysql-server -y &>>$log_file
VALIDATE $? "installing mysql"

systemctl enable mysqld &>>$log_file
VALIDATE $? "enabling mysqld"

systemctl start mysqld &>>$log_file
VALIDATE $? "starting mysqld"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$log_file
# VALIDATE $? "setting up root password"

#change db-/name/ip
mysql -h 54.226.227.12 -uroot -p${mysql_root_password} -e 'show databases;' &>>$log_file
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$log_file
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi
