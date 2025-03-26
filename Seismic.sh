#!/bin/bash

# One-Click Installer for Seismic Devnet Deployment
set -e

# ----------------------------
# Color Definitions
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
RESET='\033[0m'

# ----------------------------
# Text Elements
# ----------------------------
INSTALL="${GREEN}Install Seismic Devnet${NC}"
INFO="${CYAN}View Node Information${NC}"
LOGS="${YELLOW}View Logs${NC}"
RESTART="${BLUE}Restart Services${NC}"
STOP="${RED}Stop Services${NC}"
EXIT="${MAGENTA}Exit${NC}"
ERROR="${RED}Error${NC}"

# ----------------------------
# Installation Function
# ----------------------------
install_seismic() {
    echo -e "${GREEN}Starting Seismic Devnet installation...${NC}"
    
    # Update & install dependencies
    echo "Updating system and installing dependencies..."
    apt update && apt install -y curl jq unzip

    # Install Rust
    echo "Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"

    # Install sfoundryup
    echo "Installing sfoundryup..."
    curl -L -H "Accept: application/vnd.github.v3.raw" \
         "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash
    source ~/.bashrc

    # Run sfoundryup
    echo "Running sfoundryup... This may take some time."
    sfoundryup

    # Clone Seismic Devnet repository
    echo "Cloning Seismic Devnet repository..."
    git clone --recurse-submodules https://github.com/SeismicSystems/try-devnet.git
    cd try-devnet/packages/contract/

    # Deploy contract
    echo "Deploying contract..."
    bash script/deploy.sh

    # Install Bun
    echo "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    source ~/.bashrc

    # Install Node dependencies
    echo "Installing Node dependencies..."
    cd ../cli/
    bun install

    # Execute transactions
    echo "Executing transactions..."
    bash script/transact.sh

    echo -e "${GREEN}✅ Seismic Devnet setup & deployment completed successfully!${NC}"
    read -p "Press Enter to return to main menu..."
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
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} "
    echo -e "    ${CYAN}2.${RESET} ${INFO} "
    echo -e "    ${CYAN}3.${RESET} ${LOGS} "
    echo -e "    ${CYAN}4.${RESET} ${INFO} "
    echo -e "    ${CYAN}5.${RESET} ${INFO} "
    echo -e "    ${CYAN}6.${RESET} ${RESTART} "
    echo -e "    ${CYAN}7.${RESET} ${STOP} "
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
        1) 
            install_seismic
            ;;
        2) 
            echo -e "${CYAN}Node information will be displayed here...${NC}"
            read -p "Press Enter to continue..."
            ;;
        3) 
            echo -e "${YELLOW}Logs will be displayed here...${NC}"
            read -p "Press Enter to continue..."
            ;;
        4) 
            echo -e "${CYAN}Additional information will be displayed here...${NC}"
            read -p "Press Enter to continue..."
            ;;
        5) 
            echo -e "${CYAN}Node ID information will be displayed here...${NC}"
            read -p "Press Enter to continue..."
            ;;
        6) 
            echo -e "${BLUE}Restarting services...${NC}"
            read -p "Press Enter to continue..."
            ;;
        7) 
            echo -e "${RED}Stopping services...${NC}"
            read -p "Press Enter to continue..."
            ;;
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
