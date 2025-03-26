#!/bin/bash

# Script save path
SCRIPT_PATH="$HOME/Hyperspace.sh"


# Check and install screen
function check_and_install_screen() {
    if ! command -v screen &> /dev/null; then
        echo "screen is not installed, installing..."
        # Run installation command without sudo
        apt update && apt install -y screen
    else
        echo "screen is already installed."
    fi
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
            echo "1. Deploy Hyperspace Node"
            echo "2. View Logs"
            echo "3. View Points"
            echo "4. Delete Node (Stop Node)"
            echo "5. Enable Log Monitoring"
            echo "6. View Private Key"
            echo "7. View aios daemon Status"
            echo "8. Enable Points Monitoring"
            echo "9. Exit Script"
            echo "================================================================"
            read -p "Please choose (1/2/3/4/5/6/7/8/9): " choice
        case $choice in
            1)  deploy_hyperspace_node ;;
            2)  view_logs ;; 
            3)  view_points ;;
            4)  delete_node ;;
            5)  start_log_monitor ;;
            6)  view_private_key ;;
            7)  view_status ;;
            8)  start_points_monitor ;;
            9)  exit_script ;;
            *)  echo "Invalid choice, please try again!"; sleep 2 ;;
        esac
    done
}

# Deploy Hyperspace Node
function deploy_hyperspace_node() {
    # Run the installation command
    echo "Running installation command: curl https://download.hyper.space/api/install | bash"
    curl https://download.hyper.space/api/install | bash

    # Get the new path added after installation
    NEW_PATH=$(bash -c 'source /root/.bashrc && echo $PATH')
    
    # Update the current shell's PATH
    export PATH="$NEW_PATH"

    # Ensure ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Ensure /root/.aios is in PATH
    if [[ ":$PATH:" != *":/root/.aios:"* ]]; then
        export PATH="/root/.aios:$PATH"
    fi

    # Print the current PATH to ensure aios-cli is included
    echo "Current PATH: $PATH"

    # Verify if aios-cli is available
    if ! command -v /root/.aios/aios-cli &> /dev/null; then
        echo "aios-cli command not found, retrying..."
        sleep 3
        # Retry updating PATH
        export PATH="$PATH:/root/.local/bin"
        if ! command -v /root/.aios/aios-cli &> /dev/null; then
            echo "aios-cli command not found, please manually run 'source /root/.bashrc' and try again"
            read -n 1 -s -r -p "Press any key to return to the main menu..."
            return
        fi
    fi

    # Prompt for screen name, default is 'hyper'
    read -p "Enter screen name (default: hyper): " screen_name
    screen_name=${screen_name:-hyper}
    echo "Using screen name: $screen_name"

    # Clean up any existing 'hyper' screen session
    echo "Checking and cleaning existing 'hyper' screen session..."
    screen -ls | grep "$screen_name" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "Found existing '$screen_name' screen session, stopping and deleting..."
        screen -S "$screen_name" -X quit
        sleep 2
    else
        echo "No existing '$screen_name' screen session found."
    fi

    # Create a new screen session
    echo "Creating a new screen session named '$screen_name'..."
    screen -S "$screen_name" -dm

    # Run aios-cli start in the screen session
    echo "Running 'aios-cli start' in the '$screen_name' screen session..."
    screen -S "$screen_name" -X stuff "/root/.aios/aios-cli start\n"

    # Wait a few seconds to ensure the command runs
    sleep 5

    # Detach from the screen session
    echo "Detaching from screen session '$screen_name'..."
    screen -S "$screen_name" -X detach
    sleep 5

    # Print current PATH again to ensure aios-cli is in it
    echo "Current PATH: $PATH"

    # Prompt for private key input and save it as my.pem
    echo "Please enter your private key (press CTRL+D to finish):"
    cat > my.pem

    # Run import-keys command with my.pem file
    echo "Running import-keys command using my.pem file..."
    
    # Execute import-keys command
    /root/.aios/aios-cli hive import-keys ./my.pem
    sleep 5

    # Define model variable
    model="hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf"

    # Add model and retry
    echo "Adding model through '/root/.aios/aios-cli models add'..."
    while true; do
        if /root/.aios/aios-cli models add "$model"; then
            echo "Model added successfully and downloaded!"
            break
        else
            echo "Error adding model, retrying..."
            sleep 3
        fi
    done

    # Login and choose tier
    echo "Logging in and selecting tier..."

    # Log in to Hive
    /root/.aios/aios-cli hive login

    # Prompt user to choose tier
    echo "Select tier (1-5):"
    select tier in 1 2 3 4 5; do
        case $tier in
            1|2|3|4|5)
                echo "You selected tier $tier"
                /root/.aios/aios-cli hive select-tier $tier
                break
                ;;
            *)
                echo "Invalid choice, please select a number between 1 and 5."
                ;;
        esac
    done

    # Connect to Hive
    /root/.aios/aios-cli hive connect
    sleep 5

    # Stop the aios-cli process
    echo "Stopping 'aios-cli start' process using '/root/.aios/aios-cli kill'..."
    /root/.aios/aios-cli kill

    # Run aios-cli start in screen session with log redirection
    echo "Running '/root/.aios/aios-cli start --connect' in screen session '$screen_name', output redirected to '/root/aios-cli.log'..."
    screen -S "$screen_name" -X stuff "/root/.aios/aios-cli start --connect >> /root/aios-cli.log 2>&1\n"

    echo "Hyperspace node deployment complete, '/root/.aios/aios-cli start --connect' is running in the screen session in the background."

    # Prompt user to return to main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# View points
function view_points() {
    echo "Viewing points..."
    source /root/.bashrc
    aios-cli hive points
    sleep 5
}

# Delete node (stop node)
function delete_node() {
    echo "Stopping node with 'aios-cli kill'..."

    # Execute aios-cli kill to stop node
    aios-cli kill
    sleep 2
    
    echo "'aios-cli kill' completed, node stopped."

    # Prompt user to return to main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# Enable log monitoring
function start_log_monitor() {
    echo "Starting log monitoring..."

    # Create monitoring script
    cat > /root/monitor.sh << 'EOL'
#!/bin/bash
LOG_FILE="/root/aios-cli.log"
SCREEN_NAME="hyper"
LAST_RESTART=$(date +%s)
MIN_RESTART_INTERVAL=300

while true; do
    current_time=$(date +%s)
    
    # Detect issues and trigger restart
    if (tail -n 4 "$LOG_FILE" | grep -q "Last pong received.*Sending reconnect signal" || \
        tail -n 4 "$LOG_FILE" | grep -q "Failed to authenticate" || \
        tail -n 4 "$LOG_FILE" | grep -q "Failed to connect to Hive" || \
        tail -n 4 "$LOG_FILE" | grep -q "Another instance is already running" || \
        tail -n 4 "$LOG_FILE" | grep -q "\"message\": \"Internal server error\"" || \
        tail -n 4 "$LOG_FILE" | grep -q "thread 'main' panicked at aios-cli/src/main.rs:181:39: called \`Option::unwrap()\` on a \`None\` value") && \
       [ $((current_time - LAST_RESTART)) -gt $MIN_RESTART_INTERVAL ]; then
        echo "$(date): Detected connection issue, authentication failure, Hive connection failure, another instance running, internal server error, or 'Option::unwrap()' error, restarting service..." >> /root/monitor.log
        
        # Send Ctrl+C first
        screen -S "$SCREEN_NAME" -X stuff $'\003'
        sleep 5
        
        # Execute aios-cli kill
        screen -S "$SCREEN_NAME" -X stuff "aios-cli kill\n"
        sleep 5
        
        echo "$(date): Cleaning old logs..." > "$LOG_FILE"
        
        # Restart the service
        screen -S "$SCREEN_NAME" -X stuff "aios-cli start --connect >> /root/aios-cli.log 2>&1\n"
        
        LAST_RESTART=$current_time
        echo "$(date): Service restarted" >> /root/monitor.log
    fi
    sleep 30
done
EOL

    # Add execute permissions
    chmod +x /root/monitor.sh

    # Start monitoring script in background
    nohup /root/monitor.sh > /root/monitor.log 2>&1 &

    echo "Log monitoring started and running in the background."
    echo "You can check the monitoring status by viewing /root/monitor.log"
    sleep 2

    # Prompt user to return to main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# Enable points monitoring
function start_points_monitor() {
    echo "Starting points monitoring..."

    # Create points monitoring script
    cat > /root/points_monitor.sh << 'EOL'
#!/bin/bash
LOG_FILE="/root/aios-cli.log"
SCREEN_NAME="hyper"
LAST_POINTS=0
MIN_RESTART_INTERVAL=300

while true; do
    CURRENT_POINTS=$(aios-cli hive points | grep -o '[0-9]\+')
    
    if [ "$CURRENT_POINTS" -eq "$LAST_POINTS" ]; then
        echo "$(date): Points not increasing, restarting service..." >> /root/points_monitor.log
        
        # Restart the service
        screen -S "$SCREEN_NAME" -X stuff $'\003'
        sleep 5
        screen -S "$SCREEN_NAME" -X stuff "aios-cli kill\n"
        sleep 5
        
        echo "$(date): Cleaning old logs..." > "$LOG_FILE"
        screen -S "$SCREEN_NAME" -X stuff "aios-cli start --connect >> /root/aios-cli.log 2>&1\n"
        
        LAST_POINTS=$CURRENT_POINTS
    else
        LAST_POINTS=$CURRENT_POINTS
    fi

    sleep 7200  # Check points every 2 hours
done
EOL

    # Add execute permissions
    chmod +x /root/points_monitor.sh

    # Start points monitoring script in background
    nohup /root/points_monitor.sh > /root/points_monitor.log 2>&1 &

    echo "Points monitoring started and running in the background."
    echo "You can check the monitoring status by viewing /root/points_monitor.log"
    sleep 2

    # Prompt user to return to main menu
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}


# Call main menu function
main_menu
