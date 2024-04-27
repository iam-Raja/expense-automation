#!/bin/bash
USERID=$(id -u)
Timestamp=$(date +%F-%H-%M-%S)
script_name=$(echo $0|cut -d "." -f1)
log_file=/tmp/$script_name-$Timestamp.log
R="\e[31M"
G="\e[32M"
Y="\e[33M"
N="\e[0M"

if [ $USERID -ne 0 ]
then echo "switch to super user"
exit 1
else " u r super user"
fi

# if [ $USERID -ne 0 ]
# then
# echo "switch to root....proceed....."
# exit 1
# else
# echo "u r super user"
# fi
validate(){
    If [ $1 -ne 0 ]
    then echo -e "$2 ..... $R Failed $N"
    exit 1
    else echo -e "$2 ..... $G success $N"
    fi
}
dnf install mysql-server -y &>>$log_file
validate $? "installing mysql"

systemctl enable mysqld &>>$log_file
validate $? "enabling mysqld"

systemctl start mysqld &>>$log_file
validate $? "starting mysqld"

#mysql -h db.
mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$log_file
validate $? "setting up root password"
