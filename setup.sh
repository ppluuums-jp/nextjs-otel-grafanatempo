#!/bin/bash

source env.sh

if [[ -z "${PROJECT_ID}" ]] || [[ -z "${REGION}" ]] || [[ -z "${SERVICE}" ]] || [[ -z "${GRAFANA_CLOUD_API_KEY}" ]] || [[ -z "${GRAFANA_CLOUD_TEMPO_ENDPOINT}" ]] || [[ -z "${GRAFANA_CLOUD_TEMPO_USERNAME}" ]] || [[ -z "${GRAFANA_CLOUD_PROMETHEUS_URL}" ]] || [[ -z "${GRAFANA_CLOUD_PROMETHEUS_USERNAME}" ]] || [[ -z "${GRAFANA_CLOUD_LOKI_URL}" ]] || [[ -z "${GRAFANA_CLOUD_LOKI_USERNAME}" ]]; then
  echo "env isnt set"
  exit 1
fi

CONFIG_FILE="./collector/config.yaml"
SERVICE_FILE="./cloudrun/service.yaml"

sed -i -e "s/GRAFANA_CLOUD_API_KEY/${GRAFANA_CLOUD_API_KEY}/g" $CONFIG_FILE
sed -i -e "s|GRAFANA_CLOUD_TEMPO_ENDPOINT|${GRAFANA_CLOUD_TEMPO_ENDPOINT}|g" $CONFIG_FILE
sed -i -e "s/GRAFANA_CLOUD_TEMPO_USERNAME/${GRAFANA_CLOUD_TEMPO_USERNAME}/g" $CONFIG_FILE
sed -i -e "s|GRAFANA_CLOUD_PROMETHEUS_URL|${GRAFANA_CLOUD_PROMETHEUS_URL}|g" $CONFIG_FILE
sed -i -e "s/GRAFANA_CLOUD_PROMETHEUS_USERNAME/${GRAFANA_CLOUD_PROMETHEUS_USERNAME}/g" $CONFIG_FILE
sed -i -e "s|GRAFANA_CLOUD_LOKI_URL|${GRAFANA_CLOUD_LOKI_URL}|g" $CONFIG_FILE
sed -i -e "s/GRAFANA_CLOUD_LOKI_USERNAME/${GRAFANA_CLOUD_LOKI_USERNAME}/g" $CONFIG_FILE
sed -i -e "s/SERVICE/${SERVICE}/g" $SERVICE_FILE
sed -i -e "s|REGION|${REGION}|g" $SERVICE_FILE
sed -i -e "s/PROJECT_ID/${PROJECT_ID}/g" $SERVICE_FILE

echo "done with SEDs"

gcloud artifacts repositories create nextjs-otel-grafanatempo-repo --repository-format=docker --location=${REGION}  --project=${PROJECT_ID}

docker build -t ${SERVICE} . --platform linux/amd64
gcloud auth configure-docker ${REGION}.pkg.dev
docker tag ${SERVICE} ${REGION}-docker.pkg.dev/${PROJECT_ID}/nextjs-otel-grafanatempo-repo/${SERVICE}
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/nextjs-otel-grafanatempo-repo/${SERVICE}

docker build -t otel-collector ./collector/ --platform linux/amd64
gcloud auth configure-docker ${REGION}.pkg.dev
docker tag otel-collector ${REGION}-docker.pkg.dev/${PROJECT_ID}/nextjs-otel-grafanatempo-repo/otel-collector
docker push ${REGION}-docker.pkg.dev/${PROJECT_ID}/nextjs-otel-grafanatempo-repo/otel-collector

echo "done with build and push"

gcloud run services replace ./cloudrun/service.yaml --region=${REGION}  --project=${PROJECT_ID}

echo "done with run deploy"