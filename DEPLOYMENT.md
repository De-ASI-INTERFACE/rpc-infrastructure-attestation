# Deployment Documentation

> **Exhibit C-3** — Cross-referenced with `node-manifest.json` (Exhibit C-1)  
> **RON Record ID:** 2026-OH-7749-001  
> **Author:** Richard Patterson (`De-ASI-INTERFACE`)  
> **Date:** 2026-07-07  
> **Status:** Production — All 70 nodes active

---

## Overview

This document describes the complete deployment architecture of the 70-node Solana mainnet-beta RPC infrastructure built, operated, and maintained by Richard Patterson under the **De-ASI-INTERFACE** and **Quantum Trading Infinity (QTI)** organizations. This infrastructure underpins the DeFi protocols TruthLend, Legion, and QTI's quantitative trading systems, providing sub-20ms median RPC latency across six global regions.

All endpoint identities are enumerated in [`node-manifest.json`](./node-manifest.json). Health-check telemetry is recorded in [`health-check-sample.jsonl`](./health-check-sample.jsonl). This document is cross-referenced by [`ATTESTATION.md`](./ATTESTATION.md).

---

## Architecture

### Node Tiers

| Tier | Count | Role | Provider(s) |
|------|-------|------|-------------|
| `primary` | 25 | High-throughput mainnet RPC, direct validator peering | GCP |
| `secondary` | 20 | Failover and geographic redundancy | GCP, Railway |
| `edge` | 10 | Low-latency edge termination, global CDN proximity | Vercel |
| `bare-metal` | 10 | Highest-performance, dedicated hardware, no virtualization overhead | Hetzner |
| `aggregator` | 5 | RPC request routing, multi-node fanout, response deduplication | GCP |
| `load-balancer` | 5 | Layer-7 intelligent load distribution across tiers | GCP |

### Provider Distribution

| Provider | Nodes | Justification |
|----------|-------|---------------|
| GCP | 40 | Global footprint, low-latency peering with Solana validator network |
| Railway | 10 | Rapid deployment, CI/CD-native, containerized RPC processes |
| Vercel | 10 | Edge network, global PoPs, optimized for JSON-RPC over HTTPS |
| Hetzner | 10 | Bare-metal performance, NVMe storage, dedicated 10Gbps uplinks |

---

## Deployment Process

### 1. Node Provisioning

Each node is provisioned using infrastructure-as-code (IaC) scripts maintained in the De-ASI-INTERFACE organization. The provisioning sequence is:

```bash
# 1. Generate node identity keypair
solana-keygen new --no-bip39-passphrase -o /etc/solana/identity.json

# 2. Export and record the node identity public key
solana-keygen pubkey /etc/solana/identity.json

# 3. Configure the RPC validator with the identity
agave-validator \
  --identity /etc/solana/identity.json \
  --rpc-port 8899 \
  --rpc-bind-address 0.0.0.0 \
  --no-voting \
  --enable-rpc-transaction-history \
  --enable-extended-tx-metadata-storage \
  --known-validators 7Np41oeYqPefeNQEHSv1UDhYrehxin3NStELsSKCT4K2 \
  --known-validators GdnSyH3YtwcxFvQrVVJMm1JhTS4QVX7MFsX56uJLUfiZ \
  --only-known-rpc
```

### 2. Health Check Automation

Automated health checks run on a 2-hour cycle across all 70 nodes using the Solana JSON-RPC `getHealth` and `getVersion` methods. Logs are written to the rolling `health-check-sample.jsonl` file in this repository. A sample entry structure:

```json
{
  "ts": "2026-07-07T19:11:00Z",
  "node_id": 1,
  "endpoint": "https://rpc-node-01.deasiinterface.io",
  "method": "getHealth",
  "status": "ok",
  "slot": 320824200,
  "latency_ms": 12,
  "block_height": 320824198,
  "version": "1.18.26"
}
```

### 3. Load Balancer Configuration

Nodes 66–70 (see `node-manifest.json` IDs 66–70) operate as Layer-7 load balancers implementing weighted round-robin routing with the following logic:

- **Primary tier nodes** receive 60% of inbound traffic weight
- **Bare-metal tier nodes** receive 25% of inbound traffic weight  
- **Secondary/Edge tier nodes** receive 15% of inbound traffic weight
- **Aggregator nodes** (IDs 61–65) perform fanout for `getAccountInfo`, `getProgramAccounts`, and `getMultipleAccounts` calls that benefit from parallel multi-node verification

### 4. CI/CD Pipeline

All node configuration changes are gated through GitHub Actions CI/CD pipelines. Deployment steps:

1. PR opened against `main` in the relevant infrastructure repository
2. Automated linting and schema validation of node config files
3. Staging deployment to secondary-tier nodes first
4. 30-minute health-check soak period
5. Progressive rollout to primary and bare-metal tiers
6. Automated rollback triggered if >2 nodes report `unhealthy` status within 10 minutes

---

## Node Manifest Cross-Reference

The complete node identity registry is maintained in [`node-manifest.json`](./node-manifest.json). The following fields in the manifest map directly to this deployment document:

| Manifest Field | Deployment Context |
|----------------|--------------------|
| `endpoint` | The publicly reachable HTTPS RPC URL |
| `identity_pubkey` | Solana validator identity public key, generated at provision time |
| `region` | GCP/Railway/Vercel/Hetzner region slug |
| `provider` | Infrastructure provider |
| `tier` | Functional role as described in the Architecture section above |
| `status` | Current operational status (`active` / `maintenance` / `decommissioned`) |

---

## Security & Compliance

- All node identity keypairs are generated in-situ and never transmitted over the network
- Identity public keys are recorded in `node-manifest.json` for third-party verification
- RPC endpoints are TLS-terminated with certificates managed via Let's Encrypt / Google-managed SSL
- No voting keys are held by RPC nodes — all nodes run with `--no-voting`
- Access to node provisioning credentials is controlled via multi-sig governance (see QTI governance documentation)
- This infrastructure is declared under **RON Record ID 2026-OH-7749-001**, a legally notarized Ohio public record

---

## Related Evidence Documents

| Document | Role in Evidence Appendix |
|----------|---------------------------|
| [`node-manifest.json`](./node-manifest.json) | Exhibit C-1: Node identity registry |
| [`health-check-sample.jsonl`](./health-check-sample.jsonl) | Exhibit C-2: 72-hour health telemetry |
| [`DEPLOYMENT.md`](./DEPLOYMENT.md) | Exhibit C-3: Deployment architecture (this document) |
| [`ATTESTATION.md`](./ATTESTATION.md) | Exhibit C-4: GPG-attested declaration |
