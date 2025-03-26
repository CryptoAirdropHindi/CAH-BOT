#!/bin/bash

# ----------------------------
# Colors for terminal output
# ----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
RESET='\033[0m'

# ----------------------------
# Install Seismic Foundry
# ----------------------------
install_seismic() {
    echo -e "${YELLOW}🚀 Installing Seismic Foundry...${NC}"

    # 0. Install system dependencies
    echo -e "${CYAN}🔧 Installing system dependencies...${NC}"
    if [[ -f /etc/debian_version ]]; then
        sudo apt update
        sudo apt install -y build-essential
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Ensure Xcode command line tools are installed on macOS
        xcode-select --install || true
    fi

    # 1. Install Rust (if not installed)
    if ! command -v rustc &> /dev/null; then
        echo -e "${CYAN}🔧 Installing Rust...${NC}"
        curl https://sh.rustup.rs -sSf | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        echo -e "${GREEN}✅ Rust already installed.${NC}"
    fi

    # 2. Install jq (JSON processor)
    if ! command -v jq &> /dev/null; then
        echo -e "${CYAN}🔧 Installing jq...${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        elif [[ -f /etc/debian_version ]]; then
            sudo apt-get update && sudo apt-get install -y jq
        else
            echo -e "${RED}❌ Unsupported OS. Install jq manually: https://stedolan.github.io/jq/download/${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ jq already installed.${NC}"
    fi

    # 3. Install sfoundryup
    echo -e "${CYAN}🔧 Installing sfoundryup...${NC}"
    curl -L \
         -H "Accept: application/vnd.github.v3.raw" \
         "https://api.github.com/repos/SeismicSystems/seismic-foundry/contents/sfoundryup/install?ref=seismic" | bash
    source ~/.bashrc || source ~/.zshrc

    # 4. Run sfoundryup
    echo -e "${YELLOW}⏳ Setting up Seismic Foundry (may take 5-60 mins)...${NC}"
    sfoundryup

    echo -e "${GREEN}🎉 Seismic Foundry installed successfully!${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Deploy Encrypted Contract
# ----------------------------
deploy_contract() {
    echo -e "${YELLOW}🚀 Deploying encrypted contract...${NC}"

    # 5. Clone repository
    if [ ! -d "try-devnet" ]; then
        echo -e "${CYAN}🔧 Cloning try-devnet repository...${NC}"
        git clone --recurse-submodules https://github.com/SeismicSystems/try-devnet.git
    else
        echo -e "${GREEN}✅ try-devnet already exists. Pulling latest changes...${NC}"
        cd try-devnet && git pull && git submodule update --init --recursive && cd ..
    fi

    # 6. Deploy contract
    echo -e "${CYAN}🔧 Deploying contract...${NC}"
    cd try-devnet/packages/contract/
    bash script/deploy.sh
    cd ../../

    echo -e "${GREEN}🎉 Contract deployed successfully!${NC}"
    read -p "Press Enter to continue..."
}

# ----------------------------
# Interact with Contract
# ----------------------------
interact_contract() {
    echo -e "${YELLOW}🔗 Interacting with contract...${NC}"

    # Check if try-devnet directory exists
    if [ ! -d "try-devnet" ]; then
        echo -e "${RED}❌ try-devnet directory not found. Please deploy a contract first (Option 2).${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    # Check if cli directory exists
    if [ ! -d "try-devnet/packages/cli" ]; then
        echo -e "${RED}❌ CLI package directory not found. The repository might not have been cloned properly.${NC}"
        read -p "Press Enter to continue..."
        return
    fi

    # Update and install zip (if not installed)
    echo -e "${CYAN}🔄 Updating packages and installing zip...${NC}"
    sudo apt update
    sudo apt install zip -y

    # 1. Install Bun (if not installed)
    if ! command -v bun &> /dev/null; then
        echo -e "${CYAN}🔧 Installing Bun...${NC}"
        curl -fsSL https://bun.sh/install | bash
        source ~/.bashrc || source ~/.zshrc
    else
        echo -e "${GREEN}✅ Bun already installed.${NC}"
    fi

    # 2. Install dependencies
    echo -e "${CYAN}📦 Installing Node dependencies...${NC}"
    cd try-devnet/packages/cli/
    
    if [ ! -f "package.json" ]; then
        echo -e "${RED}❌ package.json not found in CLI directory.${NC}"
        cd ../../../
        read -p "Press Enter to continue..."
        return
    fi
    
    bun install

    # 3. Send transactions
    echo -e "${YELLOW}💸 Sending test transactions...${NC}"
    if [ ! -f "script/transact.sh" ]; then
        echo -e "${RED}❌ transact.sh script not found.${NC}"
        cd ../../../
        read -p "Press Enter to continue..."
        return
    fi
    
    bash script/transact.sh

    cd ../../../
    echo -e "${GREEN}🎉 Transactions executed successfully!${NC}"
    read -p "Press Enter to continue..."
}


# ----------------------------
# Check Logs
# ----------------------------
check_logs() {
    echo -e "${YELLOW}📜 Checking logs...${NC}"
    
    # Check if try-devnet directory exists
    if [ ! -d "try-devnet" ]; then
        echo -e "${RED}❌ try-devnet directory not found. Please deploy a contract first.${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    # Check for log files
    if [ -f "try-devnet/packages/contract/logs/deploy.log" ]; then
        echo -e "${GREEN}✅ Deployment logs found:${NC}"
        echo -e "${CYAN}====== Deployment Logs ======${NC}"
        cat try-devnet/packages/contract/logs/deploy.log
        echo -e "${CYAN}============================${NC}"
    else
        echo -e "${YELLOW}⚠️ No deployment logs found.${NC}"
    fi
    
    if [ -f "try-devnet/packages/cli/logs/transactions.log" ]; then
        echo -e "${GREEN}✅ Transaction logs found:${NC}"
        echo -e "${CYAN}====== Transaction Logs ======${NC}"
        cat try-devnet/packages/cli/logs/transactions.log
        echo -e "${CYAN}=============================${NC}"
    else
        echo -e "${YELLOW}⚠️ No transaction logs found.${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# ----------------------------
# ASCII Art Header
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
    echo -e "${CYAN}=== Telegram Channel: CryptoAirdropHindi @CryptoAirdropHindi ===${NC}"  
    echo -e "${CYAN}=== Follow us on social media for updates and more ===${NC}"
    echo -e "=== 📱 Telegram: https://t.me/CryptoAirdropHindi6 ==="
    echo -e "=== 🎥 YouTube: https://www.youtube.com/@CryptoAirdropHindi6 ==="
    echo -e "=== 💻 GitHub Repo: https://github.com/CryptoAirdropHindi/ ==="
}

# ----------------------------
# Main Menu
# ----------------------------
show_menu() {
    display_ascii
    echo -e "    ${YELLOW}Choose an operation:${RESET}"
    echo -e "    ${CYAN}1.${RESET} Install Seismic Foundry"
    echo -e "    ${CYAN}2.${RESET} Deploy Encrypted Contract"
    echo -e "    ${CYAN}3.${RESET} Interact with Contract"
    echo -e "    ${CYAN}4.${RESET} Check Logs"
    echo -e "    ${CYAN}5.${RESET} Exit"
    echo -ne "    ${YELLOW}Enter your choice [1-5]: ${RESET}"
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
            deploy_contract
            ;;
        3) 
            interact_contract
            ;;
        4)
            check_logs
            ;;
        5)
            echo -e "${RED}👋 Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option. Please try again.${RESET}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
