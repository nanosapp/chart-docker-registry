#!/bin/bash
set -e

echo -n "S3 Access Key: "
read S3_ACCESS_KEY

echo -n "S3 Secret: "
read -s S3_ACCESS_SECRET

echo "Creating Registry Users..."
echo "To stop adding users, leave the entry empty."

HTPASSWD_CONTENT=""

while true;
do
  echo
  echo -n "Username: "
  read REGISTRY_USERNAME

  if [ -z "$REGISTRY_USERNAME" ]; then
    break;
  fi

  echo -n "Password: "
  read -s  REGISTRY_PASSWORD

  HTPASSWD_CONTENT="$HTPASSWD_CONTENT$(htpasswd -nb $REGISTRY_USERNAME $REGISTRY_PASSWORD)\n"
  
  echo
done


SECRET_NAME=docker-registry-secret
kubectl \
  -n registry \
  create secret generic \
  $SECRET_NAME \
  --from-literal=s3AccessKey=$S3_ACCESS_KEY \
  --from-literal=s3SecretKey=$S3_SECRET_KEY \
  --from-literal=htpasswd=$HTTPASSWD_CONTENT \
  --dry-run \
  -o yaml | kubeseal -o yaml > $SECRET_NAME.yml
