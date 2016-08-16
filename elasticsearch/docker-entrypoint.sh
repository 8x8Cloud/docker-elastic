#!/bin/bash

# Taken from https://github.com/docker-library/elasticsearch/blob/1e62c7d84cc549883e3404d79356d3fadfdf6c3d/2.3/docker-entrypoint.sh,
# the standard Docker image.
set -e

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
# allow the container to be started with `--user`
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	# Grab a free 30 day trial license on first run of this container.
	if [ ! -f /usr/share/elasticsearch/.docker-configured ]; then
		chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/
		plugin install license && echo 1 > /usr/share/elasticsearch/.docker-configured
	fi

	set -- su-exec elasticsearch "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
