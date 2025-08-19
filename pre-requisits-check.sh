#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✓ $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}✗ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ $message${NC}"
            ;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Kubernetes cluster connectivity
check_kubectl() {
    print_status "INFO" "Checking kubectl installation and cluster connectivity..."
    
    if ! command_exists kubectl; then
        print_status "ERROR" "kubectl is not installed or not in PATH"
        return 1
    fi
    
    if ! kubectl cluster-info >/dev/null 2>&1; then
        print_status "ERROR" "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        return 1
    fi
    
    print_status "OK" "kubectl is installed and can connect to cluster"
    return 0
}

# Function to check Linkerd CLI installation
check_linkerd_cli() {
    print_status "INFO" "Checking Linkerd CLI installation..."
    
    if ! command_exists linkerd; then
        print_status "ERROR" "Linkerd CLI is not installed or not in PATH"
        return 1
    fi
    
    if ! linkerd version --short >/dev/null 2>&1; then
        print_status "ERROR" "Linkerd CLI is installed but not working properly"
        return 1
    fi
    
    print_status "OK" "Linkerd CLI is installed and working"
    return 0
}

# Function to check Linkerd installation in cluster
check_linkerd_installation() {
    print_status "INFO" "Checking Linkerd installation in cluster..."
    
    if ! kubectl get namespace linkerd >/dev/null 2>&1; then
        print_status "ERROR" "Linkerd namespace not found. Linkerd may not be installed."
        return 1
    fi
    
    if ! kubectl get pods -n linkerd --no-headers | grep -q "Running"; then
        print_status "ERROR" "Linkerd pods are not running properly"
        return 1
    fi
    
    print_status "OK" "Linkerd is installed and running in cluster"
    return 0
}

# Function to check Linkerd Viz installation
check_linkerd_viz() {
    print_status "INFO" "Checking Linkerd Viz installation..."
    
    if ! kubectl get pods -n linkerd -l linkerd.io/extension=viz --no-headers | grep -q "Running"; then
        print_status "ERROR" "Linkerd Viz pods are not running properly"
        return 1
    fi
    
    print_status "OK" "Linkerd Viz is installed and running"
    return 0
}

# Function to check Helm installation
check_helm() {
    print_status "INFO" "Checking Helm installation..."
    
    if ! command_exists helm; then
        print_status "WARN" "Helm is not installed. Some demos may not work (dynamic-routing demo requires Helm)"
        return 1
    fi
    
    if ! helm version --short >/dev/null 2>&1; then
        print_status "ERROR" "Helm is installed but not working properly"
        return 1
    fi
    
    print_status "OK" "Helm is installed and working"
    return 0
}

# Function to check curl installation
check_curl() {
    print_status "INFO" "Checking curl installation..."
    
    if ! command_exists curl; then
        print_status "ERROR" "curl is not installed. Required for some demos."
        return 1
    fi
    
    print_status "OK" "curl is installed"
    return 0
}

# Function to check watch command
check_watch() {
    print_status "INFO" "Checking watch command..."
    
    if ! command_exists watch; then
        print_status "WARN" "watch command is not available. Some monitoring features may not work."
        return 1
    fi
    
    print_status "OK" "watch command is available"
    return 0
}

# Function to check cluster resources
check_cluster_resources() {
    print_status "INFO" "Checking cluster resources..."
    
    # Check available nodes
    local node_count=$(kubectl get nodes --no-headers | wc -l)
    if [ "$node_count" -lt 1 ]; then
        print_status "ERROR" "No nodes available in cluster"
        return 1
    fi
    
    print_status "OK" "Cluster has $node_count node(s) available"
    
    # Check if cluster has enough resources (basic check)
    local ready_nodes=$(kubectl get nodes --no-headers | grep -c "Ready")
    if [ "$ready_nodes" -eq 0 ]; then
        print_status "ERROR" "No ready nodes in cluster"
        return 1
    fi
    
    print_status "OK" "Cluster has $ready_nodes ready node(s)"
    return 0
}

# Function to check if required namespaces are available
check_namespace_availability() {
    print_status "INFO" "Checking namespace availability..."
    
    local required_namespaces=("emojivoto" "egress-test" "circuit-breaking-demo" "dynamic-routing" "test" "booksapp" "viz-commands" "injecting-faults" "per-route-metrics" "authorization-policy")
    local conflicts=()
    
    for ns in "${required_namespaces[@]}"; do
        if kubectl get namespace "$ns" >/dev/null 2>&1; then
            conflicts+=("$ns")
        fi
    done
    
    if [ ${#conflicts[@]} -gt 0 ]; then
        print_status "WARN" "The following namespaces already exist and may conflict with demos: ${conflicts[*]}"
        print_status "INFO" "Consider cleaning up these namespaces before running demos"
        return 1
    fi
    
    print_status "OK" "No conflicting namespaces found"
    return 0
}

# Function to check if Linkerd injection is working
check_linkerd_injection() {
    print_status "INFO" "Testing Linkerd injection capability..."
    
    # Create a temporary test pod to verify injection works
    cat <<EOF | kubectl apply -f - >/dev/null 2>&1
apiVersion: v1
kind: Namespace
metadata:
  name: linkerd-test-injection
  annotations:
    linkerd.io/inject: enabled
---
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: linkerd-test-injection
  annotations:
    linkerd.io/inject: enabled
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF
    
    if [ $? -eq 0 ]; then
        # Wait a moment for injection
        sleep 5
        
        # Check if proxy container was injected
        if kubectl get pod test-pod -n linkerd-test-injection -o jsonpath='{.spec.containers[*].name}' | grep -q "linkerd-proxy"; then
            print_status "OK" "Linkerd injection is working properly"
            # Clean up test resources
            kubectl delete namespace linkerd-test-injection >/dev/null 2>&1
            return 0
        else
            print_status "ERROR" "Linkerd injection is not working properly"
            kubectl delete namespace linkerd-test-injection >/dev/null 2>&1
            return 1
        fi
    else
        print_status "ERROR" "Failed to create test resources for injection check"
        return 1
    fi
}

# Function to show usage
usage() {
    echo -e "${BLUE}Linkerd Demo Prerequisites Checker${NC}"
    echo ""
    echo "Usage: $0 [-a|-c|-h]"
    echo "  -a     Run all prerequisite checks"
    echo "  -c     Check cluster connectivity only"
    echo "  -h     Show this help message"
    echo ""
    echo "This script checks all prerequisites needed to run the 0-setup.sh scripts"
    echo "in the Linkerd demo subfolders."
    exit 1
}

# Main function to run all checks
run_all_checks() {
    echo -e "${BLUE}Running all prerequisite checks for Linkerd demos...${NC}"
    echo ""
    
    local all_passed=true
    
    # Run all checks
    check_kubectl || all_passed=false
    check_linkerd_cli || all_passed=false
    check_linkerd_installation || all_passed=false
    check_linkerd_viz || all_passed=false
    check_helm || all_passed=false
    check_curl || all_passed=false
    check_watch || all_passed=false
    check_cluster_resources || all_passed=false
    check_namespace_availability || all_passed=false
    check_linkerd_injection || all_passed=false
    
    echo ""
    if [ "$all_passed" = true ]; then
        print_status "OK" "All prerequisite checks passed! You can now run the demo scripts."
        echo ""
        echo -e "${BLUE}Available demo scripts:${NC}"
        echo "  ./viz-commands/0-setup.sh [-s|-t|-d]"
        echo "  ./injecting-faults/0-setup.sh [-s|-d]"
        echo "  ./per-route-metrics/0-setup.sh [-s|-d]"
        echo "  ./dynamic-routing/0-setup.sh [-s|-d]"
        echo "  ./egress/0-setup.sh [-s|-d]"
        echo "  ./authorization-policy/0-setup.sh [-s|-d]"
    else
        print_status "ERROR" "Some prerequisite checks failed. Please fix the issues before running demos."
        exit 1
    fi
}

# Check cluster connectivity only
check_cluster_only() {
    echo -e "${BLUE}Checking cluster connectivity...${NC}"
    echo ""
    
    check_kubectl
    check_linkerd_installation
    check_cluster_resources
}

# Parse command line arguments
if [ $# -eq 0 ]; then
    usage
fi

while getopts "ach" opt; do
    case ${opt} in
        a )
            run_all_checks
            ;;
        c )
            check_cluster_only
            ;;
        h )
            usage
            ;;
        \? )
            usage
            ;;
    esac
done

exit 0
