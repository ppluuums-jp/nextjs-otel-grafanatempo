#!/bin/bash

source env.sh

if [[ -z "${PROJECT_ID}" ]] || [[ -z "${REGION}" ]] || [[ -z "${SERVICE}" ]] || [[ -z "${GRAFANA_CLOUD_API_KEY}" ]] || [[ -z "${GRAFANA_CLOUD_TEMPO_ENDPOINT}" ]] || [[ -z "${GRAFANA_CLOUD_TEMPO_USERNAME}" ]] || [[ -z "${GRAFANA_CLOUD_PROMETHEUS_URL}" ]] || [[ -z "${GRAFANA_CLOUD_PROMETHEUS_USERNAME}" ]] || [[ -z "${GRAFANA_CLOUD_LOKI_URL}" ]] || [[ -z "${GRAFANA_CLOUD_LOKI_USERNAME}" ]]; then
  echo "env isnt set"
  exit 1
fi

docker rmi ${SERVICE}
docker rmi ${REGION}-docker.pkg.dev/${PROJECT_ID}/nextjs-otel-grafanatempo-repo/${SERVICE}
docker rmi otel-collector
docker rmi ${REGION}-docker.pkg.dev/${PROJECT_ID}/nextjs-otel-grafanatempo-repo/otel-collector

gcloud artifacts repositories delete nextjs-otel-grafanatempo-repo --location=${REGION} --project=${PROJECT_ID} --quiet

gcloud run services delete ${SERVICE} --region=${REGION} --project=${PROJECT_ID} --quiet
