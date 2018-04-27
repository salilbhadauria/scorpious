#!/bin/bash

# Deploy custom services and frameworks
bash deploy_service.sh aries-api-rest/marathon.json aries-api-rest/env_vars.sh
bash deploy_service.sh baile/marathon.json baile/env_vars.sh
bash deploy_service.sh baile-haproxy/marathon.json baile-haproxy/env_vars.sh
bash deploy_service.sh cortex-api-rest/marathon.json cortex-api-rest/env_vars.sh
bash deploy_service.sh logstash/marathon.json logstash/env_vars.sh
bash deploy_service.sh orion-api-rest/marathon.json orion-api-rest/env_vars.sh
bash deploy_service.sh um-service/marathon.json um-service/env_vars.sh

# Deploy online prediction
if [ $ONLINE_PREDICTION = "true" ]; then
  # Stop postgresql servers if running
  service postgresql stop

  # Initialize redshift
  bash postgres/postgres_init.sh

  # Deploy custom services
  bash deploy_service.sh argo-api-rest/marathon.json argo-api-rest/env_vars.sh
  bash deploy_service.sh pegasus-api-rest/marathon.json pegasus-api-rest/env_vars.sh
  bash deploy_service.sh taurus/marathon.json taurus/env_vars.sh
fi
