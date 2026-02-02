
#!/bin/bash

# ==============================
# AWS FULL RESOURCE CLEANUP
# ==============================

SG_ID="sg-0b5f214278688d1f2"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="10031052IOPWYQ5HA3UD"
DOMAIN_NAME="hymaaws.online"

echo "Starting AWS Cleanup..."
echo "----------------------------------"

# ==============================
# 1️⃣ DELETE DNS RECORD FROM HOSTED ZONE
# ==============================
echo "Fetching DNS record for $DOMAIN_NAME"

aws route53 list-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --query "ResourceRecordSets[?Name == '$DOMAIN_NAME']" \
  --output json > record.json

jq '{
  Changes: [{
    Action: "DELETE",
    ResourceRecordSet: .[0]
  }]
}' record.json > delete-record.json

echo "Deleting DNS record..."
aws route53 change-resource-record-sets \
  --hosted-zone-id $hymaaws.online \
  --change-batch file://delete-record.json

sleep 10

# ==============================
# 2️⃣ DELETE HOSTED ZONE
# ==============================
echo "Deleting Hosted Zone..."
aws route53 delete-hosted-zone --id $ZONE_ID

# ==============================
# 3️⃣ DEREGISTER AMI
# ==============================
echo "Deregistering AMI: $AMI_ID"
aws ec2 deregister-image --image-id $AMI_ID

# Get snapshot ID linked to AMI
SNAPSHOT_ID=$(aws ec2 describe-images \
  --image-ids $AMI_ID \
  --query "Images[0].BlockDeviceMappings[0].Ebs.SnapshotId" \
  --output text)

echo "Deleting snapshot: $SNAPSHOT_ID"
aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID

# ==============================
# 4️⃣ DELETE SECURITY GROUP
# ==============================
echo "Deleting Security Group: $SG_ID"
aws ec2 delete-security-group --group-id $SG_ID

# ==============================
# CLEANUP TEMP FILES
# ==============================
rm -f record.json delete-record.json

echo "----------------------------------"
echo "🎉 Cleanup Completed Successfully!"
echo "----------------------------------"


