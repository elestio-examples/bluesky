set env vars
set -o allexport; source .env; set +o allexport;

ADMIN_PASSWORD=$(eval openssl rand --hex 16)

cat /opt/elestio/startPostfix.sh > post.txt
filename="./post.txt"

SMTP_LOGIN=""
SMTP_PASSWORD=""

# Read the file line by line
while IFS= read -r line; do
  # Extract the values after the flags (-e)
  values=$(echo "$line" | grep -o '\-e [^ ]*' | sed 's/-e //')

  # Loop through each value and store in respective variables
  while IFS= read -r value; do
    if [[ $value == RELAYHOST_USERNAME=* ]]; then
      SMTP_LOGIN=${value#*=}
    elif [[ $value == RELAYHOST_PASSWORD=* ]]; then
      SMTP_PASSWORD=${value#*=}
    fi
  done <<< "$values"

done < "$filename"

rm post.txt


cat << EOT >> ./.env
PDS_EMAIL_FROM_ADDRESS=$SMTP_LOGIN
PDS_EMAIL_SMTP_URL="smtp://$SMTP_LOGIN:$SMTP_PASSWORD@172.17.0.1:25"
ADMIN_PASSWORD=$ADMIN_PASSWORD
PDS_JWT_SECRET=$(openssl rand --hex 16)
PDS_ADMIN_PASSWORD=$ADMIN_PASSWORD
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=$(eval openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32)
EOT
