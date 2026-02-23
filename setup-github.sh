#!/bin/bash
# Setup script for GitHub Pages deployment
# Run this after creating the GitHub repo

echo "🚀 Setting up Beast Capital for GitHub Pages..."

# Check if GitHub remote exists
if ! git remote | grep -q "github"; then
    echo "Adding GitHub remote..."
    git remote add github https://github.com/Oswfrans/beastcapital.git
fi

echo "Pushing code to GitHub..."
git push -u github main

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Code pushed successfully!"
    echo ""
    echo "Next steps to enable GitHub Pages:"
    echo "1. Go to: https://github.com/Oswfrans/beastcapital/settings/pages"
    echo "2. Under 'Build and deployment' → Source, select 'GitHub Actions'"
    echo "3. The workflow will run automatically and deploy your site"
    echo ""
    echo "Your site will be live at: https://oswfrans.github.io/beastcapital/"
else
    echo "❌ Push failed. Make sure you:"
    echo "   - Created the repo at https://github.com/new"
    echo "   - Have push access to the repo"
    exit 1
fi
