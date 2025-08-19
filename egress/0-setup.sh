#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

demo-egress() {
    echo -e "${BLUE}Setting up egress-test namespace...${NC}"
    kubectl apply -f egress-test-namespace.yaml
    watch -n 1 "linkerd dg proxy-metrics -n egress-test po/http-client | grep outbound_http_route_request_statuses_total"
    echo -e "${BLUE}Configuring egress policy...${NC}"
    kubectl apply -f egress-allow.yaml
    kubectl patch egressnetwork -n egress-test all-egress-traffic  -p '{"spec":{"trafficPolicy": "Deny"}}' --type=merge
    watch -n 1 "linkerd dg proxy-metrics -n egress-test po/http-client | grep outbound_http_route_request_statuses_total"
    echo -e "${BLUE}Configuring egress routes for httpbin.org...${NC}"
    kubectl apply -f egress-routes.yaml
    watch -n 1 "linkerd dg proxy-metrics -n egress-test po/http-client | grep outbound_http_route_request_statuses_total"
    echo -e "${YELLOW}Still other domains will not work...${NC}" && sleep 5
    watch -n 1 "linkerd dg proxy-metrics -n egress-test po/http-client-postman | grep outbound_http_route_request_statuses_total"
    echo -e "${BLUE}Enable egress traffic back to cluster as default behavior...${NC}"
    kubectl delete httproute -n egress-test httpbin-get
    kubectl apply -f egress-back-cluster.yaml
    watch -n 1 "linkerd dg proxy-metrics -n egress-test po/http-client | grep outbound_http_route_request_statuses_total"
    echo -e "${YELLOW}Checking that both pods are going to the internal-egress service...${NC}" && sleep 5
    kubectl logs  deploy/internal-egress -n egress-test -f -c legacy-app
    echo -e "${GREEN}Done! If you want to remove the egress-test namespace, run ./0-setup.sh -d${NC}"
}

usage(){
      echo -e "${BLUE}Linkerd Egress Demo Setup${NC}"
      echo ""
      echo "Usage: $0 [-s|-d]"
      echo "  -s: Execute full egress demo"
      echo "  -d: Delete egress-test namespace"
      exit 1
}
  # Check if no arguments provided
  if [ $# -eq 0 ]; then
    usage
  fi

while getopts "sd" flag; do
  case "${flag}" in
    s)
      echo -e "${BLUE}Executing demo-egress...${NC}"
      demo-egress
      ;;
    d)
        echo -e "${BLUE}Deleting egress-test namespace...${NC}"
        kubectl delete ns egress-test
        echo -e "${GREEN}✓ Egress-test namespace deleted successfully${NC}"
      ;;
    *)
      usage
      ;;
  esac
done
