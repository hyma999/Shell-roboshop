#!/bin/bash

ZONE_ID="Z10031052IOPWYQ5HA3UD"
DOMAIN_NAME="hymaaws.online"

for instance in $@
do
    echo "Finding instance ID for $instance..."

    INSTANCE_ID=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance" "Name=instance-state-name,Values=running,stopped" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)

    if [ -z "$INSTANCE_ID" ]; then
        echo "No instance found for $instance"
        continue
    fi

    echo "Instance ID: $INSTANCE_ID"

    if [ "$instance" == "frontend" ]; then
        RECORD_NAME="$DOMAIN_NAME"
    else
        RECORD_NAME="$instance.$DOMAIN_NAME"
    fi

    echo "Deleting DNS record: $RECORD_NAME"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch "{
        \"Comment\": \"Deleting record\",
        \"Changes\": [{
            \"Action\": \"DELETE\",
            \"ResourceRecordSet\": {
                \"Name\": \"$RECORD_NAME\",
                \"Type\": \"A\",
                \"TTL\": 1,
                \"ResourceRecords\": [{\"Value\": \"0.0.0.0\"}]
            }
        }]
    }" 2>/dev/null

    echo "Terminating instance $INSTANCE_ID..."
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID

    echo "$instance deletion initiated 🚀"
done
