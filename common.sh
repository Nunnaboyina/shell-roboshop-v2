#!/bin/bash

user_id=$(id -u)
log_folder="/var/log/roboshop"
log_file="${log_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
domain_name="saidevops.shop"
script_dir=$(dirname "$(realpath "$0")") 

check_root(){
    if [ $user_id -ne 0 ]; then
        echo "Please run the script with sudo access...."
        exit 1
    fi
}
mkdir -p $log_folder

timestamp(){
    date +"%F %T"
}

echo "$(timestamp) [INFO] ========Script Execution Started==========" | tee -a $log_file

validate(){
    if [ $1 -ne 0 ]; then 
        echo -e "$(timestamp) [ERROR] ${2} is ${R}FAILED${N}" | tee -a $log_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2} is ${G}SUCCESSFUL${N}" | tee -a $log_file
    fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>> $log_file
    dnf module enable nodejs:24 -y &>> $log_file
    dnf install nodejs -y &>> $log_file
    validate $? "Installing nodejs"
    npm install &>> $log_file
    validate $? "Installing dependencies"
}

app_setup(){
    id "roboshop" &>> $log_file
    if [ $? -eq 0 ]; then 
        echo -e "$(timestamp) [INFO] System roboshop User already exists---${Y}SKIPPED${N}"
    else
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
        validate $? "Creating System application User"
    fi
    rm -rf /app
    mkdir -p /app 
    validate $? "Creating app directory"

    curl -L -o "/tmp/$app_name.zip" "https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/$app_name-v4.zip" &>> $log_file
    validate $? "Downloading $app_name"

    cd /app
    unzip "/tmp/$app_name.zip"
    validate $? "unzipping the $app_name"   

}

java_setup(){
    dnf module enable maven:3.9 -y &>> $log_file
    dnf install maven java-25-openjdk-devel -y &>> $log_file
    validate $? "Installing Java and maven"

    alternatives --set java /usr/lib/jvm/java-25-openjdk/bin/java &>> $log_file
    validate $? "setting Java 25 as default version"

    echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
    source /etc/profile.d/java.sh &>> $log_file
    echo $JAVA_HOME  &>> $log_file
    validate $? "Setting JAVA_HOME for maven"
    mvn clean package &>> $log_file
    validate $? "Installing dependencies"

    mv target/shipping.jar shipping.jar &>> $log_file
    validate $? "Moving shipping jar files"

}
python_setup(){
    dnf install python3.14 python3.14-pip -y &>> $log_file
    validate $? "Installing python"

    python3.14 --version &>> $log_file 
    validate $? "Verifying python version"
    python3.14 -m venv /app/.venv &>> $log_file
    /app/.venv/bin/pip install -r requirements.txt &>> $log_file
    validate $? "Installing python dependencies"
}
systemd_setup(){
    sed -i "s/DOMAIN_NAME/$domain_name/" "$script_dir/$app_name.service"
    cp "$script_dir/$app_name.service" /etc/systemd/system/$app_name.service
    validate $? "copying the $app_name service file"

    systemctl daemon-reload &>> $log_file
    systemctl enable $app_name &>> $log_file
    systemctl start $app_name &>> $log_file
    validate $? "Starting $app_name"
}

restart(){
    systemctl restart $app_name &>> $log_file
    validate $? "Restart $app_name"
}

time_period(){
    echo "$(timestamp) [INFO] Script ended in $SECONDS seconds"
    echo "$(timestamp) [INFO] ========Script Execution Stopped==========" | tee -a $log_file
}