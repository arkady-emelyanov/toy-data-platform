#!/usr/bin/env bash
set -eo pipefail

HOST=$(hostname -s)
POD_ID=${HOST##*-}
MY_ID=$(( ${POD_ID} + 1 ))

export ZOO_MY_ID=${MY_ID}
exec /docker-entrypoint.sh zkServer.sh start-foreground
