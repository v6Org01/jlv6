#!/bin/bash

# Set up branch variables
PRODUCTION_BRANCH="main"
DEVELOPMENT_BRANCH="development"
DIR_TO_MERGE="public"

# Prompt for commit message
echo "help: --create-tag|--ct major.minor.patch, --skip-build-push-image|--sbpi, --skip-deploy-aws|--sda, --skip-deploy-k8s|--sdk"
read -p "Enter commit message: " commit_msg

# Kill the npm process for "npm run dev"
echo "Killing any running npm process (npm run dev)..."
pkill -f "npm run dev" || echo "No npm run dev process found."

# Clean the public directory and rebuild the project
echo "Cleaning the public directory and rebuilding the project..."
hugo --cleanDestinationDir
npm run build || { echo "Build failed. Exiting."; exit 1; }

# Ensure we are in the development branch
current_branch=$(git branch --show-current)

if [ "$current_branch" != "$DEVELOPMENT_BRANCH" ]; then
    echo "Switching to the development branch..."
    git checkout $DEVELOPMENT_BRANCH || { echo "Failed to switch to the development branch"; exit 1; }
fi

# Commit and push any changes to the development branch
echo "Committing and pushing changes to the development branch..."
git add .
git commit -m "Clean build and rebuild of Hugoplate project"
git push origin $DEVELOPMENT_BRANCH || { echo "Failed to push changes to the development branch."; exit 1; }

# Check for uncommitted changes in the development branch
# if [[ -n $(git status --porcelain) ]]; then
#     echo "Error: You have uncommitted changes. Please commit or stash them before running this script."
#     exit 1
# fi

# Sleep for 5 seconds to allow changes to propagate
echo "Waiting for 5 seconds to ensure changes propagate..."
sleep 5

# Fetch the latest changes from the production branch
echo "Pulling the latest changes from the production branch..."
git pull origin $PRODUCTION_BRANCH

# Switch to the production branch
echo "Switching to the production branch..."
git checkout $PRODUCTION_BRANCH || { echo "Failed to switch to the production branch"; exit 1; }

# Enable sparse-checkout and set it to only include the public directory
echo "Enabling sparse-checkout for the public directory..."
git sparse-checkout init --cone
git sparse-checkout set $DIR_TO_MERGE

# Merge the public directory from the development branch into the production branch
echo "Merging the public directory from the development branch into the production branch..."
git checkout $DEVELOPMENT_BRANCH -- $DIR_TO_MERGE || { echo "Failed to checkout the public directory"; exit 1; }

# Add and commit the changes
echo "Adding and committing the merged public directory..."
git add $DIR_TO_MERGE
git commit -m "$commit_msg"

# Push the changes to the remote production branch
echo "Pushing changes to the remote production branch..."
git push origin $PRODUCTION_BRANCH || { echo "Failed to push changes to the production branch"; exit 1; }

# Switch back to the development branch
echo "Switching back to the development branch..."
git checkout $DEVELOPMENT_BRANCH

# Disable sparse-checkout
echo "Disabling sparse-checkout..."
git sparse-checkout disable

echo "Process completed."
