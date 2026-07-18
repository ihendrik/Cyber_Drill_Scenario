# Image Preparation Checklist — Ransomware Cyber Drill 2026

Before deploying, you must build/upload 5 OpenStack images to Glance. Image names in `topology.yml` must match exactly.

## Quick Check

```bash
openstack image list | grep -E 'rocky|debian|windows-11|kali'
```

Should show 5 images. If any are missing, build them below.

---

## 1. Rocky Linux 9 x64 (Server)

**Used by:** 3 production servers + 2 DR + 1 backup (5 VMs)  
**Not in KYPO stock catalog** — must build

```bash
# Download Rocky Linux 9 Generic Cloud image
wget https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2

# Upload to OpenStack
openstack image create "rocky-9-x64-server" \
  --disk-format qcow2 --container-format bare \
  --file Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 \
  --property hw_qemu_guest_agent=yes
```

**Management user:** `rocky`

---

## 2. Debian 12 x64 (Server)

**Used by:** Wazuh SIEM manager (1 VM)  
**Stock catalog only has 9/10** — must build

```bash
# Download Debian 12 cloud image
wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2

# Upload to OpenStack
openstack image create "debian-12-x64-server" \
  --disk-format qcow2 --container-format bare \
  --file debian-12-genericcloud-amd64.qcow2 \
  --property hw_qemu_guest_agent=yes
```

**Management user:** `debian`

---

## 3. Windows 11 22H2 Enterprise x64

**Used by:** 2 client workstations  
**Not in KYPO stock catalog** — **most effort required**

### Prerequisites
- Windows 11 installation media (ISO)
- Cloudbase-Init Windows package
- QEMU/KVM or Hyper-V for VM creation
- 50 GB disk space minimum

### Steps

1. **Create Windows 11 VM** (in KVM/Hyper-V)
   - 4 vCPU, 4 GB RAM, 50 GB disk
   - Install Windows 11 Enterprise 22H2
   - Apply all updates

2. **Install Cloudbase-Init**
   ```
   Download: https://cloudbase.it/cloudbase-init/
   Install with default settings (enables WinRM + SSH key injection)
   Restart VM
   ```

3. **Run Sysprep** (generalize the image)
   ```cmd
   C:\Windows\System32\sysprep\sysprep.exe /generalize /oobe /shutdown
   ```
   VM will shutdown after sysprep completes.

4. **Export to QCOW2**
   ```bash
   virt-manager or qemu-img convert to QCOW2 format
   ```

5. **Upload to OpenStack**
   ```bash
   openstack image create "windows-11-22h2-x64-enterprise" \
     --disk-format qcow2 --container-format bare \
     --file windows-11-sysprepped.qcow2 \
     --property os_type=windows \
     --property hw_firmware_type=uefi
   ```

**Management user:** `windows` (Cloudbase-Init default)  
**Management protocol:** `winrm`

---

## 4. Kali Linux (Current)

**Used by:** Attacker workstation (1 VM)  
**Stock catalog has Kali 2019.4** — outdated, rebuild with current tools

```bash
# Download current Kali cloud image
wget https://kali.download/cloud-images/kali-latest-cloudimage-amd64.tar.xz

# Extract and convert to QCOW2
tar -xf kali-latest-cloudimage-amd64.tar.xz
qemu-img convert -f raw -O qcow2 kali-*.img kali-linux-current.qcow2

# Upload to OpenStack
openstack image create "kali-linux-current-amd64" \
  --disk-format qcow2 --container-format bare \
  --file kali-linux-current.qcow2 \
  --property hw_qemu_guest_agent=yes
```

**Management user:** `kali`

---

## 5. Debian 9 x86_64 (Router)

**Used by:** Router (1 VM)  
**Likely in KYPO stock catalog** — verify first

```bash
# Check if it already exists
openstack image list | grep debian-9

# If NOT present, download and upload
wget https://cdimage.debian.org/cdimage/openstack/current-9/debian-9-openstack-amd64.qcow2

openstack image create "debian-9-x86_64" \
  --disk-format qcow2 --container-format bare \
  --file debian-9-openstack-amd64.qcow2
```

**Management user:** `debian`

---

## Verification

After uploading all images, verify:

```bash
openstack image list --property hidden=false | grep -E 'rocky-9|debian-12|windows-11|kali-linux|debian-9'

# Should show 5 images with status ACTIVE
```

Check exact image names match `topology.yml`:
- `rocky-9-x64-server` ✓
- `debian-12-x64-server` ✓
- `windows-11-22h2-x64-enterprise` ✓
- `kali-linux-current-amd64` ✓
- `debian-9-x86_64` ✓

---

## Troubleshooting

**"Image not found" error during Pool creation:**
- Verify image name matches exactly (case-sensitive)
- Check `openstack image list` for correct naming
- Update `topology.yml` to match your image names if different

**Cloudbase-Init not working on Windows:**
- Ensure WinRM is enabled in the sysprep'd image
- Check: Settings → System Properties → Remote tab → "Allow remote connections"
- Ansible won't be able to connect without WinRM

**Kali tools missing after deployment:**
- Playbook's `apt install` may fail if package repo access is blocked
- SSH into attacker-box and install manually: `sudo apt update && sudo apt install responder impacket-scripts`

---

## Timing

| Image | Build Time | Upload Time |
|---|---|---|
| Rocky 9 | 20 min | 5 min |
| Debian 12 | 20 min | 5 min |
| Windows 11 | **2–4 hours** | 10 min |
| Kali Linux | 30 min | 5 min |
| Debian 9 | 20 min | 2 min (likely already exists) |
| **Total** | **3.5–5 hours** | **30 min** |

**Windows 11 is the critical path.** Start with that if possible.

---

Next: Once all 5 images are uploaded, proceed to README_KYPO_DEPLOYMENT.md
