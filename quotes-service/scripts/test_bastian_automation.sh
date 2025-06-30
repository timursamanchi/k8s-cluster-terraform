#!/bin/bash

# Example NLB and ALB DNS names (replace with actual)
API_NLB_DNS="k8s-api-nlb-xyz.elb.amazonaws.com"
INGRESS_ALB_DNS="k8s-ingress-alb-xyz.elb.amazonaws.com"

# Resolve IPs
API_IP=$(getent hosts $API_NLB_DNS | awk '{print $1}')
INGRESS_IP=$(getent hosts $INGRESS_ALB_DNS | awk '{print $1}')

# Remove existing
sudo sed -i '/api.k8s.local/d' /etc/hosts
sudo sed -i '/app.k8s.local/d' /etc/hosts
sudo sed -i '/ingress.k8s.local/d' /etc/hosts

# Add API + Ingress mappings
echo "$API_IP api.k8s.local" | sudo tee -a /etc/hosts
echo "$INGRESS_IP app.k8s.local" | sudo tee -a /etc/hosts
echo "$INGRESS_IP ingress.k8s.local" | sudo tee -a /etc/hosts

# (Optional) Add node mappings (replace with your actual EC2 IPs)
# echo "10.0.1.10 controller1.k8s.local" | sudo tee -a /etc/hosts
# echo "10.0.2.10 controller2.k8s.local" | sudo tee -a /etc/hosts
# echo "10.0.1.20 worker1.k8s.local" | sudo tee -a /etc/hosts

echo "✅ /etc/hosts updated:"
grep 'k8s.local' /etc/hosts
