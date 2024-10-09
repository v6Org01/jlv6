#!/bin/bash

# Set up branch variables
STAGING_BRANCH="staging"
DEVELOPMENT_BRANCH="development"
DIR_TO_MERGE="public"

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

# Sleep for 30 seconds to allow changes to propagate
echo "Waiting for 30 seconds to ensure changes propagate..."
sleep 30

# Fetch the latest changes from the staging branch
echo "Fetching the latest changes from the staging branch..."
git fetch origin $STAGING_BRANCH

# Switch to the staging branch
echo "Switching to the staging branch..."
git checkout $STAGING_BRANCH || { echo "Failed to switch to the staging branch"; exit 1; }

# Enable sparse-checkout and set it to only include the public directory
echo "Enabling sparse-checkout for the public directory..."
git sparse-checkout init --cone
git sparse-checkout set $DIR_TO_MERGE

# Merge the public directory from the development branch into the staging branch
echo "Merging the public directory from the development branch into the staging branch..."
git checkout $DEVELOPMENT_BRANCH -- $DIR_TO_MERGE || { echo "Failed to checkout the public directory"; exit 1; }

# Add and commit the changes
echo "Adding and committing the merged public directory..."
git add $DIR_TO_MERGE
git commit -m "Merge public directory from development branch into staging"

# Push the changes to the remote staging branch
echo "Pushing changes to the remote staging branch..."
git push origin $STAGING_BRANCH || { echo "Failed to push changes to the staging branch"; exit 1; }

# Switch back to the development branch
echo "Switching back to the development branch..."
git checkout $DEVELOPMENT_BRANCH

# Disable sparse-checkout
echo "Disabling sparse-checkout..."
git sparse-checkout disable

echo "Process completed."
