#!/bin/bash
app_name=shipping
source ./common.sh
check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y &>> $log_file
validate $? "Installing mysql client"

count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -NB -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file)
if [ -z "$count" ] || [ "$count" -eq 0 ]; then
     mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $log_file
     validate $? "Loading shipping data"
else
    echo -e "$(timestamp) [INFO] Shipping data already exist...${Y}SKIPPINNG${N}"
fi

mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $log_file
validate $? " Creating APP user "

restart
time_period