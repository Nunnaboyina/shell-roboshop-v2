#!/bin/bash

source ./common.sh

check_root

dnf module enable mysql:8.4 -y &>> $log_file
dnf install mysql-server -y &>> $log_file
validate $? "Installing mysql" 

systemctl enable mysqld &>> $log_file
systemctl start mysqld &>> $log_file
validate $? "Start and enable mysql"

mysql_secure_installation --set-root-pass RoboShop@1 
validate $? "Setting MySQL root password"

time_period
