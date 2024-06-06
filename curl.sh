#!/bin/bash

source env.sh

CLOUD_RUN_URL=$(gcloud run services describe ${SERVICE} --region=${REGION} --format="value(status.url)")
ACCESS_TOKEN=$(gcloud auth print-identity-token)
curl -H "Authorization: Bearer ${ACCESS_TOKEN}" $CLOUD_RUN_URL -v
