#!/bin/bash

# ----------------------------
# Color Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
RESET='\033[0m'
INSTALL='\033[1;32m'
INFO='\033[1;34m'
LOGS='\033[1;33m'
ID='\033[1;36m'
RESTART='\033[1;35m'
STOP='\033[1;31m'
EXIT='\033[1;31m'
ERROR='\033[1;31m'


# ----------------------------
# Install Rust
# ----------------------------
Install Required Dependencies() {
    echo -e "${INSTALL}Install Required Dependencies...${NC}"
# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y nano screen build-essential gcc

# Install Go
echo "Installing Go..."
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile
source $HOME/.bash_profile
go version

    # Install Rust
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env

    # Install Risc0 Toolchain
    echo "Installing Risc0 Toolchain..."
    curl -L https://risczero.com/install | bash
    source "$HOME/.bashrc"
    rzup install
    source "$HOME/.bashrc"

    # Install Cargo (if not already installed)
    echo "Installing Cargo..."
    sudo apt install -y cargo

    echo -e "${GREEN}Install Required Dependencies installed successfully!${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Light Node Install
# ----------------------------
light_node_install() {
    echo -e "${INFO}Installing Light Node...${NC}"
    git clone https://github.com/Layer-Edge/light-node
    cd light-node
    echo -e "${GREEN}Light Node installed successfully!${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Configure Private Key
# ----------------------------
configure_private_key() {
echo -e "${LOGS}Configuring Private Key...${NC}"

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
echo -e "${GREEN}Private Key configured successfully!${NC}"
read -p "Press Enter to continue..."
}

# ----------------------------
# Start the Merkle Service
# ----------------------------
start_merkle_service() {
    echo -e "${INFO}Starting Merkle Service...${NC}"
    screen -S rsic -dm bash -c 'cd $HOME/light-node/risc0-merkle-service; cargo build && cargo run'
    echo -e "${GREEN}Merkle Service started in a screen session. Use 'screen -r rsic' to attach.${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Run the LayerEdge Light Node
# ----------------------------
run_light_node() {
    echo -e "${ID}Running LayerEdge Light Node...${NC}"
    screen -S lightnode -dm bash -c 'cd $HOME/light-node; go build; ./light-node'
    echo -e "${GREEN}Light Node started in a screen session. Use 'screen -r lightnode' to attach.${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Check Logs
# ----------------------------
check_logs() {
    echo -e "${RESTART}Checking logs...${NC}"
    sudo journalctl -fu lightnode.service
    read -p "Press Enter to continue..."
}

# ----------------------------
# Fetch Points via CLI
# ----------------------------
fetch_points() {
    echo -e "${STOP}Fetching Points...${NC}"
    read -p "Enter your wallet address: " wallet_address
    curl "https://light-node.layeredge.io/api/cli-node/points/${wallet_address}"
    echo -e "${GREEN}Points fetched successfully!${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Display ASCII Art Header
# ----------------------------
display_ascii() {
    clear
    echo -e "    ${RED}██╗  ██╗ █████╗ ███████╗ █████╗ ███╗   ██╗${NC}"
    echo -e "    ${GREEN}██║  ██║██╔══██╗██╔════╝██╔══██╗████╗  ██║${NC}"
    echo -e "    ${BLUE}███████║███████║███████╗███████║██╔██╗ ██║${NC}"
    echo -e "    ${YELLOW}██╔══██║██╔══██║╚════██║██╔══██║██║╚██╗██║${NC}"
    echo -e "    ${MAGENTA}██║  ██║██║  ██║███████║██║  ██║██║ ╚████║${NC}"
    echo -e "    ${CYAN}╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo "================================================================"
    echo -e "${CYAN}=== Telegram Channel : (CryptoAirdropHindi) (@CryptoAirdropHindi) ===${NC}"  
    echo -e "${CYAN}=== Follow us on social media for updates and more ===${NC}"
    echo -e "=== 📱 Telegram: https://t.me/CryptoAirdropHindi6 ==="
    echo -e "=== 🎥 YouTube: https://www.youtube.com/@CryptoAirdropHindi6 ==="
    echo -e "=== 💻 GitHub Repo: https://github.com/CryptoAirdropHindi/ ==="
}

# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    clear
    display_ascii
    echo -e "    ${YELLOW}Choose an operation:${RESET}"
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install Required Dependencies"
    echo -e "    ${CYAN}2.${RESET} ${INFO} Light Node Install"
    echo -e "    ${CYAN}3.${RESET} ${LOGS} Configure Private Key"
    echo -e "    ${CYAN}4.${RESET} ${INFO} Start the Merkle Service"
    echo -e "    ${CYAN}5.${RESET} ${ID} Run the LayerEdge Light Node"
    echo -e "    ${CYAN}6.${RESET} ${RESTART} Check logs"
    echo -e "    ${CYAN}7.${RESET} ${STOP} Fetch Points via CLI"
    echo -e "    ${CYAN}8.${RESET} ${EXIT} Exit"
    echo -ne "    ${YELLOW}Enter your choice [1-8]: ${RESET}"
}

# ----------------------------
# Main Loop
# ----------------------------
while true; do
    show_menu
    read choice
    case $choice in
        1) Install_Required_Dependencies;;
        2) light_node_install;;
        3) configure_private_key;;
        4) start_merkle_service;;
        5) run_light_node;;
        6) check_logs;;
        7) fetch_points;;
        8)
            echo -e "${EXIT} Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${ERROR} Invalid option. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
