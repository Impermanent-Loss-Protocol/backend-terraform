# Backend Terraform

## Install

`brew install terraform`

## Run

1. get `service-account.json` from your GCP's IAM
2. `. ./.env.sh`
3. `terraform apply --auto-approve`

seems to me that terraform is not up to date, so we can
1. build image in Github Action
2. manually update image tag in cloud run for v0
3. or use cloud build to update image for cloud run