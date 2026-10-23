#!/bin/bash

source ./common.sh

check_root

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo 
validate $? "Adding RabbitMq repo"

dnf install erlang rabbitmq-server -y &>> $log_file
validate $? "Installing Rabbitmq server"

systemctl enable rabbitmq-server &>> $log_file
systemctl start rabbitmq-server &>> $log_file
validate $? "Starting and Enabling Rabbitmq"


rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then 
    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    validate $? "Creating RabbitMq user for Roboshop"
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
    validate $? "Setting permission for Roboshop user"
else
   echo -e "RabbitMq user already exists-----${Y}SKIPPED${N}" | tee -a $log_file
fi


time_period
