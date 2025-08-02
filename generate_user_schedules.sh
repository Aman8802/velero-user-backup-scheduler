#!/bin/bash

USER_FILE="users.txt"
TEMPLATE_FILE="devspaces_template.yml"
OUTPUT_DIR="generated_schedules"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Convert CT to UTC (CT is UTC-5 during Daylight Saving Time)
# Friday 11PM CT = Saturday 04:00 UTC
# Monday 4AM CT = Monday 09:00 UTC
START_HOUR=4    # UTC
END_HOUR=$((9 + 24*2))  # 9AM Monday = 57th hour from midnight Saturday

TOTAL_HOURS=$((END_HOUR - START_HOUR))  # 53 hours
TOTAL_USERS=$(wc -l < "$USER_FILE")
USERS_PER_HOUR=$(( (TOTAL_USERS + TOTAL_HOURS - 1) / TOTAL_HOURS ))  # Ceiling division

echo "Total users: $TOTAL_USERS"
echo "Total hours: $TOTAL_HOURS"
echo "Users per hour: $USERS_PER_HOUR"

readarray -t USERS < "$USER_FILE"

user_index=0
for (( hour=START_HOUR; hour<END_HOUR; hour++ )); do
    HOUR_UTC=$(( hour % 24 ))
    DAY_OFFSET=$(( hour / 24 ))
    DAY_OF_WEEK=$(( (6 + DAY_OFFSET) % 7 ))  # Saturday = 6

    for (( i=0; i<USERS_PER_HOUR && user_index<TOTAL_USERS; i++ )); do
        USERNAME="${USERS[$user_index]}"
        CRON_EXPR="0 $HOUR_UTC * * $DAY_OF_WEEK"

        cat <<EOF > "$OUTPUT_DIR/${USERNAME}-devspaces.yml"
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: ocdev-oadp-${USERNAME,,}-devspaces
  namespace: openshift-adp
spec:
  schedule: "$CRON_EXPR"
  skipImmediately: false
  template:
    csiSnapshotTimeout: 72h
    defaultVolumesToRestic: true
    excludedNamespaces: []
    includedNamespaces:
      - ${USERNAME,,}-devspaces
    storageLocation: ocdev-oadp-data-protection-application-1
    ttl: 720h
EOF
        echo "Generated: $OUTPUT_DIR/${USERNAME}-devspaces.yml (UTC: $CRON_EXPR)"
        ((user_index++))
    done
done

echo "✅ Completed generating schedules for $TOTAL_USERS users."
