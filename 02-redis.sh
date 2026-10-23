#!/bin/bash

source ./common.sh

check_root

dnf module disable redis -y &>> $log_file
dnf module enable redis:7 -y &>> $log_file
dnf install redis -y &>> $log_file
validate $? "Installing redis"

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
validate $? "Allowing remote connections to Redis"

systemctl enable redis &>> $log_file
systemctl start redis
validate $? "Enabling and Starting redis"

time_period