#!/bin/bash

set -euo pipefail

tmpdir=${TMPDIR:-/tmp}
uid=${UID}

name="${1}"
value="${2}"
title="${3}"
body="${4}"

id_file="$tmpdir/notify-progress-$uid-$name.id"

id=$(cat $id_file 2>/dev/null || echo -n 0)

echo $id

id=$(notify-send --hint "int:value:$value" --print-id --replace-id "$id" "$title" "$body")

echo $id

echo -n "$id" > $id_file
