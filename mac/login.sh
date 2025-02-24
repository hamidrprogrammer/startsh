#!/bin/bash

# Display separator
echo ".........................................................."

# Display public IP from ngrok tunnel
echo "IP:"
curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | sed 's/"public_url":"//'

# Display login credentials
echo "Username: runneradmin"
echo "Password: P@ssw0rd!"

# Enable Remote Management (ARD)
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on -restart -agent -privs -all

# Set VNC password
echo "P@ssw0rd!" | sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvncpw -vncpw

# Enable legacy VNC support
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes

# Allow access for all users with all privileges
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -allowAccessFor -allUsers -privs -all

# Reset screen capture permissions (for VNC screen sharing)
sudo tccutil reset ScreenCapture

# Restart Remote Management agent to apply changes
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -restart -agent

# Confirmation
echo "Remote management and VNC setup completed."
