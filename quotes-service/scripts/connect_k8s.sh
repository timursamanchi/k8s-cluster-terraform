#!/bin/bash

echo "Setting PEM file permissions..."
chmod 400 ../pems/k8s-key-pair.pem

echo ""
echo "SSH into masters:"
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/k8s-key-pair.pem ubuntu@54.229.151.205
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/k8s-key-pair.pem ubuntu@54.154.169.125
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ../pems/k8s-key-pair.pem ubuntu@34.245.159.85

echo ""
echo "Use AWS CLI or console to get their public IPs."
