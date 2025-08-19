# Linkerd Documentation

## Table of Contents
1. [Introduction to Service Meshes](#introduction-to-service-meshes)
2. [What is Linkerd?](#what-is-linkerd)
3. [Linkerd Architecture](#linkerd-architecture)
4. [Key Features](#key-features)
5. [Demo Examples](#demo-examples)
6. [Getting Started](#getting-started)
7. [Best Practices](#best-practices)

## Introduction to Service Meshes

A **service mesh** is a dedicated infrastructure layer that handles service-to-service communication in a microservices architecture. It provides a way to control how different parts of your application share data with one another, without requiring changes to the application code itself.

### Why Service Meshes?

In traditional monolithic applications, all components communicate within a single process. However, as applications evolve into microservices, communication becomes more complex:

- **Network Complexity**: Services need to communicate over the network
- **Observability**: Understanding service interactions becomes challenging
- **Security**: Service-to-service authentication and authorization
- **Reliability**: Handling failures, retries, and circuit breaking
- **Traffic Management**: Load balancing, routing, and traffic splitting

### Service Mesh Components

A typical service mesh consists of:

1. **Data Plane**: Sidecar proxies deployed alongside each service instance
2. **Control Plane**: Centralized management and configuration
3. **Service Discovery**: Automatic detection and registration of services
4. **Policy Enforcement**: Security, routing, and reliability policies

## What is Linkerd?

**Linkerd** is a lightweight, ultra-fast service mesh designed for Kubernetes. It provides observability, reliability, and security for microservices without requiring any code changes. Linkerd is built on the Rust programming language, making it extremely fast and resource-efficient.

### Key Characteristics

- **Lightweight**: Minimal resource overhead
- **Fast**: Built in Rust for maximum performance
- **Secure**: Zero-trust security model
- **Observable**: Rich metrics and tracing
- **Kubernetes Native**: Designed specifically for Kubernetes

## Linkerd Architecture

Linkerd follows the standard service mesh architecture with two main components:

### 1. Data Plane (Proxy)
- **Rust-based proxy** deployed as a sidecar container
- Handles all inbound and outbound traffic for each pod
- Provides metrics, logging, and policy enforcement
- Automatically injected into pods via mutating admission webhook

### 2. Control Plane
- **linkerd-controller**: Manages service discovery and routing
- **linkerd-destination**: Provides load balancing and service discovery
- **linkerd-identity**: Handles mTLS certificate management
- **linkerd-proxy-injector**: Automatically injects proxies into pods
- **linkerd-sp-validator**: Validates service profiles
- **linkerd-tap**: Provides real-time request inspection
- **linkerd-viz**: Web UI and metrics dashboard

## Key Features

### 1. **Observability**
Linkerd provides comprehensive observability without requiring application changes:

- **Metrics**: Request rates, latencies, error rates, and success rates
- **Distributed Tracing**: Request flow across services
- **Real-time Monitoring**: Live request inspection and debugging
- **Service Topology**: Visual representation of service dependencies

**Demo**: See [Per-Route Metrics Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/per-route-metrics/) for detailed metrics collection and visualization.

### 2. **Reliability**
Linkerd ensures your services are reliable and resilient:

- **Automatic Retries**: Configurable retry policies for failed requests
- **Circuit Breaking**: Prevents cascading failures
- **Load Balancing**: Intelligent load balancing with health checking
- **Fault Injection**: Testing resilience by injecting failures

**Demo**: See [Circuit Breaking Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/circuit-break/) for failure handling and [Fault Injection Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/injecting-faults/) for resilience testing.

### 3. **Security**
Linkerd implements a zero-trust security model:

- **mTLS**: Automatic mutual TLS encryption between services
- **Identity**: Cryptographic service identity
- **Authorization**: Fine-grained access control policies
- **Network Policies**: Egress and ingress traffic control

**Demo**: See [Authorization Policy Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/authorizaton-policy/) for access control and [Egress Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/egress/) for network policy enforcement.

### 4. **Traffic Management**
Linkerd provides sophisticated traffic management capabilities:

- **Dynamic Routing**: Route traffic based on headers, paths, or other criteria
- **Traffic Splitting**: Gradually shift traffic between service versions
- **Rate Limiting**: Control request rates to prevent overload
- **Canary Deployments**: Safe, gradual service updates

**Demo**: See [Dynamic Routing Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/dynamic-routing/) for header-based routing and [Rate Limiting Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/rate-limit/) for traffic control.

### 5. **Viz Commands**
Linkerd Viz is a monitoring and observability extension that provides powerful CLI commands and a web dashboard for inspecting your service mesh. It collects metrics, generates visualizations, and enables real-time monitoring through the following commands:

- **stat**: View real-time metrics for deployments, pods, and services
  ```bash
  linkerd viz stat deployments
  linkerd viz stat pods
  linkerd viz stat services
  ```

- **edges**: Inspect service mesh topology and circuit breaker status
  ```bash
  linkerd viz edges deployment
  linkerd viz edges pod
  ```

- **tap**: Watch live HTTP traffic between services
  ```bash
  linkerd viz tap deployment/my-app
  linkerd viz tap -n my-namespace deploy/my-service
  ```

- **top**: Display real-time traffic metrics by resource
  ```bash
  linkerd viz top deployment
  linkerd viz top pods
  ```

- **list**: View all mesh-enabled Kubernetes resources
  ```bash
  linkerd viz list
  ```

- **dashboard**: Access the web dashboard for visualization
  ```bash
  linkerd viz dashboard
  ```

**Demo**: See [Viz Commands Demo](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/viz-commands/) for examples of using these observability commands with sample applications.


## Demo Examples

This repository contains comprehensive demos showcasing Linkerd's capabilities:

### 🔍 **Observability**
- **[Per-Route Metrics](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/per-route-metrics/)**: Detailed metrics collection and visualization for individual service routes

### 🛡️ **Security**
- **[Authorization Policy](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/authorizaton-policy/)**: Fine-grained access control and policy enforcement
- **[Egress Control](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/egress/)**: Network policy management for outbound traffic

### 🔄 **Reliability**
- **[Circuit Breaking](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/circuit-break/)**: Failure handling and cascading failure prevention
- **[Fault Injection](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/injecting-faults/)**: Testing service resilience by injecting failures

### 🚦 **Traffic Management**
- **[Dynamic Routing](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/dynamic-routing/)**: Header-based traffic routing and load balancing
- **[Rate Limiting](https://github.com/flysas-tech/kubility-workshops/tree/main/linkerd/rate-limit/)**: Request rate control and traffic shaping

## Installation

### Method 1: Standard Installation (Recommended only for testing)

1. **Install Linkerd CLI**:
   ```bash
   curl -sL https://run.linkerd.io/install | sh
   export PATH=$PATH:$HOME/.linkerd2/bin
   ```

2. **Install Linkerd on your cluster**:
   ```bash
   linkerd install | kubectl apply -f -
   ```

3. **Verify installation**:
   ```bash
   linkerd check
   ```

4. **Install Linkerd Viz (optional)**:
   ```bash
   linkerd viz install | kubectl apply -f -
   ```

### Method 2: Helm Installation Flux

Helm provides more flexibility and customization options for Linkerd installation. This method is recommended for production environments.

#### Prerequisites

- flux
- **Helm 3.x** installed
- **Kubernetes cluster** (1.19+)
- **kubectl** configured
- **Linkerd CLI** installed

#### Step 1: Helm releases

The following files are used for the Linkerd installation with Flux:

1. **linkerd-helm-repository.yaml**
   - Defines where Flux should fetch the Linkerd Helm charts from
   - Points to the official Linkerd Helm repository edge channel
   - Configures check interval for updates

2. **linkerd-viz-helm-release.yaml**
   - Configures the Linkerd visualization dashboard deployment
   - Depends on the control plane being installed first
   - Customizes dashboard access with domain restrictions
   - Disables built-in Prometheus in favor of external monitoring
   - Configures external Grafana URL
   - Sets logging format to JSON

3. **viz-web-ingress.yaml**
   - Sets up external access to the Linkerd dashboard
   - Configures domain routing and service endpoints
   - Maps the dashboard to port 8084

4. **kustomization.yaml**
   - Orchestrates the deployment order of Linkerd components
   - References all required Helm releases:
     - CRDs
     - Control plane
     - Visualization components
     - Helm repository configuration

Additionally, `generate-certificate-for-mTLS.sh` is a helper script that:
- Automates the creation of mTLS certificates
- Generates trust anchor (CA) and issuer certificates
- Includes validation checks for required tools
- Creates certificates with 1-year validity


#### Step 2: Generate Certificates

Linkerd requires TLS certificates for secure communication. You can either use pre-generated certificates or create your own.

**Option A: Use Linkerd's Certificate Generation**

```bash
# Generate certificates using Linkerd CLI
linkerd install --crds | kubectl apply -f -
linkerd install --identity-trust-anchors-file=./ca.crt --identity-issuer-certificate-file=./issuer.crt --identity-issuer-key-file=./issuer.key | kubectl apply -f -
```

**Option B: Generate Custom Certificates**

```bash
# Create a directory for certificates
mkdir -p linkerd-certs
cd linkerd-certs

# Generate CA certificate
step certificate create root.linkerd.cluster.local ca.crt ca.key \
  --profile root-ca --no-password --insecure \
  --not-after=87600h

# Generate issuer certificate
step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
  --profile intermediate-ca --no-password --insecure \
  --ca ca.crt --ca-key ca.key \
  --not-after=87600h

# Verify certificates
step certificate inspect ca.crt
step certificate inspect issuer.crt
```

Please check `generate-certificate-for-mTLS.sh`.


#### Step 5: Verify Installation

```bash
# Check Linkerd status
linkerd check

# Verify Helm releases
helm list -n linkerd
helm list -n linkerd-viz

# Check pods status
kubectl get pods -n linkerd
kubectl get pods -n linkerd-viz
```

### Advanced Helm Configuration

#### Custom Values File

Create a `linkerd-values.yaml` file for custom configuration:

```yaml
# linkerd-values.yaml
global:
  clusterDomain: cluster.local

identity:
  issuer:
    scheme: kubernetes.io/tls

proxy:
  resources:
    cpu:
      request: 100m
      limit: 200m
    memory:
      request: 128Mi
      limit: 256Mi

controllerImage:
  name: cr.l5d.io/linkerd/controller
  tag: stable-2.13.0

debugContainer:
  image:
    name: cr.l5d.io/linkerd/debug
    tag: stable-2.13.0

policyValidator:
  image:
    name: cr.l5d.io/linkerd/policy-validator
    tag: stable-2.13.0

proxyInjector:
  image:
    name: cr.l5d.io/linkerd/proxy-injector
    tag: stable-2.13.0

spValidator:
  image:
    name: cr.l5d.io/linkerd/sp-validator
    tag: stable-2.13.0

tap:
  image:
    name: cr.l5d.io/linkerd/tap
    tag: stable-2.13.0

web:
  image:
    name: cr.l5d.io/linkerd/web
    tag: stable-2.13.0
```

Install with custom values:

```bash
helm install linkerd-control-plane linkerd/linkerd-control-plane \
  --namespace linkerd \
  --values linkerd-values.yaml \
  --set-file identityTrustAnchorsPEM=./ca.crt \
  --set-file identity.issuer.tls.crtPEM=./issuer.crt \
  --set-file identity.issuer.tls.keyPEM=./issuer.key \
  --wait
```

#### Production Considerations

1. **Certificate Management**:
   ```bash
   # Set up certificate rotation
   linkerd upgrade --identity-trust-anchors-file=./ca.crt \
     --identity-issuer-certificate-file=./issuer.crt \
     --identity-issuer-key-file=./issuer.key | kubectl apply -f -
   ```

2. **Resource Limits**:
   ```yaml
   # In your values file
   proxy:
     resources:
       cpu:
         request: 200m
         limit: 500m
       memory:
         request: 256Mi
         limit: 512Mi
   ```

3. **High Availability**:
   ```yaml
   # Enable HA mode
   controllerReplicas: 3
   webhookFailurePolicy: Ignore
   ```

### Troubleshooting Helm Installation

#### Common Issues

1. **Certificate Errors**:
   ```bash
   # Verify certificate validity
   step certificate inspect ca.crt
   step certificate inspect issuer.crt
   
   # Check certificate expiration
   kubectl get secret -n linkerd linkerd-identity-issuer -o yaml
   ```

2. **Helm Chart Not Found**:
   ```bash
   # Re-add repository
   helm repo remove linkerd
   helm repo add linkerd https://helm.linkerd.io/stable
   helm repo update
   ```

3. **Installation Timeout**:
   ```bash
   # Check pod status
   kubectl get pods -n linkerd
   kubectl describe pods -n linkerd
   
   # Check events
   kubectl get events -n linkerd --sort-by='.lastTimestamp'
   ```

#### Useful Helm Commands

```bash
# List all Helm releases
helm list --all-namespaces

# Get release status
helm status linkerd-control-plane -n linkerd

# Get release values
helm get values linkerd-control-plane -n linkerd

# Upgrade Linkerd
helm upgrade linkerd-control-plane linkerd/linkerd-control-plane \
  --namespace linkerd \
  --reuse-values

# Uninstall Linkerd
helm uninstall linkerd-control-plane -n linkerd
helm uninstall linkerd-crds -n linkerd
kubectl delete namespace linkerd
```

### Running the Demos

Each demo includes a `0-setup.sh` script for easy execution:

```bash
# Navigate to any demo directory
cd demo/circuit-break/

# Run the demo
./0-setup.sh -s

# Clean up when done
./0-setup.sh -d
```

### Useful Commands

```bash
# Check Linkerd status
linkerd check

# View service metrics
linkerd viz stat svc

# Inspect proxy logs
kubectl logs -n <namespace> <pod> -c linkerd-proxy

# Debug service discovery
linkerd diagnostics proxy-metrics -n <namespace> <pod>
```

## Best Practices

### 1. **Start Small**
- Begin with a single namespace or service
- Gradually expand to more services
- Monitor resource usage and performance

### 2. **Security First**
- Enable mTLS from the start
- Implement authorization policies early
- Use network policies for egress control

### 3. **Observability**
- Set up monitoring and alerting
- Use service profiles for detailed metrics
- Implement distributed tracing for complex flows

### 4. **Traffic Management**
- Use canary deployments for safe updates
- Implement circuit breakers for resilience
- Configure appropriate retry policies

### 5. **Resource Management**
- Monitor proxy resource usage
- Use resource limits and requests
- Optimize for your specific workload

### 6. **Testing**
- Test failure scenarios regularly
- Use fault injection to validate resilience
- Monitor performance impact

## Troubleshooting

### Common Issues

1. **Proxy Injection Fails**
   - Check namespace annotations
   - Verify mutating admission webhook
   - Check pod security policies

2. **mTLS Issues**
   - Verify identity service is running
   - Check certificate validity
   - Review network policies

3. **Performance Problems**
   - Monitor proxy resource usage
   - Check for proxy bottlenecks
   - Review service profiles

## Additional Resources

- [Official Linkerd Documentation](https://linkerd.io/docs/)
- [Linkerd GitHub Repository](https://github.com/linkerd/linkerd2)
- [Linkerd Community](https://linkerd.io/community/)
- [Linkerd Blog](https://linkerd.io/blog/)
