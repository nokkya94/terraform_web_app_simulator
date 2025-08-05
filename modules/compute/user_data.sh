#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

yum update -y
amazon-linux-extras enable python3.8
yum install -y python38 git

# Installing SSM agent to retrieve parameters from SSM
yum install -y amazon-ssm-agent
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

yum install -y jq aws-cli

# Install pip and Flask
python3.8 -m ensurepip
pip3 install flask psycopg2-binary

# Create app directory
mkdir -p /opt/webapp
cd /opt/webapp

cat <<EOF > app.py
from flask import Flask, request, redirect
import psycopg2
import os

app = Flask(__name__)

DB_HOST = os.environ.get("DB_HOST")
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASS = os.environ.get("DB_PASS")

@app.route("/", methods=["GET"])
def index():
    return '''
    <form action="/submit" method="post">
        First Name: <input name="fname"><br>
        Last Name: <input name="lname"><br>
        <input type="submit" value="Submit">
    </form>
    '''

@app.route("/submit", methods=["POST"])
def submit():
    fname = request.form["fname"]
    lname = request.form["lname"]

    conn = psycopg2.connect(
        host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS
    )
    cur = conn.cursor()
    cur.execute("INSERT INTO users (first_name, last_name) VALUES (%s, %s)", (fname, lname))
    conn.commit()
    cur.close()
    conn.close()
    return redirect("/")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
EOF

# Create systemd unit to run Flask app
cat <<EOF > /etc/systemd/system/webapp.service
[Unit]
Description=Flask Web App

[Service]
Environment=DB_HOST=<RDS_ENDPOINT>
Environment=DB_NAME=webappdb
Environment=DB_USER=$(aws ssm get-parameter --name "/webapp/db/username" --with-decryption --region us-east-1 | jq -r '.Parameter.Value')
Environment=DB_PASS=$(aws ssm get-parameter --name "/webapp/db/password" --with-decryption --region us-east-1 | jq -r '.Parameter.Value')

ExecStart=/usr/bin/python3.8 /opt/webapp/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable webapp
systemctl start webapp
