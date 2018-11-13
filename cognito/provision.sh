#!/usr/bin/env bash

# enable bash debug:
# set -x

: "${AWS_PROFILE:=CHANGEME}"
: "${AWS_REGION:=us-east-1}"
: "${STATE_BUCKET:=CHANGEME}"
: "${STATE_KEY:=CHANGEME/terraform/base.tfstate}"

action="$1"

# NVM
. "/usr/local/opt/nvm/nvm.sh"
NVM_NODE_VERSION=$(cat .nvmrc)
nvm install $NVM_NODE_VERSION
nvm use $NVM_NODE_VERSION

# npm
npm install

# tfenv/terraform version
TFENV=$(which tfenv)
if [ $? -eq 0 ]; then
  $TFENV install $(cat .terraform-version)
  cat .terraform-version | xargs $TFENV use
fi

rm -f *.tfstate
rm -rf ./.terraform

terraform init \
  -force-copy \
  -backend=true \
  -backend-config "bucket=${STATE_BUCKET}" \
  -backend-config "key=${STATE_KEY}" \
  -backend-config "profile=${AWS_PROFILE}" \
  -backend-config "region=${AWS_REGION}"

terraform plan

if [ "$action" == "apply" ]; then
  terraform apply -auto-approve
fi

if [ "$action" == "destroy" ]; then
  terraform destroy
fi
