#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongodb Repo"

dnf install mongodb-org -y &>>$log_file
validate $? "Installing mongodb"

systemctl enable mongod &>>$log_file
systemctl start mongod &>>$log_file
validate $? "Starting and Enabling mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Updating the listening address"

systemctl restart mongod
validate $? "restarting mongod"

time_period