# BooksApp Authorization Policies Diagram

## Authorization Architecture Overview

```mermaid
graph TB
    %% External Clients
    External[🌐 External Clients] --> Traffic[🚗 Traffic Generator]
    
    %% Application Services
    Traffic --> Webapp[🌐 Webapp<br/>Identity: webapp.booksapp.serviceaccount.identity.linkerd.cluster.local<br/>3 replicas]
    Webapp --> Authors[👥 Authors Service<br/>Port: 7001<br/>1 replica]
    Webapp --> Books[📚 Books Service<br/>Identity: books.booksapp.serviceaccount.identity.linkerd.cluster.local<br/>1 replica]
    Books --> Authors
    
    %% Server Definition
    subgraph "🔒 Authors Server (policy.linkerd.io/v1beta3)"
        Server[Authors Server<br/>Selector: app=authors, project=booksapp<br/>Port: service<br/>Default: DENY ALL]
    end
    
    %% HTTP Routes and Policies
    subgraph "🛣️ HTTP Routes (gateway.networking.k8s.io/v1)"
        ProbeRoute[📡 Probe Route<br/>GET /ping]
        GetRoute[📖 GET Route<br/>GET /authors.json<br/>GET /authors/*<br/>HEAD /authors/*]
        ModifyRoute[✏️ Modify Route<br/>POST /authors.json<br/>PUT /authors/*<br/>DELETE /authors/*]
    end
    
    %% Authentication Methods
    subgraph "🔐 Authentication Methods"
        NetworkAuth[🌍 Network Authentication<br/>CIDR: 0.0.0.0/0, ::/0<br/>Open for health checks]
        GetAuthn[MeshTLS Authentication<br/>Identities:<br/>• books.booksapp.serviceaccount.identity.linkerd.cluster.local<br/>• webapp.booksapp.serviceaccount.identity.linkerd.cluster.local]
        ModifyAuthn[MeshTLS Authentication<br/>Identity:<br/>• webapp.booksapp.serviceaccount.identity.linkerd.cluster.local ONLY]
    end
    
    %% Authorization Policies
    subgraph "🛡️ Authorization Policies (policy.linkerd.io/v1alpha1)"
        ProbePolicy[Probe Authorization Policy<br/>Target: authors-probe-route<br/>Auth: Network Authentication]
        GetPolicy[GET Authorization Policy<br/>Target: authors-get-route<br/>Auth: MeshTLS (books + webapp)]
        ModifyPolicy[Modify Authorization Policy<br/>Target: authors-modify-route<br/>Auth: MeshTLS (webapp only)]
    end
    
    %% Connections
    Authors -.-> Server
    Server -.-> ProbeRoute
    Server -.-> GetRoute
    Server -.-> ModifyRoute
    
    ProbeRoute -.-> NetworkAuth
    NetworkAuth -.-> ProbePolicy
    
    GetRoute -.-> GetAuthn
    GetAuthn -.-> GetPolicy
    
    ModifyRoute -.-> ModifyAuthn
    ModifyAuthn -.-> ModifyPolicy
    
    %% Service Identity Connections
    Webapp -.-> GetAuthn
    Books -.-> GetAuthn
    Webapp -.-> ModifyAuthn
    
    %% Styling
    classDef service fill:#e3f2fd,stroke:#1976d2,stroke-width:3px
    classDef server fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef route fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef auth fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef policy fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef external fill:#f1f8e9,stroke:#689f38,stroke-width:2px
    
    class Webapp,Authors,Books service
    class Server server
    class ProbeRoute,GetRoute,ModifyRoute route
    class NetworkAuth,GetAuthn,ModifyAuthn auth
    class ProbePolicy,GetPolicy,ModifyPolicy policy
    class External,Traffic external
```

## Detailed Policy Breakdown

### 1. **Authors Server Configuration**
- **Type**: Server (policy.linkerd.io/v1beta3)
- **Selector**: `app=authors, project=booksapp`
- **Port**: `service` (7001)
- **Default Behavior**: **DENY ALL** - requires explicit authorization policies

### 2. **Probe Route (/ping)**
- **HTTP Route**: `GET /ping`
- **Authentication**: Network Authentication
- **Network Access**: `0.0.0.0/0` and `::/0` (open to all networks)
- **Purpose**: Health checks and readiness probes
- **Authorization**: Anyone can access health check endpoints

### 3. **GET Route (/authors/*)**
- **HTTP Routes**:
  - `GET /authors.json`
  - `GET /authors/*` (PathPrefix)
  - `HEAD /authors/*` (PathPrefix)
- **Authentication**: MeshTLS Authentication
- **Authorized Identities**:
  - `books.booksapp.serviceaccount.identity.linkerd.cluster.local`
  - `webapp.booksapp.serviceaccount.identity.linkerd.cluster.local`
- **Purpose**: Read access to author data

### 4. **Modify Route (/authors/*)**
- **HTTP Routes**:
  - `POST /authors.json`
  - `PUT /authors/*` (PathPrefix)
  - `DELETE /authors/*` (PathPrefix)
- **Authentication**: MeshTLS Authentication
- **Authorized Identity**: 
  - `webapp.booksapp.serviceaccount.identity.linkerd.cluster.local` **ONLY**
- **Purpose**: Write/modify access to author data (restricted to frontend)

## Access Control Matrix

| Service | Identity | /ping | GET /authors/* | POST/PUT/DELETE /authors/* |
|---------|----------|-------|----------------|---------------------------|
| **Webapp** | `webapp.booksapp.serviceaccount.identity.linkerd.cluster.local` | ✅ | ✅ | ✅ |
| **Books** | `books.booksapp.serviceaccount.identity.linkerd.cluster.local` | ✅ | ✅ | ❌ |
| **External** | Any network | ✅ | ❌ | ❌ |
| **Unauthenticated** | No identity | ❌ | ❌ | ❌ |

## Security Model

### **Principle of Least Privilege**
- **Health Checks**: Open access for monitoring
- **Read Operations**: Allowed for both webapp and books services
- **Write Operations**: Restricted to webapp service only
- **Default Deny**: All other traffic is blocked

### **Service Mesh Security**
- **MeshTLS**: Automatic mTLS between services
- **Identity-based**: Access control based on service account identities
- **Network-based**: Health checks use network-level authentication
- **Route-based**: Different policies for different HTTP paths and methods

## Key Security Features

1. **🔒 Default Deny**: Server defaults to deny all traffic
2. **🆔 Identity-based Auth**: Uses Linkerd service identities
3. **🌐 Network Auth**: Open access for health checks
4. **📋 Method-specific**: Different policies for GET vs POST/PUT/DELETE
5. **🛡️ Path-based**: Different policies for different URL paths
6. **🔐 mTLS**: Automatic mutual TLS between services 