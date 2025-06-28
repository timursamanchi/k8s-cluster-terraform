#!/bin/bash

# Get the ASG name from the correct directory
ASG_NAME=$(terraform -chdir=.. output -raw workers_asg_name 2>/dev/null)

if [ -z "$ASG_NAME" ]; then
  echo "❌ No Auto Scaling Group name found in Terraform output."
  echo "✅ Please check that you have 'workers_asg_name' output defined and applied."
  exit 1
fi

echo "✅ Auto Scaling Group Name: $ASG_NAME"
echo ""

# Get list of instance IDs in ASG
INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$ASG_NAME" \
  --query "AutoScalingGroups[0].Instances[*].InstanceId" \
  --output text)

if [ -z "$INSTANCE_IDS" ]; then
  echo "❌ No instances found in ASG: $ASG_NAME"
  exit 1
else
  echo "📌 Number of worker instances: $(echo $INSTANCE_IDS | wc -w)"
  echo ""

  # Fetch and display details for each instance
  echo "📌 Worker instance details:"
  for INSTANCE_ID in $INSTANCE_IDS; do
    aws ec2 describe-instances \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[0].Instances[0].{
        InstanceID: InstanceId,
        PublicIP: PublicIpAddress,
        PrivateIP: PrivateIpAddress,
        AZ: Placement.AvailabilityZone
      }" \
      --output table
  done
fi
echo "*** node_info.sh script completed successfully ***"