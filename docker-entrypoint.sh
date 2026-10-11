#!/bin/sh
# Starts the dashboard with the defaults baked into the image. Override them
# with DATASET, PORT and BOKEH_ALLOW_WS_ORIGIN; any arguments are passed
# through to `panel serve` (e.g. --num-procs 4).
set -eu

: "${DATASET:?set DATASET to a dataset URL, JSON scene list, or /data path}"

exec python -m panel serve "$DASHBOARD_APP" \
    --address 0.0.0.0 \
    --port "${PORT:-8080}" \
    --liveness \
    "$@" \
    --args "$DATASET"
