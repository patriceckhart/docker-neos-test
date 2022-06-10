#!/bin/bash

flow flow:core:setfilepermissions

chown -R www-data:www-data /data/neos
chmod -R g+rwx /data/neos
chown -R www-data:www-data $FLOW_PATH_TEMPORARY_BASE
chmod -R g+rwx $FLOW_PATH_TEMPORARY_BASE
