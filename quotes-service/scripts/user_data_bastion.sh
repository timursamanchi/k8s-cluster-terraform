#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -e

touch /tmp/it-worked
echo "Create bastion and installing apps: $(date '+%Y-%m-%d %H:%M:%S')" > /tmp/k8-welcome.txt

# Install packages
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
apt-get install -y net-tools dnsutils htop iotop iftop ncdu
apt-get install -y unzip tar git jq vim tmux
apt-get install -y curl wget socat

