#!/bin/bash

echo "================= QUICK GITHUB PROJECT SETUP ================="

# Step 0 - Collect user input
echo -e "\n🟡 ENTER THE NAME OF YOUR REPOSITORY (use '-' or '_' for spaces):"
read REPOSITORY_NAME 

echo -e "\n🟡 ENTER YOUR GITHUB USERNAME:"
read GITHUB_USERNAME

echo -e "\n🟡 ENTER THE FULL PATH OF YOUR GITHUB PAT TOKEN (file containing the token):"
read PAT_TOKEN_PATH

echo -e "\n🟡 PASTE YOUR README CONTENT (press Ctrl+D when done):"
CONTENT_FOR_README=$(</dev/stdin)

# Step 1 - Create local directory and navigate into it
echo -e "\n✅ CREATING LOCAL DIRECTORY: $REPOSITORY_NAME"
mkdir -p "$REPOSITORY_NAME"
cd "$REPOSITORY_NAME" || { echo "❌ Failed to enter directory"; exit 1; }

# Step 2 - Initialize Git repository
echo -e "\n✅ INITIALIZING GIT REPOSITORY"
git init
git checkout -b main

# Step 3 - Create README.md
echo -e "\n✅ CREATING README.md FILE"
echo "$CONTENT_FOR_README" > README.md
echo "📄 README.md created with provided content."

# Step 4 - Commit changes
echo -e "\n✅ STAGING AND COMMITTING FILES"
git add .
git commit -m "Initial commit: Added README.md"

# Step 5 - Create remote repo on GitHub using API
echo -e "\n✅ CREATING REMOTE REPOSITORY ON GITHUB"
RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
  -H "Authorization: token $(cat "$PAT_TOKEN_PATH")" \
  -d "{\"name\":\"$REPOSITORY_NAME\"}" \
  https://api.github.com/user/repos)

if [ "$RESPONSE" -eq 201 ]; then
    echo "🎉 GitHub repository created successfully."
else
    echo "❌ Failed to create GitHub repository. Response code: $RESPONSE"
    cat response.json
    exit 1
fi

# Step 6 - Set remote origin
echo -e "\n✅ SETTING REMOTE ORIGIN TO GITHUB"
git remote add origin git@github.com:$GITHUB_USERNAME/$REPOSITORY_NAME.git

# Step 7 - Push to remote repository
echo -e "\n✅ PUSHING CODE TO REMOTE (main branch)"
git push -u origin main

# Final Step
echo -e "\n🎉🎉 DONE! Your project '$REPOSITORY_NAME' is live on GitHub: https://github.com/$GITHUB_USERNAME/$REPOSITORY_NAME"
