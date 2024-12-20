#!/bin/bash
# Update package list and install Docker
echo "Updating package list and installing Docker..."
sudo apt update
sudo apt install docker.io -y

# Add the current user to the docker group
echo "Adding the current user to the docker group..."
sudo usermod -aG docker $USER

# Pull and run Portainer container
echo "Pulling and running Portainer container..."
sudo docker pull portainer/portainer-ce:latest
sudo docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce:latest

# Create directory for WG-Easy configuration
echo "Creating directory for WG-Easy configuration..."
mkdir -p ~/wgeasy/wg-easy
cd ~/wgeasy

# Create .env file with password hash
echo "Creating .env file..."
cat <<EOL > .env
WG_PASSWORD_HASH=\$2b\$10\$WIqvUthA5OiMXK0yYhLR7.ymQCMwRkOrfXmNNK5T3CWwjJU7ZBCnq
EOL

# Create docker-compose.yml for WG-Easy
echo "Creating docker-compose.yml for WG-Easy..."
cat <<EOL > docker-compose.yml
version: '3.8'
services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy  
    container_name: wg-easy         
    environment:                    
      LANG: en                     
      WG_HOST: your_public_ip_here    # Replace with your actual server public IP
      PASSWORD_HASH: \${WG_PASSWORD_HASH}
      PORT: 51821                  
      WG_PORT: 443             
    volumes:
      - ./wg-easy/:/etc/wireguard   
    ports:
      - "443:443/udp"           
      - "51821:51821/tcp"          
    cap_add:                       
      - NET_ADMIN
      - SYS_MODULE
    sysctls:                        
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    restart: unless-stopped         
EOL

# Install Docker Compose
echo "Installing Docker Compose..."
sudo apt install docker-compose -y

# Start WG-Easy using Docker Compose
echo "Starting WG-Easy using Docker Compose..."
sudo docker-compose up -d

echo "Installation and setup complete!"
echo "Please replace 'your_public_ip_here' in the docker-compose.yml file with your actual public IP"
echo "Access WG-Easy at http://your-server-ip:51821"
echo "WireGuard VPN will run on port 443"
echo "Default password is: soethu69"
