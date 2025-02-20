#!/bin/bash

# Define service name and file path
SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/nexus.service"

# Define node ID file path
PROVER_ID_FILE="/root/.nexus/node-id"

# Script save path
SCRIPT_PATH="$HOME/nexus.sh"

# Check if the script is run as root user
if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run with root privileges."
    echo "Please try using the 'sudo -i' command to switch to root user and then run the script again."
    exit 1
fi

# Check if screen command is installed
function check_screen() {
    if ! command -v screen &> /dev/null; then
        echo "screen command not found, installing..."
        sudo apt install -y screen
        if ! command -v screen &> /dev/null; then
            echo "Failed to install screen, please install it manually and try again."
            exit 1
        else
            echo "screen installed successfully."
        fi
    else
        echo "screen is already installed."
    fi
}

# Main menu function
function main_menu() {
    while true; do
        clear
        echo -e ""
        echo -e '\e[34m'
        echo -e ' ██████╗██████╗ ██╗   ██╗██████╗ ████████╗ ██████╗  █████╗ ██╗██████╗ ██████╗ ██████╗  ██████╗ ██████╗ ██╗  ██╗██╗███╗   ██╗██████╗ ██╗'
        echo -e '██╔════╝██╔══██╗╚██╗ ██╔╝██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██║  ██║██║████╗  ██║██╔══██╗██║'
        echo -e '██║     ██████╔╝ ╚████╔╝ ██████╔╝   ██║   ██║   ██║███████║██║██████╔╝██║  ██║██████╔╝██║   ██║██████╔╝███████║██║██╔██╗ ██║██║  ██║██║'
        echo -e '██║     ██╔══██╗  ╚██╔╝  ██╔═══╝    ██║   ██║   ██║██╔══██║██║██╔══██╗██║  ██║██╔══██╗██║   ██║██╔═══╝ ██╔══██║██║██║╚██╗██║██║  ██║██║'
        echo -e '╚██████╗██║  ██║   ██║   ██║        ██║   ╚██████╔╝██║  ██║██║██║  ██║██████╔╝██║  ██║╚██████╔╝██║     ██║  ██║██║██║ ╚████║██████╔╝██║'
        echo -e ' ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝        ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝'
        echo -e '\e[0m'
        echo -e "                 \033[48;2;9;10;12m CryptoAirdropHindi \e[0m";
        echo -e "\e[0;37m Subscribe Our Telegram Channel: \e[4;35mhttps://t.me/Crypto_airdropHM/";
        echo "================================================================"
        echo "To exit the script, press ctrl + C."
        echo "Please choose an operation:"
        echo "1. Start Node"
        echo "2. Show ID"
        echo "3. Change ID"
        echo "4) Exit"
        
        read -p "Enter your choice (1-4): " choice
        
        case $choice in
            1)
                start_node
                ;;
            2)
                show_id
                ;;
            3)
                set_prover_id
                ;;
            4)
                echo "Exiting the script."
                exit 0
                ;;
            *)
                echo "Invalid option, please choose again."
                ;;
        esac
    done
}

# Show ID function
function show_id() {
    if [ -f /root/.nexus/node-id ]; then
        echo "Prover ID content:"
        echo "$(</root/.nexus/node-id)"
    else
        echo "File /root/.nexus/node-id does not exist."
    fi
    read -p "Press any key to return to the main menu"
}

# Set node ID function
function set_prover_id() {
    read -p "Please enter the new node ID: " new_id
    if [ -n "$new_id" ]; then
        echo "$new_id" > "$PROVER_ID_FILE"
        echo -e "${GREEN}Node ID has been successfully updated to: $new_id${NC}"
    else
        echo -e "${RED}Error: Node ID cannot be empty${NC}"
    fi
}

# Start node function
function start_node() {
    # Check if there is a screen session named nexus, if it exists, delete it
    if screen -list | grep -q "nexus"; then
        echo "Detected an existing 'nexus' screen session, deleting..."
        screen -S nexus -X quit
        echo "'nexus' screen session has been successfully deleted."
    fi

    # Update system and install necessary components
    echo "Updating system and installing necessary components..."
    if ! sudo apt update && sudo apt upgrade -y && sudo apt install -y build-essential pkg-config libssl-dev git-all protobuf-compiler curl unzip; then
        echo "Failed to install basic components"
        exit 1
    fi

    # Check and install screen
    check_screen

    # Install Rust
    echo "Installing Rust..."
    if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        echo "Rust installation failed"
        exit 1
    fi

    # Reload environment variables
    echo "Loading Rust environment..."
    source $HOME/.cargo/env
    export PATH="$HOME/.cargo/bin:$PATH"

    # Verify Rust installation
    if command -v rustc &> /dev/null; then
        echo "Rust installed successfully, current version: $(rustc --version)"
    else
        echo "Rust environment failed to load"
        exit 1
    fi

    # Install additional dependencies
    echo "Installing additional dependencies..."
    if ! sudo apt install -y libudev-dev liblzma-dev unzip; then
        echo "Failed to install additional dependencies"
        exit 1
    fi

    # Download and install protoc
    echo "Downloading and installing protoc..."
    PROTOC_VERSION="3.15.0"  # Set the required version
    curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-x86_64.zip"
    
    # Check if download is successful
    if [ ! -f "protoc-$PROTOC_VERSION-linux-x86_64.zip" ]; then
        echo "Failed to download protoc"
        exit 1
    fi

    # Unzip protoc
    if ! unzip "protoc-$PROTOC_VERSION-linux-x86_64.zip" -d protoc3; then
        echo "Failed to unzip protoc"
        exit 1
    fi

    # Install protoc
    if [ -d "protoc3/bin" ]; then
        sudo mv protoc3/bin/protoc /usr/local/bin/
    else
        echo "protoc binary file not found"
        exit 1
    fi

    if [ -d "protoc3/include" ]; then
        sudo mv protoc3/include/* /usr/local/include/
    else
        echo "protoc include files not found"
        exit 1
    fi

    # Clean up temporary files
    rm -rf protoc3 "protoc-$PROTOC_VERSION-linux-x86_64.zip"

    # Check if protoc is installed successfully
    if ! command -v protoc &> /dev/null; then
        echo "protoc installation failed"
        exit 1
    else
        echo "protoc installed successfully, version: $(protoc --version)"
    fi

    # Run the node in a screen session
    echo "Creating screen session and running node..."
    screen -S nexus -dm sh -c 'curl https://cli.nexus.xyz/ | sh'

    echo "Node started successfully! The node is running in the background."
    echo "Use the 'screen -r nexus' command to check the node's running status."
    read -p "Press any key to return to the main menu"
}

# Call the main menu function
main_menu
