#!/bin/bash

echo "Setting PEM file permissions..."
chmod 400 k8s-key-pair.pem

echo ""
echo "SSH into master:"
ssh -i k8s-key-pair.pem ubuntu@52.215.220.156

echo ""
echo "SSH into workers:"
                    ssh -i k8s-key-pair.pem ubuntu@18.202.30.42
                    ssh -i k8s-key-pair.pem ubuntu@52.211.207.8
