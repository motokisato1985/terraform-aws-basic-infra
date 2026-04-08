#!/bin/bash
# ---------------------------------
# EC2 user data
# Autoscaling startup scripts.
# ---------------------------------
APP_NAME=tastylog
BUCKET_NAME=tastylog-dev-deploy-bucket-f9iswm
CWD=/home/ec2-user

# Log output setting
LOGFILE="/var/log/initialize.log"
exec > "${LOGFILE}"
exec 2>&1

# Change current work directory
cd ${CWD}

# Get latest version number.
aws s3 cp s3://${BUCKET_NAME}/latest ${CWD}

# Get latest resources.
aws s3 cp s3://${BUCKET_NAME}/${APP_NAME}-app-$(cat ./latest).tar.gz ${CWD}

# Decompress tar.gz
rm -rf ${CWD}/${APP_NAME}
mkdir -p ${CWD}/${APP_NAME}
tar -zxvf "${CWD}/${APP_NAME}-app-$(cat ./latest).tar.gz" -C "${CWD}/${APP_NAME}"

# Move to application directory
sudo rm -rf /opt/${APP_NAME}
sudo mv ${CWD}/${APP_NAME} /opt/

# =============================
# SSMからDB接続情報を取得
# =============================
ENVIRONMENT="dev"
REGION="ap-northeast-1"

MYSQL_HOST=$(aws ssm get-parameter --name "/${APP_NAME}/${ENVIRONMENT}/app/MYSQL_HOST" --region ${REGION} --query "Parameter.Value" --output text)
MYSQL_USERNAME=$(aws ssm get-parameter --name "/${APP_NAME}/${ENVIRONMENT}/app/MYSQL_USERNAME" --region ${REGION} --with-decryption --query "Parameter.Value" --output text)
MYSQL_PASSWORD=$(aws ssm get-parameter --name "/${APP_NAME}/${ENVIRONMENT}/app/MYSQL_PASSWORD" --region ${REGION} --with-decryption --query "Parameter.Value" --output text)

CONFIG_FILE="/opt/${APP_NAME}/config/mysql.config.js"

if [ -f "$CONFIG_FILE" ]; then
  sed -i "s|127.0.0.1|${MYSQL_HOST}|g" "$CONFIG_FILE"
  sed -i "s|root|${MYSQL_USERNAME}|g" "$CONFIG_FILE"
  sed -i "s|Passw0rd|${MYSQL_PASSWORD}|g" "$CONFIG_FILE"
  echo "mysql.config.js updated"
else
  echo "ERROR: ${CONFIG_FILE} not found"
  exit 1
fi

# Boot application 
sudo systemctl enable tastylog
sudo systemctl start tastylog
