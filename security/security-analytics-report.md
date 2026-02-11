# Security Analytics Report: Azure Governance Baseline

## Executive Summary

This governance baseline establishes subscription-level preventive controls using Azure Policy and Terraform-managed CI/CD. Two mandatory deny controls are deployed for naming and tagging. The architecture is modular, scalable through policy auto-discovery, and integrated with OIDC-based GitHub Actions for passwordless deployment.

## Control Coverage Table

| Control Domain | Implemented Control | Enforcement Type | Scope | Status |
|---|---|---|---|---|
| Resource Naming | Resource group naming convention `<org>-<env>-rg-<region>` | Preventive (Deny) | Subscription | Implemented |
| Metadata Hygiene | Mandatory tags `Environment`, `Owner` | Preventive (Deny) | Subscription | Implemented |
| IaC Change Control | PR plan + main apply workflow | Detective/Preventive | Repository | Implemented |
| Identity Security | GitHub OIDC federation (`azure/login@v2`) | Preventive | CI/CD | Implemented |
| State Security | Remote Terraform state in Azure Storage backend | Preventive | Deployment platform | Implemented |

## Risk Analysis

- Unauthorized or non-standard resource creation risk is reduced through naming deny control.
- Asset ownership ambiguity risk is reduced through mandatory tag enforcement.
- Static credential leakage risk is reduced by OIDC-based workload identity federation.
- Drift and unreviewed changes risk is reduced by PR plan validation and branch-driven apply.
- Residual risk remains for resource types not covered by custom controls and for non-policy Azure governance gaps (for example networking, encryption, diagnostics).

## Compliance Mapping

| Framework | Relevant Controls | Mapping Outcome |
|---|---|---|
| ISO 27001 | A.5.9, A.5.23, A.8.9 | Naming/tagging improve asset inventory and accountability; CI/CD enforces controlled changes |
| SOC 2 | CC6, CC7, CC8 | Preventive policy controls and controlled release workflow support logical access and change management |
| NIST CSF 2.0 | ID.AM, PR.AC, PR.PS, DE.CM | Asset metadata and policy enforcement strengthen identify/protect functions; pipeline validation supports monitoring |

## Maturity Score

Current governance maturity: **3.2 / 5.0 (Defined)**

Scoring basis:

- Policy-as-code model implemented
- Automated CI/CD enforcement in place
- Preventive controls active at subscription scope
- Limited coverage breadth (two controls) keeps maturity below Managed/Optimizing

## Gap Analysis

- No built-in initiative packaging for grouped assignment lifecycle.
- No automated compliance dashboard export/reporting workflow.
- No deny controls yet for allowed locations, SKU restrictions, private networking, or diagnostics.
- No management group scope deployment path in this baseline.
- No break-glass exception workflow for policy exemptions.

## Phase 2 Roadmap

1. Introduce policy initiatives (policy set definitions) for domain-based governance bundles.
2. Extend policy library: allowed locations, required diagnostics, managed identity enforcement, and encryption defaults.
3. Add management group deployment option for multi-subscription enterprises.
4. Implement automated compliance reporting to Log Analytics/Sentinel/Power BI.
5. Establish controlled policy exemption process with expiration and approval gates.
6. Add pre-merge policy unit tests and OPA/Conftest checks for Terraform changes.
