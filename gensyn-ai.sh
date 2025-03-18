#!/bin/bash

# Script file path
SCRIPT_PATH="$HOME/gensyn-ai.sh"

# Function to install gensyn-ai node
function install_gensyn_ai_node() {
    # Update system
    sudo apt-get update && sudo apt-get upgrade -y

    # Install necessary packages
    sudo apt install -y curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev python3 python3-pip

    # Check if Docker is installed
    if ! command -v docker &> /dev/null
    then
        echo "Docker is not installed, installing Docker..."
        # Install Docker
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        sudo apt-get update
        sudo apt-get install -y docker-ce
        echo "Docker installation complete"
    else
        echo "Docker is already installed"
    fi

    # Clone GitHub repository and switch to that directory
    git clone https://github.com/gensyn-ai/rl-swarm/
    cd rl-swarm

    # Backup existing docker-compose.yaml file
    mv docker-compose.yaml docker-compose.yaml.old

    # Prompt user if their system has a GPU
    read -p "Does your system have a GPU? (y/n): " has_gpu

    # Create new docker-compose.yaml file based on user input
    if [ "$has_gpu" == "y" ]; then
        cat <<EOL > docker-compose.yaml
version: '3'

services:
  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.120.0
    ports:
      - "4317:4317"  # OTLP gRPC
      - "4318:4318"  # OTLP HTTP
      - "55679:55679"  # Prometheus metrics (optional)
    environment:
      - OTEL_LOG_LEVEL=DEBUG

  swarm_node:
    image: europe-docker.pkg.dev/gensyn-public-b7d9/public/rl-swarm:v0.0.2
    command: ./run_hivemind_docker.sh
    runtime: nvidia  # Enables GPU support; remove if no GPU is available
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - PEER_MULTI_ADDRS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
      - HOST_MULTI_ADDRS=/ip4/0.0.0.0/tcp/38331
    ports:
      - "38331:38331"  # Exposes the swarm node's P2P port
    depends_on:
      - otel-collector

  fastapi:
    build:
      context: .
      dockerfile: Dockerfile.webserver
    environment:
      - OTEL_SERVICE_NAME=rlswarm-fastapi
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - INITIAL_PEERS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
    ports:
      - "8080:8000"  # Maps port 8080 on the host to 8000 in the container
    depends_on:
      - otel-collector
      - swarm_node
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/healthz"]
      interval: 30s
      retries: 3
EOL
    else
        cat <<EOL > docker-compose.yaml
version: '3'

services:
  otel-collector:
    image: otel/opentelemetry-collector-contrib:0.120.0
    ports:
      - "4317:4317"  # OTLP gRPC
      - "4318:4318"  # OTLP HTTP
      - "55679:55679"  # Prometheus metrics (optional)
    environment:
      - OTEL_LOG_LEVEL=DEBUG

  swarm_node:
    image: europe-docker.pkg.dev/gensyn-public-b7d9/public/rl-swarm:v0.0.2
    command: ./run_hivemind_docker.sh
    environment:
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - PEER_MULTI_ADDRS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
      - HOST_MULTI_ADDRS=/ip4/0.0.0.0/tcp/38331
    ports:
      - "38331:38331"  # Exposes the swarm node's P2P port
    depends_on:
      - otel-collector

  fastapi:
    build:
      context: .
      dockerfile: Dockerfile.webserver
    environment:
      - OTEL_SERVICE_NAME=rlswarm-fastapi
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317
      - INITIAL_PEERS=/ip4/38.101.215.13/tcp/30002/p2p/QmQ2gEXoPJg6iMBSUFWGzAabS2VhnzuS782Y637hGjfsRJ
    ports:
      - "8080:8000"  # Maps port 8080 on the host to 8000 in the container
    depends_on:
      - otel-collector
      - swarm_node
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/healthz"]
      interval: 30s
      retries: 3
EOL
    fi

    # Run docker compose up --build -d and display logs
    docker compose up --build -d && docker compose logs -f
}

# Function to view Rl Swarm logs
function view_rl_swarm_logs() {
    cd /root/rl-swarm && docker-compose logs -f swarm_node

    # Prompt user to press any key to return to the main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# Function to view Web UI logs
function view_web_ui_logs() {
    cd /root/rl-swarm && docker-compose logs -f fastapi

    # Prompt user to press any key to return to the main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# Function to view Telemetry logs
function view_telemetry_logs() {
    cd /root/rl-swarm && docker-compose logs -f otel-collector

    # Prompt user to press any key to return to the main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

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
        echo "================================================================"
        echo "To exit the script, press Ctrl + C."
        echo "Please choose an action:"
        echo "1. Install gensyn-ai node"
        echo "2. View Rl Swarm logs"
        echo "3. View Web UI logs"
        echo "4. View Telemetry logs"
        echo "5. Exit"
        read -p "Enter option [1-5]: " choice
        case $choice in
            1)
                install_gensyn_ai_node
                ;;
            2)
                view_rl_swarm_logs
                ;;
            3)
                view_web_ui_logs
                ;;
            4)
                view_telemetry_logs
                ;;
            5)
                exit 0
                ;;
            *)
                echo "Invalid option, please try again..."
                sleep 2
                ;;
        esac
    done
}

# Run the main menu
main_menu
