#!/bin/bash

source ./common.sh
check_root

dnf module disable nginx -y &>> $log_file
dnf module enable nginx:1.26 -y &>> $log_file
dnf install nginx -y &>> $log_file
validate $? "Installing nginx"

systemctl enable nginx &>> $log_file
systemctl start nginx &>> $log_file
validate $? "Enabling and Starting nginx"

rm -rf /usr/share/nginx/html/* &>> $log_file
validate $? "Deleting Default content"

curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip &>> $log_file
validate $? "Downloading frontend code"

cd /usr/share/nginx/html &>> $log_file
unzip /tmp/frontend.zip &>> $log_file
validate $? "Unzipping frontend code"

sed -i "s/DOMAIN_NAME/$domain_name/" "$script_dir/roboshop.conf"
cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf &>> $log_file
validate $? "copying the roboshop config file"

nginx -t &>> $log_file
validate $? "Rechecking nginx configuration"

systemctl restart nginx &>> $log_file
validate $? "Restarting the nginx"

time_period