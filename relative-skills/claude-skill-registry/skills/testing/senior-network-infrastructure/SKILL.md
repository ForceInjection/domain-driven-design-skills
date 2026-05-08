---

# === CORE IDENTITY ===
name: senior-network-infrastructure
title: Senior Network Infrastructure Skill Package
description: Network infrastructure specialist for VPC/VNet design, VPN configuration, firewall policies, load balancing, and multi-cloud networking. Includes topology analysis, security group generation, and network compliance auditing.
domain: engineering
subdomain: network-infrastructure

# === WEBSITE DISPLAY ===
difficulty: advanced
time-saved: "70% reduction in network configuration time"
frequency: "Weekly for infrastructure changes, daily during deployments"
use-cases:
  - Designing VPC/VNet architecture for multi-region applications
  - Configuring site-to-site VPN between cloud providers
  - Generating firewall rules and security groups
  - Planning subnet allocation and CIDR blocks
  - Auditing network security compliance

# === RELATIONSHIPS ===
related-agents: [cs-network-engineer, cs-devops-engineer, cs-architect]
related-skills: [engineering-team/senior-devops, engineering-team/senior-security]
related-commands: []
orchestrated-by: [cs-network-engineer]

# === TECHNICAL ===
dependencies:
  scripts:
    - vpn_configurator.py
    - firewall_policy_generator.py
    - network_topology_analyzer.py
    - subnet_planner.py
  references:
    - vpc_design_patterns.md
    - network_security_guide.md
    - cloud_networking.md
  assets: []
compatibility:
  python-version: 3.8+
  platforms: [macos, linux, windows]
tech-stack: [Python 3.8+, Terraform, AWS VPC, Azure VNet, GCP VPC, BGP, IPSec, WireGuard]

# === EXAMPLES ===
examples:
  - title: "VPN Configuration"
    input: "Configure site-to-site VPN between AWS and Azure"
    output: "Terraform configuration for AWS VPN Gateway and Azure VPN Gateway with IPSec tunnel"
  - title: "Firewall Rules"
    input: "Generate security groups for 3-tier web application"
    output: "AWS Security Groups for web, app, and database tiers with least-privilege rules"
  - title: "Subnet Planning"
    input: "Plan subnets for /16 VPC with 3 AZs"
    output: "CIDR allocation plan with public, private, and database subnets per AZ"

# === ANALYTICS ===
stats:
  downloads: 0
  stars: 0
  rating: 0.0
  reviews: 0

# === VERSIONING ===
version: v1.0.0
author: Claude Skills Team
contributors: []
created: 2025-12-16
updated: 2025-12-16
license: MIT

# === DISCOVERABILITY ===
tags: [network, infrastructure, VPN, firewall, VPC, load-balancer, security-groups, routing, DNS, multi-cloud, networking, AWS, GCP, Azure, engineering]
featured: false
verified: true
---


# Senior Network Infrastructure

Complete toolkit for network infrastructure design, VPN configuration, and security policy management across AWS, Azure, and GCP.

## Overview

This skill provides comprehensive network infrastructure capabilities through four core Python automation tools and extensive reference documentation. Whether designing VPC architectures, configuring VPNs, generating firewall policies, or planning subnet allocations, this skill delivers production-ready network configurations.

Senior network engineers use this skill for cloud networking (AWS VPC, Azure VNet, GCP VPC), VPN configuration (site-to-site, point-to-site), firewall policy management (security groups, NACLs, NSGs), load balancing, and network security compliance. The skill covers multi-cloud connectivity, network segmentation, and zero-trust architecture patterns.

**Core Value:** Reduce network configuration time by 70%+ while improving security posture and ensuring consistent, compliant network architectures across cloud platforms.

## Quick Start

### Main Capabilities

This skill provides four core capabilities through automated scripts:

```bash
# Script 1: VPN Configurator - Generate VPN configurations
python scripts/vpn_configurator.py --provider aws --type site-to-site --output terraform

# Script 2: Firewall Policy Generator - Create security rules
python scripts/firewall_policy_generator.py --cloud aws --tier 3-tier --output json

# Script 3: Network Topology Analyzer - Analyze network design
python scripts/network_topology_analyzer.py --input vpc-config.json --check-redundancy

# Script 4: Subnet Planner - Plan CIDR allocation
python scripts/subnet_planner.py --vpc-cidr 10.0.0.0/16 --azs 3 --tiers 3
```

## Core Capabilities

- **VPC/VNet Design** - Multi-region VPC architecture, hub-spoke topology, transit gateway patterns for AWS, Azure, GCP
- **VPN Configuration** - Site-to-site VPN, point-to-site VPN, IPSec tunnels, WireGuard configurations
- **Firewall Policies** - Security groups, NACLs, NSGs, WAF rules with least-privilege principles
- **Load Balancing** - ALB/NLB configuration, health checks, target groups, SSL termination
- **Subnet Planning** - CIDR allocation, IP address management, subnet sizing for optimal utilization
- **Network Security** - Network segmentation, zero-trust architecture, DDoS mitigation, compliance auditing

## Python Tools

### 1. VPN Configurator

Generate production-ready VPN configurations for multi-cloud connectivity.

**Key Features:**
- AWS Site-to-Site VPN and Client VPN generation
- Azure VPN Gateway configuration
- GCP Cloud VPN setup
- IPSec and IKEv2 tunnel parameters
- High availability with redundant tunnels
- Output in Terraform, CloudFormation, or CLI commands

**Common Usage:**
```bash
# AWS Site-to-Site VPN
python scripts/vpn_configurator.py --provider aws --type site-to-site --remote-ip 203.0.113.1 --output terraform

# Azure VPN Gateway
python scripts/vpn_configurator.py --provider azure --type site-to-site --remote-ip 198.51.100.1 --output json

# GCP Cloud VPN with HA
python scripts/vpn_configurator.py --provider gcp --type ha-vpn --output terraform

# Help
python scripts/vpn_configurator.py --help
```

**Use Cases:**
- Connecting on-premises data center to cloud
- Multi-cloud connectivity (AWS to Azure)
- Remote access VPN for developers
- Disaster recovery site connectivity

### 2. Firewall Policy Generator

Create security groups, NACLs, and firewall rules following least-privilege principles.

**Key Features:**
- AWS Security Groups and NACLs
- Azure Network Security Groups (NSGs)
- GCP Firewall Rules
- 3-tier application templates (web, app, database)
- Microservices security patterns
- Compliance-ready rules (PCI-DSS, SOC2, HIPAA)

**Common Usage:**
```bash
# 3-tier application security groups
python scripts/firewall_policy_generator.py --cloud aws --tier 3-tier --output terraform

# Microservices firewall rules
python scripts/firewall_policy_generator.py --cloud gcp --pattern microservices --services web,api,db --output json

# Compliance-ready NSGs
python scripts/firewall_policy_generator.py --cloud azure --compliance pci-dss --output terraform

# Help
python scripts/firewall_policy_generator.py --help
```

**Use Cases:**
- New application deployments
- Security compliance audits
- Network segmentation projects
- Zero-trust implementation

### 3. Network Topology Analyzer

Analyze network configurations for redundancy, security, and best practices.

**Key Features:**
- Subnet connectivity validation
- Route table analysis
- Redundancy checking (multi-AZ, multi-region)
- Security posture assessment
- Cost optimization recommendations
- Compliance gap identification

**Common Usage:**
```bash
# Analyze VPC configuration
python scripts/network_topology_analyzer.py --input vpc-config.json --check-redundancy

# Security assessment
python scripts/network_topology_analyzer.py --input network-export.json --security-audit

# Full analysis with recommendations
python scripts/network_topology_analyzer.py --input infra/ --verbose --output report.md

# Help
python scripts/network_topology_analyzer.py --help
```

**Use Cases:**
- Pre-deployment network review
- Quarterly security audits
- Cost optimization analysis
- Disaster recovery validation

### 4. Subnet Planner

Calculate CIDR allocations and plan subnet layouts for optimal IP utilization.

**Key Features:**
- Automatic CIDR subdivision
- Multi-AZ subnet planning
- Reserved IP calculation
- Future growth accommodation
- Visual subnet map generation
- IP address inventory

**Common Usage:**
```bash
# Plan subnets for 3-tier, 3-AZ deployment
python scripts/subnet_planner.py --vpc-cidr 10.0.0.0/16 --azs 3 --tiers 3

# Custom subnet sizes
python scripts/subnet_planner.py --vpc-cidr 172.16.0.0/12 --subnets public:24,private:22,database:26

# Generate IP inventory
python scripts/subnet_planner.py --vpc-cidr 10.0.0.0/16 --inventory --output csv

# Help
python scripts/subnet_planner.py --help
```

**Use Cases:**
- New VPC design
- Network expansion planning
- IP address management
- Migration subnet planning

See [vpc_design_patterns.md](references/vpc_design_patterns.md) for comprehensive architecture documentation.

## Reference Documentation

### VPC Design Patterns

Comprehensive guide available in `references/vpc_design_patterns.md`:

- Single VPC architectures
- Hub-spoke topology with Transit Gateway
- Multi-region designs
- AWS, Azure, GCP-specific patterns
- Landing zone architectures
- Network segmentation strategies

### Network Security Guide

Complete security documentation in `references/network_security_guide.md`:

- Security group best practices
- NACL vs Security Group decisions
- Zero-trust network architecture
- Network segmentation patterns
- DDoS mitigation strategies
- Compliance frameworks (PCI-DSS, SOC2, HIPAA)

### Cloud Networking

Technical reference guide in `references/cloud_networking.md`:

- AWS Direct Connect setup
- Azure ExpressRoute configuration
- GCP Cloud Interconnect
- Multi-cloud connectivity patterns
- BGP configuration
- Network peering strategies

## Tech Stack

**Cloud Platforms:** AWS, Azure, GCP
**Networking:** VPC, VNet, VPN, Direct Connect, ExpressRoute, Cloud Interconnect
**Security:** Security Groups, NACLs, NSGs, WAF, Shield
**Protocols:** BGP, IPSec, IKEv2, WireGuard, OSPF
**Tools:** Terraform, CloudFormation, ARM Templates, Deployment Manager

## Key Workflows

### 1. VPC Design for Multi-Region Application

**Time:** 2-3 hours for complete VPC architecture

1. **Gather Requirements** - Application tiers, availability zones, estimated IP usage, compliance needs
2. **Plan CIDR Allocation** - Use subnet planner for optimal IP utilization
   ```bash
   python scripts/subnet_planner.py --vpc-cidr 10.0.0.0/16 --azs 3 --tiers 3 --reserve-future 20
   ```
3. **Generate VPC Configuration** - Create Terraform for VPC, subnets, route tables
4. **Configure Security Groups** - Generate least-privilege firewall rules
   ```bash
   python scripts/firewall_policy_generator.py --cloud aws --tier 3-tier --output terraform
   ```
5. **Validate Design** - Analyze topology for redundancy and security
   ```bash
   python scripts/network_topology_analyzer.py --input vpc-config.json --check-redundancy --security-audit
   ```

See [vpc_design_patterns.md](references/vpc_design_patterns.md) for architecture patterns.

### 2. Site-to-Site VPN Configuration

**Time:** 1-2 hours for VPN setup with failover

1. **Gather Remote Site Details** - Public IP, BGP ASN (if using BGP), pre-shared key requirements
2. **Generate VPN Configuration** - Create VPN gateway and tunnel configuration
   ```bash
   python scripts/vpn_configurator.py --provider aws --type site-to-site \
     --remote-ip 203.0.113.1 --remote-cidr 192.168.0.0/16 --ha --output terraform
   ```
3. **Configure Customer Gateway** - Apply configuration to on-premises device
4. **Verify Tunnel Status** - Check tunnel establishment and BGP peering
5. **Test Connectivity** - Validate traffic flow between sites

See [cloud_networking.md](references/cloud_networking.md) for VPN best practices.

### 3. Firewall Policy Implementation

**Time:** 1-2 hours for comprehensive security rules

1. **Document Application Flows** - Identify all required network communications
2. **Generate Base Policies** - Create tier-based security groups
   ```bash
   python scripts/firewall_policy_generator.py --cloud aws --tier 3-tier \
     --app-port 8080 --db-port 5432 --output terraform
   ```
3. **Add Custom Rules** - Append application-specific rules
4. **Review and Audit** - Validate no overly permissive rules
   ```bash
   python scripts/network_topology_analyzer.py --input security-groups.json --security-audit
   ```
5. **Apply and Test** - Deploy rules and verify application connectivity

See [network_security_guide.md](references/network_security_guide.md) for security best practices.

### 4. Network Security Audit

**Time:** 2-3 hours for comprehensive audit

1. **Export Current Configuration** - Gather VPC, security groups, route tables
2. **Run Security Analysis** - Identify vulnerabilities and compliance gaps
   ```bash
   python scripts/network_topology_analyzer.py --input network-export/ \
     --security-audit --compliance pci-dss --output audit-report.md
   ```
3. **Review Findings** - Prioritize issues by severity
4. **Generate Remediation Plan** - Create action items for each finding
5. **Apply Fixes** - Update configurations to address gaps
6. **Re-audit** - Verify all issues resolved

See [network_security_guide.md](references/network_security_guide.md) for compliance frameworks.

## Development Workflow

### 1. Setup and Configuration

```bash
# No external dependencies required - uses Python standard library only
python --version  # Requires Python 3.8+

# Verify tools work
python scripts/vpn_configurator.py --help
python scripts/firewall_policy_generator.py --help
python scripts/network_topology_analyzer.py --help
python scripts/subnet_planner.py --help
```

### 2. Run Quality Checks

```bash
# Analyze existing network configuration
python scripts/network_topology_analyzer.py --input ./infrastructure --verbose

# Review recommendations and apply fixes
```

### 3. Implement Best Practices

Follow the patterns and practices documented in:
- `references/vpc_design_patterns.md`
- `references/network_security_guide.md`
- `references/cloud_networking.md`

## Best Practices Summary

### Network Design
- Use private subnets for application and database tiers
- Implement NAT Gateways for outbound-only internet access
- Plan for future growth with adequate CIDR allocation
- Use Transit Gateway for hub-spoke topologies

### Security
- Apply least-privilege security group rules
- Use separate security groups per application tier
- Enable VPC Flow Logs for network monitoring
- Implement network segmentation for isolation

### High Availability
- Deploy across multiple availability zones
- Use redundant VPN tunnels with failover
- Implement health checks for all endpoints
- Plan for regional failover

### Cost Optimization
- Right-size NAT Gateways based on traffic
- Use VPC endpoints to reduce data transfer costs
- Consider reserved capacity for Direct Connect
- Monitor and optimize cross-AZ traffic

## Common Commands

```bash
# VPN Configuration
python scripts/vpn_configurator.py --provider aws --type site-to-site --output terraform
python scripts/vpn_configurator.py --provider azure --type point-to-site --output json

# Firewall Rules
python scripts/firewall_policy_generator.py --cloud aws --tier 3-tier --output terraform
python scripts/firewall_policy_generator.py --cloud gcp --pattern microservices --output json

# Network Analysis
python scripts/network_topology_analyzer.py --input vpc-config.json --check-redundancy
python scripts/network_topology_analyzer.py --input network/ --security-audit

# Subnet Planning
python scripts/subnet_planner.py --vpc-cidr 10.0.0.0/16 --azs 3 --tiers 3
python scripts/subnet_planner.py --vpc-cidr 172.16.0.0/12 --inventory --output csv
```

## Troubleshooting

### Common Issues

**VPN Tunnel Not Establishing:**
- Verify remote IP address and pre-shared key
- Check security group allows IPSec protocols (UDP 500, 4500)
- Validate BGP ASN if using dynamic routing
- Review IKE/IPSec phase 1 and 2 parameters match

**Security Group Rules Not Working:**
- Verify stateful vs stateless rules (SG vs NACL)
- Check rule priority/order for NACLs
- Validate source/destination CIDR blocks
- Ensure both inbound and outbound rules are configured

**Subnet IP Exhaustion:**
- Review CIDR allocation with subnet planner
- Identify unused elastic IPs and ENIs
- Consider larger subnet sizes for high-density workloads
- Plan for reserved IPs (AWS reserves 5 per subnet)

### Getting Help

- Review reference documentation for patterns
- Check script output messages for specific errors
- Consult cloud provider documentation
- Review VPC flow logs for traffic issues

## Resources

- Pattern Reference: `references/vpc_design_patterns.md`
- Security Guide: `references/network_security_guide.md`
- Cloud Networking: `references/cloud_networking.md`
- Tool Scripts: `scripts/` directory
