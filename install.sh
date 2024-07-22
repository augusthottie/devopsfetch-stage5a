#!/bin/bash

# Install necessary dependencies
apt-get update
apt-get install -y net-tools
apt-get install -y docker.io
apt-get install -y nginx
apt-get install -y jq
apt-get install -y finger

# Copy devopsfetch.sh to /usr/local/bin
cp devopsfetch.sh /usr/local/bin/devopsfetch
chmod +x /usr/local/bin/devopsfetch

# Create systemd service file
cat <<EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevopsFetch Service
After=network.target
[Service]
ExecStart=/usr/local/bin/devopsfetch -t now now
Restart=always
[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

cat <<EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root adm
    postrotate
        systemctl reload devopsfetch.service > /dev/null 2>/dev/null || true
    endscript
}
EOF