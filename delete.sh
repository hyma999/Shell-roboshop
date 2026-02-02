#!/bin/bash
# Usage: ./cleanup.sh <sg-0b5f214278688d1f2> <Z10031052IOPWYQ5HA3UD> <hymaaws.online> <ami-0220d79f3f480ecf5>

INSTANCE_ID=$1
ZONE_ID=$2
RECORD_NAME=$3
SG_ID=$4

# 1. Terminate Instance
echo "Terminating instance $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# 2. Delete Route 53 Record
echo "Deleting R53 record $RECORD_NAME in $ZONE_ID..."
DNS_JSON=$(aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID \
  --query "ResourceRecordSets[?Name == '$RECORD_NAME.' && Type == 'A']" | jq -c '.[0]')

if [ "$DNS_JSON" != "null" ]; then
  aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID \
    --change-batch '{"Changes": [{"Action": "DELETE", "ResourceRecordSet": '"$DNS_JSON"'}]}'
  echo "Record $RECORD_NAME deleted."
else
  echo "Record $RECORD_NAME not found."
fi
