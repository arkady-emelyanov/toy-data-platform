#!/usr/bin/env bash
set -eo pipefail

HOST=$(hostname -s)
POD_ID=${HOST##*-}
BROKER_ID=$(( ${POD_ID} + 1 ))

export KAFKA_HEAP_OPTS="-Xmx256M -Xms256M"
export KAFKA_BROKER_ID=${BROKER_ID}
exec /usr/bin/start-kafka.sh
