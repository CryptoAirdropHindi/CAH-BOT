#!/bin/bash

# ----------------------------
# Color Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

CHECKMARK="✅"
ERROR="❌"
PROGRESS="⏳"
INSTALL="🛠️"
STOP="⏹️"
RESTART="🔄"
LOGS="📄"
EXIT="🚪"
INFO="ℹ️"
ID="🆔"

# ----------------------------
# Install Node & Setup Functions
# ----------------------------
install_layeredge() {
    echo -e "${INSTALL} Installing LayerEdge Node...${RESET}"
    
    # Update Server
    echo -e "${PROGRESS} Updating server...${RESET}"
    sudo apt update -y && sudo apt upgrade -y

    # Install dependencies
    echo -e "${PROGRESS} Installing necessary packages...${RESET}"
    sudo apt install htop ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev tmux iptables curl nvme-cli git wget make jq libleveldb-dev build-essential pkg-config ncdu tar clang bsdmainutils lsb-release libssl-dev libreadline-dev libffi-dev jq gcc screen unzip lz4 -y

    # Install Go
    echo -e "${PROGRESS} Installing Go...${RESET}"
    wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    go version

    # Install Rust
    echo -e "${PROGRESS} Installing Rust...${RESET}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
    rustc --version

    # Install Risc0
    echo -e "${PROGRESS} Installing Risc0...${RESET}"
    curl -L https://risczero.com/install | bash
    source "/root/.bashrc"
    rzup install
    rzup --version

 # Install Docker only if not already installed
if ! command -v docker &> /dev/null; then
    echo -e "${PROGRESS} Installing Docker...${RESET}"
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker $(whoami)
    docker --version
else
    echo -e "${CHECKMARK} Docker is already installed.${RESET}"
fi


    # Clone LayerEdge Repo
    echo -e "${PROGRESS} Cloning LayerEdge repository...${RESET}"
    git clone https://github.com/Layer-Edge/light-node.git
    cd light-node

    echo -e "${CHECKMARK} LayerEdge Node installation complete.${RESET}"
}

# ----------------------------
# Configure LayerEdge Node
# ----------------------------
configure_layeredge() {
    echo -e "${INFO} Configuring LayerEdge Node...${RESET}"

    # Ask user for private key and configuration details
    read -p "Enter your private key (without 0x): " private_key

    echo -e "${PROGRESS} Editing .env file...${RESET}"
    cat <<EOF > .env
export GRPC_URL=34.31.74.109:9090
export CONTRACT_ADDR=cosmos1ufs3tlq4umljk0qfe8k5ya0x6hpavn897u2cnf9k0en9jr7qarqqt56709
export ZK_PROVER_URL=http://127.0.0.1:3001
export API_REQUEST_TIMEOUT=100
export POINTS_API=http://127.0.0.1:8080
export PRIVATE_KEY='$private_key'
EOF

    echo -e "${CHECKMARK} Configuration complete.${RESET}"
}

echo -e "🛠️ Building and running risc0-merkle-service..."
cd risc0-merkle-service
cargo build && screen -dmS risc0-service cargo run && echo -e "🚀 risc0-merkle-service is running in a screen session!"

# ----------------------------
# Start LayerEdge Node in Screen
# ----------------------------
start_node() {
    echo -e "${INFO} Starting LayerEdge Node in a screen session...${RESET}"

    # Navigate to the correct directory if needed
    cd ~/light-node || exit

    # Ensure that the build and execute process is automated
    echo -e "${PROGRESS} Building light-node...${RESET}"
    go build
    if [[ $? -ne 0 ]]; then
        echo -e "${ERROR} Build failed! Please check the logs for errors.${RESET}"
        exit 1
    fi

    # Create a screen session for LayerEdge Node
    screen -S layeredge -d -m bash -c "
        echo '${PROGRESS} Starting LayerEdge Node...${RESET}' && 
        chmod +x light-node && 
        ./light-node
    "
    
    echo -e "${CHECKMARK} LayerEdge Node is running in screen session.${RESET}"
    echo -e "${INFO} To reattach to the LayerEdge node, run: screen -r layeredge${RESET}"
}

# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    clear
    echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${RESET}"
    echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${RESET}"
    echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${RESET}"
    echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${RESET}"
    echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${RESET}"
    echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${RESET}"
    echo -e "    ${RED}===============================${RESET}"
    echo -e "    ${GREEN}LayerEdge Auto Bot Setup${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install LayerEdge Node"
    echo -e "    ${CYAN}2.${RESET} ${INFO} Configure LayerEdge Node"
    echo -e "    ${CYAN}3.${RESET} ${INFO} Run Merkle Service"
    echo -e "    ${CYAN}4.${RESET} ${RESTART} Start LayerEdge Node"
    echo -e "    ${CYAN}5.${RESET} ${EXIT} Exit"
    echo -ne "    ${YELLOW}Enter your choice [1-5]: ${RESET}"
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1) install_layeredge;;
        2) configure_layeredge;;
        3) run_merkle;;
        4) start_node;;
        5)
            echo -e "${EXIT} Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${ERROR} Invalid option. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
