#!/bin/bash

/usr/bin/supervisord
sleep 10
curl http://127.0.0.1:3000/api/datasources \
    -u admin:admin \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"name":"graphite","type":"graphite","url":"http://127.0.0.1/graphite","access":"proxy","isDefault":true}'
