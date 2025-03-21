#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if a command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Success!${NC}"
    else
        echo -e "${RED}Failed!${NC}"
        exit 1
    fi
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

# Display the ASCII art header
display_ascii

# Update System
echo -e "${YELLOW}Updating system...${NC}"
sudo apt update && sudo apt upgrade -y
check_success

# Install Rust
echo -e "${YELLOW}Installing Rust...${NC}"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
check_success

# Activate Rust Environment
echo -e "${YELLOW}Activating Rust environment...${NC}"
source $HOME/.cargo/env
check_success

# Verify Rust Installation
echo -e "${YELLOW}Verifying Rust installation...${NC}"
rustc --version
check_success
cargo --version
check_success

# Persist the Rust Environment
echo -e "${YELLOW}Persisting Rust environment...${NC}"
echo 'source $HOME/.cargo/env' >> ~/.bashrc
source ~/.bashrc
check_success

# Install Soundness Tools
echo -e "${YELLOW}Installing Soundness Tools...${NC}"
curl -sSL https://raw.githubusercontent.com/soundnesslabs/soundness-layer/main/soundnessup/install | bash
check_success

# Source the Bash Configuration
echo -e "${YELLOW}Sourcing bash configuration...${NC}"
source ~/.bashrc
check_success

# Install and Update Soundness
echo -e "${YELLOW}Installing and updating Soundness...${NC}"
soundnessup install
check_success
soundnessup update
check_success

# Generate a Key
echo -e "${YELLOW}Generating a key...${NC}"
soundness-cli generate-key --name my-key
check_success

echo -e "${GREEN}Setup completed successfully!${NC}"

# Pause before exiting
read -p "Press Enter to exit..."
