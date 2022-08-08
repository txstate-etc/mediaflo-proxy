#!/usr/bin/env sh
set -eu

envsubst '${ENSEMBLE_HOST} ${MFREV_HOST} ${SERVICES_OEMBED_REDIR_HOST}' < /etc/nginx/locations.conf.template > /etc/nginx/locations.conf

exec "$@"
