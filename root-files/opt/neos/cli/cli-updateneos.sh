#!/bin/bash

if [ "$FLOW_CONTEXT" == "Production" ]; then
	cd /data/neos && composer update --no-dev --no-interaction
else
	cd /data/neos && composer update --no-interaction
fi

cd /data/neos && ./flow flow:core:setfilepermissions

su root -c "/root-files/opt/neos/cli/cli-packagerescan.sh"

if [ ! -z "$1" ]; then
	if [ "$1" == "--force" ]; then

		su root -c "/root-files/opt/neos/cli/cli-doctrinemigrate.sh"
		su root -c "/root-files/opt/neos/cli/cli-doctrineupdate.sh"
		su root -c "/root-files/opt/neos/cli/cli-noderepair.sh"
		
	fi
fi

su root -c "/root-files/opt/neos/cli/cli-flushcache.sh"
