#!/usr/bin/env bash
set -eo pipefail

OK=$(echo ruok | nc 127.0.0.1 ${1})
if [ "$OK" == "imok" ]; then
	exit 0
fi

exit 1
