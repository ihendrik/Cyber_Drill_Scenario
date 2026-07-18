# Ransomware Cyber Drill 2026 — Quick Start Guide

## Files Provided

You have 10 production-ready files to deploy a complete ransomware cyber drill on KYPO CRP. No modifications needed to start.

| File | Size | Purpose |
|---|---|---|
| **00_START_HERE.txt** | 9.6 KB | Friendly introduction |
| **MANIFEST.md** | Reference | Complete file guide |
| **QUICKSTART.md** | This file | 5-minute workflow overview |
| **Image_Preparation_Checklist.md** | 5.3 KB | Images to build/upload |
| **topology.yml** | 11 KB | Infrastructure definition (ready to deploy) |
| **provisioning.zip** | 6.4 KB | Ansible playbook + setup scripts |
| **setup-repo.sh** | 5.5 KB | Git repo initialization (automated) |
| **README_KYPO_DEPLOYMENT.md** | 14 KB | Step-by-step deployment guide |
| **TOPOLOGY_REFERENCE.md** | 12 KB | topology.yml deep dive |
| **ARCHITECTURE_GUIDE.md** | 20 KB | Design & technical details |

## Deployment Workflow

### Phase 1: Image Preparation (2–8 hours)
```
Read: Image_Preparation_Checklist.md
↓
Build/upload 5 OpenStack images:
  - Rocky Linux 9
  - Debian 12
  - Windows 11 22H2
  - Kali Linux (current)
  - Debian 9 (likely in stock)
```

### Phase 2: Repository Setup (10 minutes)
```
Option A (Automated):
  bash setup-repo.sh <your-git-repo-url>

Option B (Manual):
  1. Create Git repo (GitLab/GitHub/internal)
  2. Extract provisioning.zip
  3. Copy topology.yml
  4. Commit and push
```

### Phase 3: KYPO Deployment (30 min + 20 min)
```
Read: README_KYPO_DEPLOYMENT.md (Steps 1–6)
↓
1. Register Git repo in KYPO portal (Definitions → Create Definition)
2. Create Pool (Terraform builds 10 instances + 5 networks)
3. Allocate Sandbox Unit
4. Verify connectivity via SSH proxy
```

### Phase 4: Drill Execution (2–3 hours)
```
Read: README_KYPO_DEPLOYMENT.md (Pre-Drill Checklist + Running the Drill)
↓
Execute 4 phases:
  Phase 1: LLMNR spoofing & hash capture
  Phase 2: Lateral movement (NTLM relay)
  Phase 3: Ransomware deployment
  Phase 4: Detection & incident response
```

## Reading Order

1. **MANIFEST.md** (5 min) — File inventory & navigation
2. **QUICKSTART.md** (this file) (5 min) — Workflow overview
3. **Image_Preparation_Checklist.md** (2–8 hr) — Build images
4. **README_KYPO_DEPLOYMENT.md** (30 min) — Deploy on KYPO
5. **Reference as needed:**
   - TOPOLOGY_REFERENCE.md → Deep dive into topology.yml
   - ARCHITECTURE_GUIDE.md → Design rationale

## File Dependencies

```
topology.yml
  ↓ (references)
  ├→ Image names (must exist in OpenStack Glance)
  └→ Flavor names (must exist in OpenStack)

provisioning/playbook.yml
  ↓ (auto-runs after topology builds)
  ├→ Installs Wazuh manager/agents
  ├→ Applies firewall rules (iptables)
  ├→ Deploys detection rules
  └→ Pre-stages credentials
```

## Timing Expectations

| Activity | Time |
|---|---|
| One-time image build/upload | 2–8 hours |
| Git repo setup | 10 minutes |
| KYPO pool creation + provisioning | 30 min + 20 min |
| Verification (pre-drill checklist) | 15 min |
| **Total first-time setup** | **10–16 hours** |
|  |  |
| Subsequent deployments (skip image build) | 40 minutes |
| Drill execution (full attack chain) | 2–3 hours |

## What Gets Deployed

**Infrastructure:**
- 9 hosts (2 Windows clients, 5 Linux servers, 1 Wazuh SIEM, 1 Kali attacker)
- 5 isolated VLANs (clients, production, DR, backup, SOC/SIEM)
- 1 multi-homed router (zero-trust inter-VLAN firewall)

**Provisioning (Automated):**
- Wazuh installation (manager/indexer/dashboard + agents)
- Firewall rules (iptables on router)
- 6 custom detection rules (ransomware indicators)
- File integrity monitoring (syscheck configuration)
- Ransomware simulation script (non-destructive)
- Pre-staged credentials (lateral movement demo)

## Key Features

✅ **Production-ready** — No modifications needed  
✅ **Complete** — Topology + provisioning + documentation  
✅ **Automated** — Git-based, single repo push  
✅ **Scalable** — Run multiple drills simultaneously  
✅ **Non-destructive** — Ransomware script simulates without encryption  
✅ **Detectable** — 6 Wazuh rules catch each attack phase  

## Quick Reference

| Need | File |
|---|---|
| Start here | 00_START_HERE.txt |
| File overview | MANIFEST.md |
| Image list | Image_Preparation_Checklist.md |
| Deployment steps | README_KYPO_DEPLOYMENT.md |
| Topology details | TOPOLOGY_REFERENCE.md |
| Architecture | ARCHITECTURE_GUIDE.md |

---

**Next step:** Open `Image_Preparation_Checklist.md` to start building images.
