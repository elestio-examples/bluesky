# set env vars
set -o allexport; source .env; set +o allexport;

echo "Waiting for software to be ready ..."
sleep 20s;

INVITE_CODE=$(curl \
  --fail \
  --silent \
  --show-error \
  --request POST \
  --user "admin:$PDS_ADMIN_PASSWORD" \
  --header "Content-Type: application/json" \
  --data '{"useCount": 1}' \
  "https://$PDS_HOSTNAME/xrpc/com.atproto.server.createInviteCode" | jq --raw-output '.code')


cat << EOT >> ./.env
INVITE_CODE=$INVITE_CODE
EOT
