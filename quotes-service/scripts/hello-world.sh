#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -x

# Keep it simple and avoid upgrades that cause reboots here
apt-get update -y

mkdir -p /etc/helloworld
echo "Hello, World! From Kubernetes" > /etc/helloworld/message.txt