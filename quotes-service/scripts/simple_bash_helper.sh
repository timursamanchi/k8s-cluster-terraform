#!/bin/bash

echo "=== Checking /var/log/user-data.log ==="
USER_DATA_LOG=$(sudo cat /var/log/user-data.log 2>/dev/null)

if [[ -z "$USER_DATA_LOG" ]]; then
  echo "❌ /var/log/user-data.log is empty or not found!"
else
  echo "$USER_DATA_LOG" | grep -E -i 'mkdir|echo|error|fail|permission|denied|sh:|bash:' || echo "✅ No obvious issues found in user-data.log"
fi

echo
echo "=== Checking /var/log/cloud-init-output.log ==="
CLOUD_INIT_LOG=$(sudo cat /var/log/cloud-init-output.log 2>/dev/null)

if [[ -z "$CLOUD_INIT_LOG" ]]; then
  echo "❌ /var/log/cloud-init-output.log is empty or not found!"
else
  echo "$CLOUD_INIT_LOG" | grep -E -i 'user-data|cloud-init|error|fail|permission|denied|sh:|bash:' || echo "✅ No obvious issues found in cloud-init-output.log"
fi
