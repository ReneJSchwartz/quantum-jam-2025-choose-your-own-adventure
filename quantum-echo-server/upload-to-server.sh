#!/bin/bash
# upload-to-server.sh - Upload files to your server

SERVER="108.175.12.95"
USER="your-username"  # Replace with your actual SSH username
REMOTE_PATH="/var/www/vhosts/davidjgrimsley.com/happy-noyce.108-175-12-95.plesk.page/"

echo "Uploading Quantum Echo Server files to $SERVER..."

# Upload the zip file
echo "Uploading quantum-echo-server.zip..."
scp quantum-echo-server.zip $USER@$SERVER:$REMOTE_PATH

# Upload individual files as backup
echo "Uploading individual files..."
scp deploy/app.py $USER@$SERVER:$REMOTE_PATH
scp deploy/app-minimal.py $USER@$SERVER:$REMOTE_PATH
scp deploy/startup.py $USER@$SERVER:$REMOTE_PATH
scp deploy/requirements-plesk.txt $USER@$SERVER:$REMOTE_PATH
scp deploy/requirements-minimal.txt $USER@$SERVER:$REMOTE_PATH
scp README.md $USER@$SERVER:$REMOTE_PATH

echo "Upload complete! Now SSH into your server and follow the deployment guide."
echo ""
echo "Next steps:"
echo "1. ssh $USER@$SERVER"
echo "2. cd $REMOTE_PATH"
echo "3. Follow the SSH-DEPLOYMENT.md guide"
