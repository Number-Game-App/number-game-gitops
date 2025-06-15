# Architecture Guide

## System Overview

The Enterprise Number Game Platform demonstrates production-ready DevOps practices through a cloud-native architecture.

## Architecture Diagram

```mermaid
graph TB
    subgraph "Frontend"
        UI[Game Interface<br/>HTML5 + JS]
    end
    
    subgraph "Kubernetes Cluster"
        ING[Nginx Ingress]
        APP[Game Pods<br/>3 replicas]
        SVC[Service]
    end
    
    subgraph "Monitoring"
        PROM[Prometheus]
        GRAF[Grafana]
        ALERT[AlertManager]
    end
    
    subgraph "GitOps"
        GIT[Git Repository]
        ARGO[ArgoCD]
        HELM[Helm Charts]
    end
    
    UI --> ING
    ING --> SVC
    SVC --> APP
    APP --> PROM
    PROM --> GRAF
    PROM --> ALERT
    GIT --> ARGO
    ARGO --> HELM
    HELM --> APP