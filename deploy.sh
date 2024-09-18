#!/bin/bash

# Variables
EC2_USER="ec2-user"                       # EC2 user (usually 'ec2-user' or 'ubuntu')
EC2_HOST= 16.16.56.12                      # Public IP of your EC2 instance
SSH_KEY_PATH="/home/palak/Downloads/palak.pem"  # Path to your SSH private key file
REMOTE_APP_DIR="/var/www/NetflixMovieCatalog"       # The directory on EC2 where the app will be deployed

# Commands
echo "Starting deployment to EC2 instance..."

# 1. SSH into the EC2 instance and create/update the directory
ssh -i "$SSH_KEY_PATH" "$EC2_USER@$EC2_HOST" << EOF
  echo "Connecting to EC2..."
  
  # Make sure the app directory exists
  if [ ! -d "$REMOTE_APP_DIR" ]; then
    echo "Creating directory $REMOTE_APP_DIR..."
    sudo mkdir -p "$REMOTE_APP_DIR"
    sudo chown -R $EC2_USER:$EC2_USER "$REMOTE_APP_DIR"
  fi

  # Optionally, you can stop the current running service before deploying the new code
  # For example, if you're using Nginx/PM2:
  # sudo systemctl stop nginx
  # pm2 stop all
  
  exit
EOF

# 2. Use SCP to copy the updated application files to the EC2 instance
echo "Copying application files to EC2..."
scp -i "$SSH_KEY_PATH" -r ./your-app/ "$EC2_USER@$EC2_HOST:$REMOTE_APP_DIR"

# 3. SSH back into the EC2 instance to restart services or run post-deployment commands
ssh -i "$SSH_KEY_PATH" "$EC2_USER@$EC2_HOST" << EOF
  echo "Connected to EC2 for post-deployment tasks..."

  # Navigate to the app directory
  cd "$REMOTE_APP_DIR"

  # Install dependencies if needed (e.g., if using Node.js, Python, etc.)
  # npm install  # For Node.js apps
  # pip install -r requirements.txt  # For Python apps

  # Restart your app or services
  # Example for Node.js with PM2:
  # pm2 restart all
  
  # Example for Nginx:
  # sudo systemctl restart nginx
  
  echo "Deployment complete!"
  
  exit
EOF

# Done
echo "Deployment finished successfully!"
