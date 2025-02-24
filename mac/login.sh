#!/bin/bash

echo ".........................................................."
echo "VNC Connection Details:"
echo "------------------------------------------------------------"
echo "VNC IP Address (Ngrok URL):"
curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*' | sed 's/"public_url":"//'
echo "------------------------------------------------------------"
echo "VNC Username: runneradmin"
echo "VNC Password: P@ssw0rd!"
echo ".........................................................."
