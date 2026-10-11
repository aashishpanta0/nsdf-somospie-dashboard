#!/bin/sh
# Runs `python -m panel serve <dashboard>`, filling in whatever the caller did
# not pass from the defaults saved in the image:
#
#   --address   default $ADDRESS (0.0.0.0)
#   --port      default $PORT (this dashboard's port)
#   --args      default $DATASET; a first argument that is not an option is
#               taken as the dataset too, e.g. `docker run <image> /data/x.idx`
#
# Every other argument is passed to `panel serve` unchanged.
set -eu

dataset=$DATASET
if [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; then
    dataset=$1
    shift
fi

# has FLAG ARGS...: whether FLAG (or FLAG=value) is among the panel serve
# options, i.e. before --args, whose values belong to the dashboard.
has() {
    flag=$1
    shift
    for arg do
        case $arg in
            "$flag" | "$flag"=*) return 0 ;;
            --args) return 1 ;;
        esac
    done
    return 1
}

has --args "$@" || set -- "$@" --args "$dataset"
has --port "$@" || set -- --port "$PORT" "$@"
has --address "$@" || set -- --address "$ADDRESS" "$@"

exec python -m panel serve "$DASHBOARD_APP" "$@"
