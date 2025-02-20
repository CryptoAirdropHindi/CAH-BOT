#!/bin/bash 

# Update package list 
echo "Update package list..." 
sudo apt update -y && sudo apt upgrade -y 

# Install required packages 
echo "Install required packages..." 
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common 

# Add Docker GPG key 
echo "Add Docker GPG key..." 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 

# Add Docker official repository 
echo "Add Docker repository..." 
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 

# Update package list after adding repository 
echo "Updating package list..." 
sudo apt update -y 

# Install Docker 
echo "Install Docker..." 
sudo apt install -y docker-ce docker-ce-cli containerd.io 

# Check Docker version 
echo "Docker installed successfully!" 
docker --version 

# Start and enable Docker on system boot 
echo "Enable Docker on boot..." 
sudo systemctl start docker 
sudo systemctl enable docker 

# Add permissions for current user to run Docker without sudo 
echo "Add permissions for current user..." 
sudo usermod -aG docker $USER 
echo "Please log out and log back in for changes to take effect." 

echo "Docker installation complete!"
