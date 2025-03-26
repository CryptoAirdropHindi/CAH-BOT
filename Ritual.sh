#!/bin/bash

# Check if the script is being run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script needs to be run as root."
    echo "Please try using 'sudo -i' to switch to the root user and run the script again."
    exit 1
fi

# Script save path
SCRIPT_PATH="$HOME/Ritual.sh"

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
            echo -e "${CYAN}=== Telegram Channel : (CryptoAirdropHindi) (@CryptoAirdropHindi) ===${NC}"  
            echo -e "${CYAN}=== Follow us on social media for updates and more ===${NC}"
            echo -e "=== 📱 Telegram: https://t.me/CryptoAirdropHindi6 ==="
            echo -e "=== 🎥 YouTube: https://www.youtube.com/@CryptoAirdropHindi6 ==="
            echo -e "=== 💻 GitHub Repo: https://github.com/CryptoAirdropHindi/ ==="
            echo "This script is written by the Da Du Community, hahahaha."
            echo "free and open source, do not trust paid versions."
            echo "If you have any questions, contact via telegram. This is the only account."
            echo "================================================================"
            echo "To exit the script, press ctrl + C."
            echo "Please choose an operation:"
            echo "1. Install Ritual Node"
            echo "2. View Ritual Node Logs"
            echo "3. Remove Ritual Node"
            echo "4. Exit script"
        
        read -p "Enter your choice: " choice

        case $choice in
            1) 
                install_ritual_node
                ;;
            2)
                view_logs
                ;;
            3)
                remove_ritual_node
                ;;
            4)
                echo "Exiting the script!"
                exit 0
                ;;
            *)
                echo "Invalid option, please try again."
                ;;
        esac

        echo "Press any key to continue..."
        read -n 1 -s
    done
}

# Install Ritual Node
function install_ritual_node() {
    echo "Starting installation of Ritual Node..."

    # Update system and install dependencies
    echo "Updating system..."
    sudo apt update && sudo apt upgrade -y

    echo "Installing required packages..."
    sudo apt -qy install curl git jq lz4 build-essential screen

    # Check for Docker and Docker Compose
    echo "Checking if Docker is installed..."
    if ! command -v docker &> /dev/null
    then
        echo "Docker is not installed, installing Docker..."
        sudo apt -qy install docker.io
    else
        echo "Docker is already installed"
    fi

    echo "Checking if Docker Compose is installed..."
    if ! command -v docker-compose &> /dev/null
    then
        echo "Docker Compose is not installed, installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose is already installed"
    fi

    # Clone Git repository and configure
    echo "Cloning the repository from GitHub..."
    git clone https://github.com/ritual-net/infernet-container-starter ~/infernet-container-starter
    cd ~/infernet-container-starter

    # User input for private key (input is invisible)
    echo "Please enter your wallet private key (input will be hidden):"
    read -s PRIVATE_KEY

    # Write configuration file
    echo "Writing the configuration file..."
    cat > deploy/config.json <<EOL
{
    "log_path": "infernet_node.log",
    "server": {
        "port": 4000,
        "rate_limit": {
            "num_requests": 100,
            "period": 100
        }
    },
    "chain": {
        "enabled": true,
        "trail_head_blocks": 3,
        "rpc_url": "https://mainnet.base.org/",
        "registry_address": "0x3B1554f346DFe5c482Bb4BA31b880c1C18412170",
        "wallet": {
          "max_gas_limit": 4000000,
          "private_key": "$PRIVATE_KEY",
          "allowed_sim_errors": []
        },
        "snapshot_sync": {
          "sleep": 3,
          "batch_size": 10000,
          "starting_sub_id": 180000,
          "sync_period": 30
        }
    },
    "startup_wait": 1.0,
    "redis": {
        "host": "redis",
        "port": 6379
    },
    "forward_stats": true,
    "containers": [
        {
            "id": "hello-world",
            "image": "ritualnetwork/hello-world-infernet:latest",
            "external": true,
            "port": "3000",
            "allowed_delegate_addresses": [],
            "allowed_addresses": [],
            "allowed_ips": [],
            "command": "--bind=0.0.0.0:3000 --workers=2",
            "env": {},
            "volumes": [],
            "accepted_payments": {},
            "generates_proofs": false
        }
    ]
}
EOL

    echo "Configuration file successfully written!"

    # Install Foundry
    echo "Installing Foundry..."
    mkdir -p ~/foundry && cd ~/foundry
    curl -L https://foundry.paradigm.xyz | bash

    # Immediately load new environment variables
    source ~/.bashrc

    # Wait for environment variables to take effect
    echo "Waiting for Foundry environment variables to take effect..."
    sleep 2

    # Verify if `foundryup` is installed successfully
    foundryup
    if [ $? -ne 0 ]; then
        echo "foundryup installation failed, command not found. Please check the installation process."
        exit 1
    fi

    echo "Foundry installation complete!"

    # Install contract dependencies
    echo "Entering contracts directory and installing dependencies..."
    cd ~/infernet-container-starter/projects/hello-world/contracts

    # Remove existing invalid directories
    rm -rf lib/forge-std
    rm -rf lib/infernet-sdk

    if ! command -v forge &> /dev/null
    then
        echo "forge command not found, attempting to install dependencies..."
        forge install --no-commit foundry-rs/forge-std
        forge install --no-commit ritual-net/infernet-sdk
    else
        echo "forge is already installed, installing dependencies..."
        forge install --no-commit foundry-rs/forge-std
        forge install --no-commit ritual-net/infernet-sdk
    fi
    echo "Dependencies installed!"

    # Start Docker Compose
    echo "Starting Docker Compose..."
    cd ~/infernet-container-starter
    docker compose -f deploy/docker-compose.yaml up -d
    echo "Docker Compose started successfully!"

    # Deploy contract
    echo "Deploying contract..."
    cd ~/infernet-container-starter
    project=hello-world make deploy-contracts
    echo "Contract deployed successfully!"

    echo "Ritual Node installation completed!"
}

# View Ritual Node logs
function view_logs() {
    echo "Viewing Ritual Node logs..."
    docker logs -f infernet-node
}

# Remove Ritual Node
function remove_ritual_node() {
    echo "Removing Ritual Node..."

    # Stop and remove Docker containers
    echo "Stopping and removing Docker containers..."
    docker-compose -f ~/infernet-container-starter/deploy/docker-compose.yaml down

    # Delete repository files
    echo "Deleting related files..."
    rm -rf ~/infernet-container-starter

    # Delete Docker images
    echo "Deleting Docker images..."
    docker rmi ritualnetwork/hello-world-infernet:latest

    echo "Ritual Node has been successfully removed!"
}

# Call main menu function
main_menu
