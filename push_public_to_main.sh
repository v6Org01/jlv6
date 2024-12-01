#!/bin/bash

# Set up branch variables
PRODUCTION_BRANCH="main"
DEVELOPMENT_BRANCH="development"
DIR_TO_MERGE="public"

# Prompt for commit message
echo "help: --skip-build|-sb, --skip-deploy-aws|-sa, --skip-deploy-k8s|--sk"
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

# Sleep for 5 seconds to allow changes to propagate
echo "Waiting for 5 seconds to ensure changes propagate..."
sleep 5

# Switch to the production branch (main)
echo "Switching to the production branch..."
git checkout $PRODUCTION_BRANCH || { echo "Failed to switch to the production branch"; exit 1; }

# Pull the latest changes from the remote production branch (main)
echo "Pulling the latest changes from the remote production branch..."
git pull origin $PRODUCTION_BRANCH --rebase || { echo "Failed to rebase the production branch with remote changes. Exiting."; exit 1; }

# Enable sparse-checkout and set it to only include the public directory
echo "Enabling sparse-checkout for the public directory..."
git sparse-checkout init --cone
git sparse-checkout set $DIR_TO_MERGE

# Merge the public directory from the development branch into the production branch
echo "Merging the public directory from the development branch into the production branch..."
git checkout $DEVELOPMENT_BRANCH -- $DIR_TO_MERGE || { echo "Failed to checkout the public directory from development"; exit 1; }

# Replace the baseURL placeholder in the public directory only in the main branch
echo "Replacing baseURL in the public directory with {{BASE_URL}}..."
# Find files with "http://localhost:1313" and replace with "{{BASE_URL}}"
find $DIR_TO_MERGE -type f -exec grep -l "http://localhost:1313" {} \; | while read -r file; do
  echo "Replacing baseURL in file: $file"
  sed -i '' 's|http://localhost:1313|{{BASE_URL}}|g' "$file"
done

# Add and commit the changes to main (production)
echo "Adding and committing the merged public directory to the main branch..."
git add $DIR_TO_MERGE
git commit -m "$commit_msg"

# Push the changes to the remote production branch (main)
echo "Pushing changes to the remote production branch..."
git push origin $PRODUCTION_BRANCH || { echo "Failed to push changes to the production branch"; exit 1; }

# Switch back to the development branch
echo "Switching back to the development branch..."
git checkout $DEVELOPMENT_BRANCH

# Disable sparse-checkout
echo "Disabling sparse-checkout..."
git sparse-checkout disable

echo "Process completed."