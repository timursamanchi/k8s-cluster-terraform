#!/bin/bash

echo "Setting PEM file permissions..."
chmod 400 k8s-key-pair.pem

echo ""
echo "SSH into masters:"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i k8s-key-pair.pem ubuntu@3.250.27.214
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i k8s-key-pair.pem ubuntu@34.245.77.115
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i k8s-key-pair.pem ubuntu@34.247.90.156

echo ""
echo "Workers are managed by Auto Scaling Group: k8s-workers-asg"
echo "Use AWS CLI or console to get their public IPs."
