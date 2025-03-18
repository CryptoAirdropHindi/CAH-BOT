#!/bin/bash

# Script path
SCRIPT_PATH="$HOME/t3rn.sh"
LOGFILE="$HOME/executor/executor.log"
EXECUTOR_DIR="$HOME/executor"

# Check if the script is being run as root user
if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges."
    echo "Please try switching to the root user using 'sudo -i' and run the script again."
    exit 1
fi

# Main menu function
function main_menu() {
    while true; do
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
        echo "To exit the script, press Ctrl + C."
        echo "Please select the operation you want to perform:"
        echo "1) Execute script"
        echo "2) View logs"
        echo "3) Delete node"
        echo "5) Exit"
        
        read -p "Please enter your choice [1-3]: " choice
        
        case $choice in
            1)
                execute_script
                ;;
            2)
                view_logs
                ;;
            3)
                delete_node
                ;;
            5)
                echo "Exiting the script."
                exit 0
                ;;
            *)
                echo "Invalid choice, please try again."
                ;;
        esac
    done
}

# Execute script function
function execute_script() {
    # Check if pm2 is installed, if not, install it
    if ! command -v pm2 &> /dev/null; then
        echo "pm2 is not installed, installing pm2..."
        # Install pm2
        sudo npm install -g pm2
        if [ $? -eq 0 ]; then
            echo "pm2 installed successfully."
        else
            echo "pm2 installation failed, please check npm configuration."
            exit 1
        fi
    else
        echo "pm2 is already installed, proceeding."
    fi

    # Download the latest version of the executor
    echo "Downloading the latest version of executor..."
    curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
    grep -Po '"tag_name": "\K.*?(?=")' | \
    xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo "Download successful."
    else
        echo "Download failed, please check network connection or download URL."
        exit 1
    fi

    # Extract the downloaded file
    echo "Extracting the file..."
    tar -xzf executor-linux-*.tar.gz

    # Check if extraction was successful
    if [ $? -eq 0 ]; then
        echo "Extraction successful."
    else
        echo "Extraction failed, please check the tar.gz file."
        exit 1
    fi

    # Check if the extracted file or directory contains 'executor'
    echo "Checking if the extracted file or directory contains 'executor'..."
    if ls | grep -q 'executor'; then
        echo "Check passed, found a file or directory containing 'executor'."
    else
        echo "No file or directory containing 'executor' found, the file name may be incorrect."
        exit 1
    fi

    # Prompt user to input value for EXECUTOR_MAX_L3_GAS_PRICE, default to 100 if empty
    read -p "Enter the value for EXECUTOR_MAX_L3_GAS_PRICE [default 100]: " EXECUTOR_MAX_L3_GAS_PRICE
    EXECUTOR_MAX_L3_GAS_PRICE="${EXECUTOR_MAX_L3_GAS_PRICE:-100}"

    # Set environment variables
    export ENVIRONMENT=testnet
    export LOG_LEVEL=debug
    export LOG_PRETTY=false
    export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,unichain-sepolia,optimism-sepolia,l2rn'
    export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
    export EXECUTOR_MAX_L3_GAS_PRICE="$EXECUTOR_MAX_L3_GAS_PRICE"

    # New environment variables
    export EXECUTOR_PROCESS_BIDS_ENABLED=true
    export EXECUTOR_PROCESS_ORDERS_ENABLED=true
    export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
    export RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"]
    }'

    # Prompt user to input private key
    read -p "Enter the value for PRIVATE_KEY_LOCAL: " PRIVATE_KEY_LOCAL

    # Set private key variable
    export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL"

    # Delete the compressed file
    echo "Deleting the compressed file..."
    rm executor-linux-*.tar.gz

    # Change directory to executor/bin
    echo "Changing directory and preparing to start executor with pm2..."
    cd ~/executor/executor/bin

    # Use pm2 to start executor
    echo "Starting executor with pm2..."
    pm2 start ./executor --name "executor" --log "$LOGFILE" --env NODE_ENV=testnet

    # Show pm2 process list
    pm2 list

    echo "Executor has been started with pm2."

    # Prompt user to press any key to return to the main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# View logs function
function view_logs() {
    if [ -f "$LOGFILE" ]; then
        echo "Displaying real-time log file content (press Ctrl+C to exit):"
        tail -f "$LOGFILE"  # Use tail -f to monitor the log file in real time
    else
        echo "Log file does not exist."
    fi
}

# Delete node function
function delete_node() {
    echo "Stopping the node process..."

    # Stop the executor process with pm2
    pm2 stop "executor"

    # Delete the executor directory
    if [ -d "$EXECUTOR_DIR" ]; then
        echo "Deleting the node directory..."
        rm -rf "$EXECUTOR_DIR"
        echo "Node directory deleted."
    else
        echo "Node directory does not exist, it may have already been deleted."
    fi

    echo "Node deletion operation completed."

    # Prompt user to press any key to return to the main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# Start the main menu
main_menu
