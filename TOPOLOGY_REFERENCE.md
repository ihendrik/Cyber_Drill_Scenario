# KYPO Topology Reference — Ransomware Cyber Drill 2026

Complete breakdown of `topology.yml` structure and design.

## High-Level Overview

```
9 Hosts (2 Windows + 5 Linux + 1 Wazuh + 1 Kali)
├── 5 Isolated VLANs (10, 20, 30, 40, 99)
├── 1 Multi-homed Router (iptables firewall)
└── Complete network segmentation (zero-trust)
```

## Network Architecture

| VLAN | Network | CIDR | Purpose | Hosts |
|---|---|---|---|---|
| 10 | net-clients | 10.20.10.0/24 | Client workstations | ws-client1 (.11), ws-client2 (.12) |
| 20 | net-production | 10.20.20.0/24 | Production servers (targets) | prod-server1 (.21), prod-server2 (.22) |
| 30 | net-dr | 10.20.30.0/24 | Disaster recovery replicas | dr-server1 (.31), dr-server2 (.32) |
| 40 | net-backup | 10.20.40.0/24 | Backup (isolated, recovery source) | backup-server (.41) |
| 99 | net-siem | 10.20.99.0/24 | Monitoring & attacker | siem-manager (.99), attacker-box (.10) |

## Firewall Rules (iptables on core-router)

| Rule # | Source | Destination | Action | Purpose |
|---|---|---|---|---|
| 1 | ws-client2 | net-production | ACCEPT | Client 2 has business access to production |
| 2 | net-production | net-dr | ACCEPT | Production replication to DR |
| 3 | prod-server1 | backup-server | ACCEPT (22/873) | SSH/rsync backup traffic only |
| 4 | Any | siem-manager | ACCEPT (1514/1515/55000) | Wazuh agent enrollment & logs |
| 5 | net-production | net-clients | REJECT | Anti-boomerang: prevent infected production from reaching clients |
| Default | Any-to-Any | Any | DROP | Zero-trust: deny by default |

## Host Roles

**Production Servers (Primary Targets)**
- prod-server1 (10.20.20.21)
- prod-server2 (10.20.20.22)
- Role: Financial/business data storage
- Ransomware target: encrypt these servers during Phase 3

**Disaster Recovery (Replica Assessment)**
- dr-server1 (10.20.30.31)
- dr-server2 (10.20.30.32)
- Role: Real-time replication from production
- Purpose: Show incident response team what data was encrypted

**Backup (Recovery Source)**
- backup-server (10.20.40.41)
- Role: Isolated clean backup copies
- Purpose: Safe recovery source (unreachable by ransomware due to network policy)

**Monitoring**
- siem-manager (10.20.99.99): Wazuh manager/indexer/dashboard
- attacker-box (10.20.99.10): Red team tools (Responder, Impacket, Hashcat)

## IP Addressing Scheme

Each network has:
- `.1` = Gateway (core-router)
- `.11–.12` = Clients
- `.21–.22` = Production servers
- `.31–.32` = DR servers
- `.41` = Backup
- `.99` = Central service (Wazuh)
- `.10` = Attacker box

This scheme is **preserved from the original scenario design** — all attack chain IPs are fixed and referenced in provisioning/playbook.yml.

## Provisioning (What Happens After Topology Builds)

Ansible playbook runs 6 plays:

1. **core-router**: iptables firewall rules
2. **siem-server**: Wazuh manager/indexer/dashboard
3. **linux-servers**: Wazuh agents (5 servers)
4. **windows-clients**: Wazuh agents + SMB-signing disable (2 clients)
5. **ws-client1**: Pre-stage credentials file
6. **attacker**: Install red-team tools (Responder, Impacket)

## Customization

### Change VLAN CIDRs (NOT RECOMMENDED)
If you must change from `10.20.x.x` to something else, update:
- All network CIDR fields
- All net_mappings IP addresses
- All router_mappings IP addresses
- provisioning/playbook.yml iptables rules
- provisioning/templates/ossec-syscheck.conf.j2

**High risk of mistakes** — only if absolutely necessary.

### Change Host Sizes
Edit `flavor:` fields:
```yaml
prod-server1:
  flavor: csirtmu.small2x4  # Change to csirtmu.tiny1x2 or csirtmu.medium4x8
```

Wazuh SIEM needs at least 4GB RAM and 20GB disk.

### Add More Hosts
Add host block + net_mapping + router_mapping + assign to a group.

---

For complete architecture rationale, see ARCHITECTURE_GUIDE.md
