# KYPO CRP Deployment Guide — Ransomware Cyber Drill 2026

Complete step-by-step guide for deploying and executing the ransomware drill on KYPO CRP.

## Prerequisites

- KYPO CRP instance (instructor role)
- 5 OpenStack images uploaded (see Image_Preparation_Checklist.md)
- Empty Git repository created
- SSH key access to KYPO instance

## Deployment Steps (6 steps, ~50 minutes)

### Step 1: Git Repository Setup (10 min)

```bash
# Option A: Automated
bash setup-repo.sh <your-git-repo-url>

# Option B: Manual
git clone <your-git-repo-url>
cd ransomware-drill-2026
unzip provisioning.zip
cp topology.yml .
git add .
git commit -m "Initial commit"
git push -u origin main
```

### Step 2: Register Sandbox Definition (5 min)

1. Log into KYPO portal (instructor)
2. **Definitions → Create Definition**
3. Name: `Ransomware Cyber Drill 2026`
4. Git URL: `<your-git-repo-url>`
5. Branch: `main`
6. Click **Create**

KYPO validates the topology.yml format. If errors, fix and re-push to Git.

### Step 3: Create Pool (5 min)

1. **Pools → Create Pool**
2. Select `Ransomware Cyber Drill 2026` definition
3. Pool Size: 1 (or more for multiple simultaneous runs)
4. Auto-destruction: Optional (24-hour cleanup timer)
5. Click **Create**

This starts the Terraform build. Takes ~15–20 minutes.

### Step 4: Monitor Pool Build (15–20 min)

Watch the **Pool Overview** page until all 10 instances reach **READY** status.

Check via CLI:
```bash
openstack server list  # Should show 10 ACTIVE instances
```

### Step 5: Allocate Sandbox Unit (5 min)

1. **Pools → [Your Pool] → Allocation Units**
2. Click **Allocate Unit**
3. Each unit is a fully isolated drill environment

### Step 6: Verify Connectivity (10 min)

1. Download SSH config from Allocation Unit detail page
2. Extract to `~/.ssh/`
3. Test connection: `ssh prod-server1`
4. Verify Wazuh: `curl -k https://10.20.99.99`

## Pre-Drill Checklist

Run before T+0:00:

```bash
# 1. Wazuh agent status
ssh siem-manager
/var/ossec/bin/agent_control -lc
# All 8 agents should show "Active"

# 2. Firewall rules
ssh core-router
iptables -L FORWARD -n | head -20
# Should show multiple rules, default policy DROP

# 3. FIM configuration
ssh siem-manager
grep -c "directories check_all" /var/ossec/etc/ossec.conf.d/syscheck-drill.conf
# Should return 5

# 4. Detection rules
ssh siem-manager
grep -c "ransomware\|drill" /var/ossec/etc/rules/detection_rules.xml
# Should return 6
```

## Running the Drill (2–3 hours)

### Phase 1: LLMNR Spoofing (T+0:00–T+2:00)

On attacker-box:
```bash
ssh attacker-box
responder -I eth0 -v
```

Wait for LLMNR traffic from ws-client1 (may need manual trigger).

### Phase 2: Lateral Movement (T+5:00–T+8:00)

On attacker-box:
```bash
# Use pre-staged credentials to reach production
impacket-secretsdump -u admin-prod -p 'CompanyPass123!' 10.20.20.21
```

Expect **Wazuh Rule 100104** (RDP lateral movement).

### Phase 3: Ransomware Deployment (T+10:00–T+10:15)

On production server (via attacker or SSH):
```bash
ssh prod-server1
sudo /tmp/ransomware_sim.sh
```

Expect multiple alerts:
- **Rule 100102**: Service stops (postgresql, httpd, etc.)
- **Rule 100100**: Files with `.encrypted` extension
- **Rule 100101**: Ransom notes created

### Phase 4: Detection & Response (T+12:00–T+15:00)

1. Open Wazuh Dashboard: `https://10.20.99.99`
2. Check Security Events (last 20 min, level 10+)
3. Correlate attack chain
4. Assess DR/backup status for recovery strategy

## Troubleshooting

### Images not found
```bash
openstack image list | grep -E 'rocky|debian|windows|kali'
```
If missing, rebuild per Image_Preparation_Checklist.md

### Provisioning failed
```bash
ssh <host>
sudo tail -100 /var/log/cloud-init-output.log
```

### Agents offline
Check firewall on core-router allows outbound to SIEM:
```bash
ssh core-router
iptables -L FORWARD -n | grep "10.20.99.99.*1514"
```

### Wazuh dashboard unreachable
```bash
ssh siem-manager
systemctl status wazuh-dashboard
ss -tlnp | grep 443
```

## Teardown

Option 1: Auto-cleanup (if 24-hour timer was set)
Option 2: Manual allocation unit deletion

---

For complete details, see TOPOLOGY_REFERENCE.md and ARCHITECTURE_GUIDE.md
