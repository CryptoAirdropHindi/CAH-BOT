#!/bin/bash

# Define service name and file path
SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/nexus.service"

# Define node ID file path
PROVER_ID_FILE="/root/.nexus/node-id"

# Script save path
SCRIPT_PATH="$HOME/nexus.sh"

# Check if the script is running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run with root privileges."
    echo "Please try using 'sudo -i' to switch to the root user and run the script again."
    exit 1
fi

# Check if tmux command is installed
function check_tmux() {
    if ! command -v tmux &> /dev/null; then
        echo "tmux command not found, installing..."
        sudo apt install -y tmux
        if ! command -v tmux &> /dev/null; then
            echo "Failed to install tmux. Please install it manually and try again."
            exit 1
        else
            echo "tmux installed successfully."
        fi
    else
        echo "tmux is already installed."
    fi
}

# Install OpenSSL and dependencies
function install_openssl() {
    echo "Installing OpenSSL and related dependencies..."
    # Install necessary development packages and tools
    if ! sudo apt install -y build-essential pkg-config libssl-dev libudev-dev liblzma-dev unzip; then
        echo "Failed to install OpenSSL or related dependencies"
        exit 1
    fi

    # Ensure gcc compiler and make tool are installed
    echo "Installing gcc and make tools..."
    if ! sudo apt install -y gcc make; then
        echo "Failed to install gcc or make tools"
        exit 1
    fi
}

# Start the node function
function start_node() {
    # Install OpenSSL dependencies
    install_openssl

    # Check if there is an existing 'nexus' screen session, if so, remove it
    if screen -list | grep -q "nexus"; then
        echo "Found existing 'nexus' screen session, removing..."
        screen -S nexus -X quit
        echo "'nexus' screen session successfully removed."
    fi

    # Update the system and install necessary components
    echo "Updating the system and installing necessary components..."
    if ! sudo apt update && sudo apt upgrade -y && sudo apt install -y git-all protobuf-compiler curl screen; then
        echo "Failed to install base components"
        exit 1
    fi

    # Install Rust
    echo "Installing Rust..."
    if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        echo "Failed to install Rust"
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

    # Download and install protoc
    echo "Downloading and installing protoc..."
    PROTOC_VERSION="3.15.0"  # Set the required version
    curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-x86_64.zip"
    
    # Check if download was successful
    if [ ! -f "protoc-$PROTOC_VERSION-linux-x86_64.zip" ]; then
        echo "protoc download failed"
        exit 1
    fi

    # Extract protoc
    if ! unzip "protoc-$PROTOC_VERSION-linux-x86_64.zip" -d protoc3; then
        echo "Failed to unzip protoc"
        exit 1
    fi

    # Install protoc
    if [ -d "protoc3/bin" ]; then
        sudo mv protoc3/bin/protoc /usr/local/bin/
    else
        echo "protoc binary not found"
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

    # Verify protoc installation
    if ! command -v protoc &> /dev/null; then
        echo "protoc installation failed"
        exit 1
    else
        echo "protoc installed successfully, version: $(protoc --version)"
    fi

    # Use screen to run the node command in the background
    echo "Starting the node..."
    screen -S nexus -dm sh -c 'curl https://cli.nexus.xyz/ | sh'

    echo "Node started successfully in the background!"
    echo "You can use 'screen -r nexus' to view the node status."
    read -p "Press any key to return to the main menu"
}

# Main menu function
function main_menu() {
    while true; do
        clear
        echo "Don't forget to check out our official channels:"
        echo "📱 Telegram: https://t.me/Crypto_airdropHM"
        echo "🎥 YouTube: https://www.youtube.com/@CryptoAirdropHindi6"
        echo "💻 GitHub Repo: https://github.com/CryptoAirdropHindi/"
        echo "================================================================"
        echo "To exit the script, press ctrl + C on your keyboard."
        echo "Please choose the action to perform:"
        echo "1. Start node"
        echo "2. Display ID" 
        echo "3. Change ID"
        echo "4) Exit"
        
        read -p "Enter choice (1-4): " choice
        
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
                echo "Invalid option, please try again."
                ;;
        esac
    done
}

# Show ID function
function show_id() {
    if [ -f /root/.nexus/node-id ]; then
        echo "Prover ID contents:"
        echo "$(</root/.nexus/node-id)"
    else
        echo "File /root/.nexus/node-id does not exist."
    fi
    read -p "Press any key to return to the main menu"
}

# Set node ID function
function set_prover_id() {
    read -p "Enter the new node ID: " new_id
    if [ -n "$new_id" ]; then
        echo "$new_id" > "$PROVER_ID_FILE"
        echo -e "${GREEN}Node ID successfully updated to: $new_id${NC}"
    else
        echo -e "${RED}Error: Node ID cannot be empty${NC}"
    fi
}

# Call main menu function
main_menu
