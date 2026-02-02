IP=$(aws route53 list-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --query "ResourceRecordSets[?Name == '$RECORD_NAME.'].ResourceRecords[0].Value" \
    --output text)

aws route53 change-resource-record-sets \
--hosted-zone-id $ZONE_ID \
--change-batch "{
  \"Changes\": [{
    \"Action\": \"DELETE\",
    \"ResourceRecordSet\": {
      \"Name\": \"$RECORD_NAME\",
      \"Type\": \"A\",
      \"TTL\": 1,
      \"ResourceRecords\": [{\"Value\": \"$IP\"}]
    }
  }]
}"
