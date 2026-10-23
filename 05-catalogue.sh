#!/bin/bash
app_name=catalogue
source ./common.sh

check_root
app_setup
nodejs_setup

cp $script_dir/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
validate $? "copying mongodb repo file"

dnf install mongodb-mongosh -y &>> $log_file
validate $? "Installing mongodb mongosh"

product_count=$(mongosh --host mongodb.$domain_name --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()' 2>> $log_file)
validate $? "Connecting to mongodb to check for products count"
if [ "$product_count" -eq 0 ]; then
    mongosh --host "mongodb.$domain_name" </app/db/master-data.js &>> $log_file
    validate $? "Loading products"
else 
    echo -e "$(timestamp) [INFO] Products already added --- ${Y}SKIPPED${N}"
fi
systemd_setup
restart
time_period