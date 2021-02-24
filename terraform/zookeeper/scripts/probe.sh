#!/usr/bin/env bash
set -eo pipefail

OK=$(echo ruok | nc -w 2 127.0.0.1 ${1})
if [ "$OK" == "imok" ]; then
	exit 0
fi

exit 1
