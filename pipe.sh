#!/bin/bash

# ----------------------------
# Color and Icon Definitions
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
# Install Pipe Node
# ----------------------------
install_pipe_node() {
    echo -e "${INSTALL} Installing Pipe Node...${RESET}"
    
    # Ask user for parameters with minimal validations
    read -p "Enter RAM value (minimum 4): " ram
    if [[ $ram -lt 4 ]]; then
        echo -e "${ERROR} RAM value must be at least 4. Aborting installation.${RESET}"
        read -p "Press Enter to return to the main menu."
        return
    fi

    read -p "Enter max-disk value (minimum 100): " max_disk
    if [[ $max_disk -lt 100 ]]; then
        echo -e "${ERROR} max-disk must be at least 100. Aborting installation.${RESET}"
        read -p "Press Enter to return to the main menu."
        return
    fi

    read -p "Enter SOLADDRESS: " soladdress
    if [ -z "$soladdress" ]; then
        echo -e "${ERROR} SOLADDRESS cannot be empty. Aborting installation.${RESET}"
        read -p "Press Enter to return to the main menu."
        return
    fi

    # Use current directory as working directory (no directory creation)
    curr_dir=$(pwd)

    # Download and set permission for the pop binary
    wget -O pop "https://dl.pipecdn.app/v0.2.8/pop"
    chmod +x pop

    sudo ./pop  --ram ${ram}   --max-disk ${max_disk}  --cache-dir ${curr_dir}/download_cache --pubKey ${soladdress} --signup-by-referral-route e70d24f2d1553964

    # Create systemd service file for Pipe Node
    sudo tee /etc/systemd/system/pipe.service > /dev/null << EOF
[Unit]
Description=Pipe Node Service
After=network.target
Wants=network-online.target

[Service]
User=root
Group=root
WorkingDirectory=${curr_dir}
ExecStart=${curr_dir}/pop \\
    --ram ${ram} \\
    --max-disk ${max_disk} \\
    --cache-dir ${curr_dir}/download_cache \\
    --pubKey ${soladdress} 
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=pipe-node

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable pipe
    sudo systemctl start pipe

    echo -e "${CHECKMARK} Pipe Node installed and started successfully.${RESET}"
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Check Health of Pipe Node
# ----------------------------
check_health() {
    echo -e "${INFO} Checking Pipe Node health...${RESET}"
    sudo systemctl status pipe
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Check Pipe Node Logs
# ----------------------------
check_logs() {
    echo -e "${LOGS} Showing last 100 lines of Pipe Node logs...${RESET}"
    journalctl -u pipe -n 30
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Check Node Reputation / Status
# ----------------------------
check_node_status() {
    echo -e "${INFO} Checking node reputation and status...${RESET}"
    # Ensure we are in the proper directory
    cd /root/pipe || return
    ./pop --status
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Display node_info.json
# ----------------------------
display_node_info() {
    echo -e "${ID} Displaying node_info.json...${RESET}"
    if [ -f /root/pipe/node_info.json ]; then
        cat /root/pipe/node_info.json
    else
        echo -e "${ERROR} node_info.json not found in /root/pipe.${RESET}"
    fi
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Restart Pipe Node
# ----------------------------
restart_node() {
    echo -e "${RESTART} Restarting Pipe Node...${RESET}"
    sudo systemctl daemon-reload
    sudo systemctl enable pipe
    sudo systemctl restart pipe
    echo -e "${CHECKMARK} Pipe Node restarted successfully.${RESET}"
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Stop Pipe Node
# ----------------------------
stop_node() {
    echo -e "${STOP} Stopping Pipe Node...${RESET}"
    sudo systemctl stop pipe
    echo -e "${CHECKMARK} Pipe Node stopped successfully.${RESET}"
    read -p "Press Enter to return to the main menu."
}

# ----------------------------
# Display ASCII Art Header
# ----------------------------
display_ascii() {
    clear
    echo -e "    ${RED}    ____  __ __    _   ______  ____  ___________${NC}"
    echo -e "    ${GREEN}   / __ \\/ //_/   / | / / __ \\/ __ \\/ ____/ ___/${NC}"
    echo -e "    ${BLUE}  / / / / ,<     /  |/ / / / / / / / __/  \\__ \\ ${NC}"
    echo -e "    ${YELLOW} / /_/ / /| |   / /|  / /_/ / /_/ / /___ ___/ / ${NC}"
    echo -e "    ${MAGENTA}/_____/_/ |_|  /_/ |_/\____/_____/_____//____/  ${NC}"
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
    echo -e "    ${CYAN}1.${RESET} ${INSTALL} Install Pipe Node"
    echo -e "    ${CYAN}2.${RESET} ${INFO} Check Node Health"
    echo -e "    ${CYAN}3.${RESET} ${LOGS} Check Node Logs"
    echo -e "    ${CYAN}4.${RESET} ${INFO} Check Node Reputation/Status"
    echo -e "    ${CYAN}5.${RESET} ${ID} Display node_info.json"
    echo -e "    ${CYAN}6.${RESET} ${RESTART} Restart Node"
    echo -e "    ${CYAN}7.${RESET} ${STOP} Stop Node"
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
        1) install_pipe_node;;
        2) check_health;;
        3) check_logs;;
        4) check_node_status;;
        5) display_node_info;;
        6) restart_node;;
        7) stop_node;;
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
