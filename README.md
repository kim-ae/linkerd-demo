# Linkerd Demo Examples

This directory contains examples demonstrating various Linkerd features and use cases.

Please run pre-requisits-check.sh before starting to check the demos.

## Observability

### Viz Commands
Located in `/viz-commands`
- Demonstrates various Linkerd CLI commands for observability
- Shows how to monitor service metrics, edges, and live traffic
- Includes examples of using `linkerd viz` commands:
  - `stat`: View deployment/pod/service metrics
  - `edges`: Check circuit breaker and service mesh edges
  - `tap`: Watch live HTTP traffic
  - `top`: Display real-time traffic metrics
  - `list`: View mesh-enabled resources
  - `dashboard`: Access web dashboard
- Contains setup scripts and sample application (books service)
- See `0-setup.sh` for implementation and available commands


## Traffic Management

### HTTPRoute

#### Per Route Metrics with Profiles (DEPRECATED)

Located in `/per-route-metrics`
- Demonstrates how to get metrics for individual HTTP routes using HTTPRoute resources
- Shows configuration of route-specific metrics collection and visualization
- Includes example service profiles for fine-grained metrics
- Contains setup scripts and sample applications (books service, authors service, webapp)
- See `books-routes.yaml` and `service-profiles.yaml` for implementation


#### Fault Injection

Located in `/injecting-faults`
- Demonstrates HTTP traffic splitting and fault injection using HTTPRoute
- Example shows how to split traffic between a normal service and an error-injecting service
- See `faulty-backend.yaml` for implementation

#### Dynamic Routing
Located in `/dynamic-routing`
- Demonstrates dynamic request routing based on HTTP headers
- Shows how to route traffic between different backend services
- Example uses header-based routing to direct requests to alternate backends
- See `httproute.yaml` for implementation

### TLSRoute
Located in `/egress`
- Shows TLS-based traffic routing capabilities using TLSRoute resources
- Demonstrates secure service-to-service communication with external services
- See `egress-routes.yaml` for TLSRoute configuration example

### EgressNetwork
Located in `/egress`
- Examples of controlling outbound traffic from the mesh
- Shows how to configure egress policies and routes
- Demonstrates both allowing and denying external traffic
- See `egress-allow.yaml` and `egress-routes.yaml`

## Security

### Authorization
Located in `/authorization-policy`
- Demonstrates Linkerd's authorization policies
- Shows how to secure service-to-service communication
- Includes examples of HTTP route-level authorization
- See various policy configurations in `probe-route.yaml`, `http-get-route.yaml`, etc.

## Reliability

### Circuit Breaking
Located in `/circuit-break`
- Shows how to implement circuit breaking patterns
- Demonstrates failure handling and service resilience
- Includes examples with both successful and failing services
- See `circuit-breaking-demo.yaml`

### Rate Limiting
Located in `/rate-limit`
- Examples of rate limiting configuration
- Shows how to protect services from overwhelming traffic
- Demonstrates rate limit policies and their effects

