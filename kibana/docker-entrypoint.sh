#!/bin/bash
if [ -z "$ELASTICSEARCH_HOST" ]; then 
  ELASTICSEARCH_HOST="http://elasticsearch:9200"
fi

/usr/share/kibana/bin/kibana -e ${ELASTICSEARCH_HOST} 
