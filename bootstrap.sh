#!/bin/bash
set -e

# ============================================================
#  K8s Troubleshooting Lab — One-command bootstrap
#  Works on: Ubuntu 20.04 / 22.04 / 24.04 (amd64)
#  Usage: curl -sSL <raw-url> | bash
# ============================================================

REPO_URL="https://github.com/YOUR_USERNAME/k8s-troubleshooting-lab.git"
CLUSTER_NAME="k8s-lab"
LAB_DIR="$HOME/k8s-troubleshooting-lab"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[LAB]==> $1${NC}"; }
warn() { echo -e "${YELLOW}[LAB] WARN: $1${NC}"; }
fail() { echo -e "${RED}[LAB] ERROR: $1${NC}"; exit 1; }

echo ""
echo "=============================================="
echo "   K8s Troubleshooting Lab — Quick Start"
echo "=============================================="
echo ""

# ── 1. DOCKER ────────────────────────────────────
log "Step 1/5 — Installing Docker..."
if command -v docker &>/dev/null && docker info &>/dev/null; then
  log "Docker already running — skipping install."
else
  sudo apt-get update -qq
  sudo apt-get install -y -qq ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -qq
  sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io

  sudo systemctl start docker
  sudo systemctl enable docker

  # Add current user to docker group
  sudo usermod -aG docker "$USER"
fi

# Run docker as current user without sudo for rest of script
if ! docker info &>/dev/null; then
  sudo chmod 666 /var/run/docker.sock
fi

docker info &>/dev/null || fail "Docker is not responding. Try: sudo systemctl start docker"
log "Docker OK."

# ── 2. KUBECTL ───────────────────────────────────
log "Step 2/5 — Installing kubectl..."
if command -v kubectl &>/dev/null; then
  log "kubectl already installed — skipping."
else
  ARCH=$(dpkg --print-architecture)
  K8S_VERSION=$(curl -sL https://dl.k8s.io/release/stable.txt)
  curl -sLo /tmp/kubectl \
    "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/${ARCH}/kubectl"
  sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
  rm /tmp/kubectl
fi
kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -1
log "kubectl OK."

# ── 3. KIND ──────────────────────────────────────
log "Step 3/5 — Installing kind..."
if command -v kind &>/dev/null; then
  log "kind already installed — skipping."
else
  ARCH=$(dpkg --print-architecture)
  curl -sLo /tmp/kind \
    "https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-${ARCH}"
  sudo install -o root -g root -m 0755 /tmp/kind /usr/local/bin/kind
  rm /tmp/kind
fi
kind --version
log "kind OK."

# ── 4. CLONE REPO ────────────────────────────────
log "Step 4/5 — Setting up lab repo..."
if [ -d "$LAB_DIR" ]; then
  log "Repo already exists at $LAB_DIR — pulling latest..."
  cd "$LAB_DIR" && git pull --quiet
else
  if [ "$REPO_URL" = "https://github.com/YOUR_USERNAME/k8s-troubleshooting-lab.git" ]; then
    warn "REPO_URL not set — using local zip if available, or skipping clone."
    warn "Update REPO_URL at the top of this script with your real GitHub URL."
    # Fallback: check if lab folder already exists from a manual upload
    if [ ! -d "$LAB_DIR" ]; then
      fail "No repo URL set and no lab folder found at $LAB_DIR. Push to GitHub first!"
    fi
  else
    git clone "$REPO_URL" "$LAB_DIR"
  fi
fi

cd "$LAB_DIR"
find . -name "*.sh" -exec chmod +x {} \;
log "Repo ready."

# ── 5. CREATE KIND CLUSTER ───────────────────────
log "Step 5/5 — Creating kind cluster '$CLUSTER_NAME'..."
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
  log "Cluster '$CLUSTER_NAME' already exists — skipping creation."
else
  # Use single-node config if RAM < 2GB to avoid OOM on small servers
  TOTAL_RAM_MB=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo)
  log "Detected ${TOTAL_RAM_MB}MB RAM"

  if [ "$TOTAL_RAM_MB" -lt 2048 ]; then
    warn "Low RAM detected (<2GB) — using single-node cluster for stability."
    cat > /tmp/kind-config-lite.yaml << 'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: k8s-lab
nodes:
  - role: control-plane
EOF
    kind create cluster --config /tmp/kind-config-lite.yaml
  else
    kind create cluster --config "$LAB_DIR/kind-config.yaml"
  fi
fi

log "Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo ""
echo "=============================================="
echo ""
kubectl get nodes
echo ""
echo "=============================================="
echo -e "${GREEN}"
echo "  Lab is READY! Here are your scenarios:"
echo ""
echo "  01 - CrashLoopBackOff  (Easy)    cd $LAB_DIR/scenarios/01-crashloopbackoff"
echo "  02 - OOMKilled         (Easy)    cd $LAB_DIR/scenarios/02-oomkilled"
echo "  03 - Pending PVC       (Medium)  cd $LAB_DIR/scenarios/03-pending-pvc"
echo "  04 - ImagePullBackOff  (Easy)    cd $LAB_DIR/scenarios/04-imagepullbackoff"
echo "  05 - RBAC              (Medium)  cd $LAB_DIR/scenarios/05-rbac"
echo "  06 - Network Policy    (Hard)    cd $LAB_DIR/scenarios/06-network-policy"
echo ""
echo "  For each scenario:"
echo "    ./setup.sh    ← deploy the broken state"
echo "    ./verify.sh   ← check your fix"
echo ""
echo "  To reset between scenarios:"
echo "    $LAB_DIR/scripts/reset-cluster.sh"
echo -e "${NC}"
echo "=============================================="
