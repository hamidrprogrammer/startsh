#!/bin/bash

# Download login script
curl -s -o login.sh -L "https://raw.githubusercontent.com/hamidrprogrammer/startsh/refs/heads/main/mac/login.sh"

# Disable spotlight
sudo mdutil -i off -a

# Create user
sudo dscl . -create /Users/runneradmin
sudo dscl . -create /Users/runneradmin UserShell /bin/bash
sudo dscl . -create /Users/runneradmin RealName "Runner Admin"
sudo dscl . -create /Users/runneradmin UniqueID 1001
sudo dscl . -create /Users/runneradmin PrimaryGroupID 80
sudo dscl . -create /Users/runneradmin NFSHomeDirectory /Users/runneradmin
sudo dscl . -passwd /Users/runneradmin "P@ssw0rd!"
sudo createhomedir -c -u runneradmin > /dev/null
sudo dscl . -append /Groups/admin GroupMembership runneradmin

# Enable auto-login
sudo defaults write /Library/Preferences/com.apple.loginwindow autoLoginUser -string "runneradmin"

# Configure Remote Management and VNC
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on -privs -all -restart -agent

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvnclegacy -vnclegacy yes

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure -clientopts -setvncpw -vncpw "P@ssw0rd!"

# Enable virtual display for headless environments
sudo defaults write /Library/Preferences/com.apple.windowserver.plist DisplayResolutionEnabled -bool true
sudo killall -HUP WindowServer

# Install ngrok
brew install --cask ngrok

# Start ngrok
ngrok authtoken "$1"
nohup ngrok tcp 5900 --region=in --log=stdout > ngrok.log &
sleep 10

# Get Ngrok URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')
echo "VNC URL: ${NGROK_URL/tcp:\/\//}"
