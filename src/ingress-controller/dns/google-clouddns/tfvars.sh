#!/bin/bash -e

JSON="$(echo "$creds" | jq -r '.["serviceaccount.json"]' )"
PROJECT="$(echo "$JSON" | jq -r '.project_id' )"

tfvars="$(echo "$tfvars" | jq '.PROJECT="'$PROJECT'"' )"
