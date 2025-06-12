#!/bin/bash

# ==============================================================================
#      VDT Cloud Forecast - Cross-Platform Project Startup Script (Apple Silicon Optimized)
# ==============================================================================
# This script detects the OS and launches all necessary services. It includes
# specific checks and commands for running on macOS with Apple Silicon (ARM64).
#
# Prerequisites:
# 1. PostgreSQL, RabbitMQ installed (e.g., via Homebrew) and running.
# 2. Node.js/npm, Python/pip installed.
# 3. A `~/.config/prom_adapter.env` file exists with the DATABASE_URL.
# 4. The correct ARM64 binaries for Prometheus and prom-pg-adapter are downloaded.
# ==============================================================================

# --- Configuration ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color
PROJECT_ROOT=$(pwd)
NODE_APP_PORT=3000 # The port your Node.js app runs on
OS_TYPE=$(uname)

# --- Helper Function to Open New Terminal Tabs on macOS ---
open_new_tab() {
    local title=$1
    local working_dir=$2
    local command_to_run=$3

    echo -e "${GREEN}Starting: ${title}...${NC}"

    if [ "$OS_TYPE" != "Darwin" ]; then
        echo -e "${RED}This script is configured for macOS. Please adapt for your OS.${NC}"
        exit 1
    fi

    # Prefer iTerm2 if available, otherwise use default Terminal
    if open -g "com.googlecode.iterm2"; then
        osascript <<EOD
tell application "iTerm2"
    create window with default profile
    tell current window
        tell current session
            write text "cd \"${working_dir}\" && echo -e '\\\033]1;${title}\\\007' && ${command_to_run}"
        end tell
    end tell
end tell
EOD
    else
        osascript <<EOD
tell application "Terminal"
    do script "cd \"${working_dir}\" && echo -e '\\\033]1;${title}\\\007' && ${command_to_run}"
end tell
EOD
    fi
}


# --- Pre-flight Checks ---
echo -e "${CYAN}--- Running Pre-flight Checks for Apple Silicon ---${NC}"
if [ ! -f ~/.config/prom_adapter.env ]; then
    echo -e "${RED}ERROR: Environment file ~/.config/prom_adapter.env not found.${NC}"
    echo "Please create it with your DATABASE_URL."
    exit 1
fi

if [ "$(uname -m)" != "arm64" ]; then
    echo -e "${YELLOW}WARNING: You are not on an arm64 (Apple Silicon) machine. This script is optimized for it.${NC}"
fi

# Check for ARM64 version of prometheus binary



# --- Main Startup Logic ---
echo -e "${GREEN}--- Starting All Project Services ---${NC}"
echo -e "${YELLOW}Each service will open in a new terminal tab.${NC}"

# --- Launch Concurrent Services ---

# Service 1: Prometheus PG Adapter
open_new_tab "Prom PG Adapter" "${PROJECT_ROOT}/packages/infra/prom-pg-adapter" 'echo "Loading environment variables..."; source ~/.config/prom_adapter.env; echo "Starting prom-pg-adapter..."; ./prom-pg-adapter -config.file=config.yml'

# Service 2: Prometheus Server
open_new_tab "Prometheus" "${PROJECT_ROOT}/packages/infra/prometheus" 'prometheus --config.file=prometheus.yml'

# Service 3: Node.js Backend App
open_new_tab "Node.js Backend" "${PROJECT_ROOT}/packages/main-app" 'echo "Running npm install..."; npm install; echo "Starting Node server on port 3000..."; npm start'

# Service 4: AI/ML Service - FastAPI Server (with venv)
open_new_tab "AI/ML API" "${PROJECT_ROOT}/packages/ai-ml-service" 'source .venv/bin/activate; echo "Installing Python dependencies..."; pip install -r requirements.txt; echo "Starting FastAPI server..."; uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload'

# Service 5: AI/ML Service - Feature Engineering Worker (with venv)
open_new_tab "Feature Worker" "${PROJECT_ROOT}/packages/ai-ml-service" 'sleep 5; source .venv/bin/activate; echo "Starting Feature Engineering Worker..."; python -m app.workers.feature_engineering_worker'

# Service 6: AI/ML Service - Prediction Worker (with venv)
open_new_tab "Prediction Worker" "${PROJECT_ROOT}/packages/ai-ml-service" 'sleep 5; source .venv/bin/activate; echo "Starting Prediction Worker..."; python -m app.workers.prediction_worker'

# Service 7: Node Simulator for metrics
open_new_tab "Node Simulator" "${PROJECT_ROOT}/packages/node_exporter_simulation" 'echo "Starting Node Simulator for instance test-simulator-1..."; python node_simulator.py --instance "test-simulator-1"'

echo -e "\n${GREEN}All services have been launched in new terminal tabs.${NC}"
echo -e "${YELLOW}Waiting for Node.js backend to start before syncing Prometheus...${NC}"

# --- Post-launch Task: Sync Prometheus Targets ---
sleep 10 # Give the Node.js server time to start
echo -e "\n${CYAN}--- Triggering Initial Prometheus Target Sync ---${NC}"
if curl -s -X POST http://localhost:${NODE_APP_PORT}/api/vms/sync-prometheus; then
    echo -e "\n${GREEN}Prometheus sync command sent successfully.${NC}"
    echo -e "${YELLOW}Check the Prometheus UI (http://localhost:9090/targets) in a minute to see the target status.${NC}"
else
    echo -e "\n${RED}ERROR: Failed to send sync command to Node.js backend.${NC}"
    echo -e "${YELLOW}Please ensure the backend is running on port ${NODE_APP_PORT} and trigger the sync manually.${NC}"
fi

echo -e "\n${GREEN}--- Startup Complete ---${NC}"

