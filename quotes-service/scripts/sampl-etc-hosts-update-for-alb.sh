#!/bin/bash

ALB_DNS="k8s-ingress-alb-1234567890.elb.amazonaws.com"
ALB_IP=$(getent hosts $ALB_DNS | awk '{print $1}')

sudo sed -i '/app.k8s.local/d' /etc/hosts
sudo sed -i '/ingress.k8s.local/d' /etc/hosts

echo "$ALB_IP app.k8s.local" | sudo tee -a /etc/hosts
echo "$ALB_IP ingress.k8s.local" | sudo tee -a /etc/hosts

echo "✅ ALB hosts entries added:"
grep 'k8s.local' /etc/hosts
