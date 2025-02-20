#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

curl -s https://raw.githubusercontent.com/CryptoAirdropHindi/Tools/refs/heads/main/logo.sh | bash
echo "Starting Auto Nexus"
sleep 5

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local border="-----------------------------------------------------"
    
    echo -e "${border}"
    case $level in
        "INFO") echo -e "${CYAN}[INFO] ${timestamp} - ${message}${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS] ${timestamp} - ${message}${NC}" ;;
        "ERROR") echo -e "${RED}[ERROR] ${timestamp} - ${message}${NC}" ;;
        *) echo -e "${YELLOW}[UNKNOWN] ${timestamp} - ${message}${NC}" ;;
    esac
    echo -e "${border}\n"
}

common() {
    local duration=$1
    local message=$2
    local end=$((SECONDS + duration))
    local spinner="⣷⣯⣟⡿⣿⡿⣟⣯⣷"
    
    echo -n -e "${YELLOW}${message}...${NC} "
    while [ $SECONDS -lt $end ]; do
        printf "\b${spinner:((SECONDS % ${#spinner}))%${#spinner}:1}"
        sleep 0.1
    done
    printf "\r${GREEN}Done!${NC} \n"
}

log "INFO" "Updating system..."
sudo apt update && sudo apt upgrade -y

if ! command -v rustc &> /dev/null; then
    log "INFO" "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

if ! command -v rush &> /dev/null; then
    log "INFO" "Installing rush..."
    cargo install rush
fi

curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-x86_64.zip
unzip protoc-25.2-linux-x86_64.zip -d $HOME/.local
export PATH="$HOME/.local/bin:$PATH"

sudo apt install -y build-essential pkg-config libssl-dev git-all

rustup target add riscv32i-unknown-none-elf
rustup update
rustup component add rust-src

cargo install cargo-zigbuild

rm -f protoc-25.2-linux-x86_64.zip

log "INFO" "Entering screen session for Nexus installation..."
screen -S nexus -dm bash -c 'curl https://cli.nexus.xyz/ | sh'

log "SUCCESS" "Nexus installation started in screen session. Use 'screen -r nexus' to attach."
