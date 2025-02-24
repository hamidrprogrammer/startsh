#!/bin/bash

# Disable spotlight
echo "Disabling Spotlight..."
sudo mdutil -i off -a || { echo "Failed to disable Spotlight"; exit 1; }

# Create user
echo "Creating user runneradmin..."
sudo dscl . -create /Users/runneradmin
sudo dscl . -create /Users/runneradmin UserShell /bin/bash
sudo dscl . -create /Users/runneradmin RealName "Runner Admin"
sudo dscl . -create /Users/runneradmin UniqueID 1001
sudo dscl . -create /Users/runneradmin PrimaryGroupID 80
sudo dscl . -create /Users/runneradmin NFSHomeDirectory /Users/runneradmin
sudo dscl . -passwd /Users/runneradmin "P@ssw0rd!"
sudo createhomedir -c -u runneradmin > /dev/null
sudo dscl . -append /Groups/admin GroupMembership runneradmin || { echo "Failed to create user"; exit 1; }

# Enable auto-login (if needed)
echo "Setting up auto-login..."
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string "runneradmin" || { echo "Failed to set auto-login"; exit 1; }

# Configure Remote Management and VNC
echo "Enabling remote management..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -on -privs -all -restart -agent || { echo "Failed to activate remote management"; exit 1; }
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvnclegacy -vnclegacy yes || { echo "Failed to configure VNC"; exit 1; }
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setvncpw -vncpw "P@ssw0rd!" || { echo "Failed to set VNC password"; exit 1; }

# Enable virtual display for headless environments
echo "Enabling virtual display..."
sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true || { echo "Failed to enable virtual display"; exit 1; }
sudo killall -HUP WindowServer || { echo "Failed to restart WindowServer"; exit 1; }

# Install ngrok
echo "Installing ngrok..."
brew install --cask ngrok || { echo "Failed to install ngrok"; exit 1; }

# Start ngrok
echo "Starting ngrok..."
ngrok authtoken "$1" || { echo "Failed to authenticate ngrok"; exit 1; }
nohup ngrok tcp 5900 --region=in --log=stdout > ngrok.log & sleep 10 || { echo "Failed to start ngrok"; exit 1; }

# Get Ngrok URL
echo "Fetching ngrok URL..."
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url') || { echo "Failed to retrieve ngrok URL"; exit 1; }
echo "VNC URL: ${NGROK_URL/tcp:\/\//}"
