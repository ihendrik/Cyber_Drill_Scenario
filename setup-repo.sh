#!/bin/bash
# Ransomware Cyber Drill 2026 — Git Repository Setup Script
# Usage: bash setup-repo.sh <git-repo-url> [destination-dir]

set -e

REPO_URL="${1:-}"
DEST_DIR="${2:-.}"
REPO_NAME=$(basename "$REPO_URL" .git)

if [ -z "$REPO_URL" ]; then
  echo "Usage: bash setup-repo.sh <git-repo-url> [destination-dir]"
  exit 1
fi

mkdir -p "$DEST_DIR/$REPO_NAME"
cd "$DEST_DIR/$REPO_NAME"

echo "[*] Initializing Ransomware Cyber Drill repository"
echo "[*] Repository: $REPO_URL"
echo ""

echo "[1/5] Cloning repository..."
git clone "$REPO_URL" . || { echo "[!] Failed to clone"; exit 1; }

echo "[2/5] Creating directory structure..."
mkdir -p provisioning/{files,templates}

echo "[3/5] Extracting provisioning files..."
if [ -f "../provisioning.zip" ]; then
  unzip -o "../provisioning.zip" -d .
elif [ -f "provisioning.zip" ]; then
  unzip -o "provisioning.zip" -d .
else
  echo "[!] provisioning.zip not found"
  exit 1
fi

echo "[4/5] Copying topology.yml..."
if [ -f "../topology.yml" ]; then
  cp "../topology.yml" .
elif [ -f "topology.yml" ]; then
  echo "[i] topology.yml already present"
else
  echo "[!] topology.yml not found"
  exit 1
fi

echo "[5/5] Creating README..."
if [ ! -f "README.md" ]; then
  cat > README.md << 'EOF'
# Ransomware Cyber Drill 2026 — KYPO CRP Sandbox

Complete infrastructure-as-code for ransomware attack simulation on KYPO CRP.

## Quick Start

1. Prepare images (see Image_Preparation_Checklist.md)
2. Register this repo in KYPO portal
3. Create Pool → Allocate Sandbox Unit
4. Run drill (see README_KYPO_DEPLOYMENT.md)

## Repository Contents

- `topology.yml` — Infrastructure definition (9 hosts, 5 VLANs, 1 router)
- `provisioning/playbook.yml` — Ansible automation
- `provisioning/files/` — Detection rules, simulation scripts, credentials
- `provisioning/templates/` — FIM configuration
EOF
fi

echo ""
echo "[+] Repository setup complete!"
echo "[+] Files:"
ls -lhA topology.yml provisioning/ 2>/dev/null | tail -10

echo ""
echo "Next steps:"
echo "  1. Commit and push (git push -u origin main)"
echo "  2. Register in KYPO portal (Definitions → Create Definition)"
echo "  3. Create Pool and allocate Sandbox Unit"
echo ""
