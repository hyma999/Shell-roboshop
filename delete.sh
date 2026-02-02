#!/bin/bash

# --- Configuration ---
SG_ID="sg-0b5f214278688d1f2"   # ID of the security group to delete
AMI_ID="ami-0220d79f3f480ecf5" # ID of the AMI to deregister
# ZONE_ID="Z10031052IOPWYQ5HA3UD"    # Not directly used in SG/AMI deletion
# DOMAIN_NAME="hymaaws.online"    # Not directly used in SG/AMI deletion

# --- Delete Security Group ---
echo "Deleting Security Group: $SG_ID"
aws ec2 delete-security-group --group-id $SG_ID
if [ $? -eq 0 ]; then
    echo "Successfully deleted Security Group: $SG_ID"
else
    echo "Failed to delete Security Group: $SG_ID"
fi

# --- Deregister AMI ---
echo "Deregistering AMI: $AMI_ID"
aws ec2 deregister-image --image-id $AMI_ID
if [ $? -eq 0 ]; then
    echo "Successfully deregistered AMI: $AMI_ID"
else
    echo "Failed to deregister AMI: $AMI_ID"
fi

# Note: To delete associated snapshots, additional steps are required [2].

