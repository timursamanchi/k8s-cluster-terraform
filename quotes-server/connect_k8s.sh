#!/bin/bash

echo "Setting PEM file permissions..."
chmod 400 k8s-key-pair.pem

echo ""
echo "SSH into master:"
ssh -i k8s-key-pair.pem ubuntu@34.254.221.206

echo ""
echo "SSH into workers:"
ssh -i k8s-key-pair.pem ubuntu@3.252.88.208
ssh -i k8s-key-pair.pem ubuntu@54.74.110.78
