#!/bin/bash
set -euo pipefail

APP_REPO="https://github.com/Trainings-TechEazy/test-repo-for-devops"
APP_DIR="/opt/techeazy"
APP_PORT="80"
STAGE="dev"
STOP_AFTER_MINUTES="180"

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y git maven wget curl apt-transport-https gnupg ca-certificates

wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(. /etc/os-release; echo $VERSION_CODENAME) main" | tee /etc/apt/sources.list.d/adoptium.list
apt-get update -y
apt-get install -y temurin-21-jdk

rm -rf "$APP_DIR"
git clone "$APP_REPO" "$APP_DIR"
cd "$APP_DIR"
mvn clean package -DskipTests || true

mkdir -p /etc/techeazy
cat > /etc/techeazy/env.conf <<EOF
APP_PORT=${APP_PORT}
STAGE=${STAGE}
EOF

cat > /etc/systemd/system/techeazy.service <<'SERVICE'
[Unit]
Description=TechEazy Devops App
After=network.target

[Service]
Type=simple
EnvironmentFile=/etc/techeazy/env.conf
WorkingDirectory=/opt/techeazy
ExecStart=/bin/bash -lc 'jar=$(ls /opt/techeazy/target/*.jar 2>/dev/null | head -n1); /usr/bin/java -jar "$jar" --server.port=$APP_PORT'
Restart=always
User=root

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now techeazy.service

nohup bash -lc "sleep $(( STOP_AFTER_MINUTES * 60 )); shutdown -h now" >/var/log/techeazy_shutdown.log 2>&1 &
