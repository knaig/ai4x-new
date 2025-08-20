@echo off
echo 🚀 GitHub Repository Setup for AI4Bharat KServe
echo ============================================================

REM Check if git is initialized
if not exist ".git" (
    echo ❌ Git repository not initialized. Please run 'git init' first.
    pause
    exit /b 1
)

echo ✅ Git repository is ready
echo 📝 Current commit: 
git log --oneline -1

echo.
echo 📋 Manual Steps Required:
echo 1. Go to https://github.com/new
echo 2. Repository name: AI4X-New
echo 3. Description: AI4Bharat KServe Setup with Web Dashboard
echo 4. Make it Public or Private ^(your choice^)
echo 5. DO NOT initialize with README, .gitignore, or license
echo 6. Click 'Create repository'
echo.

set /p continue="Have you created the repository? (y/N): "
if /i not "%continue%"=="y" (
    echo ❌ Please create the repository first and run this script again.
    pause
    exit /b 1
)

set /p username="Enter your GitHub username: "

REM Add remote origin
set remoteUrl=https://github.com/%username%/AI4X-New.git
echo 🔗 Adding remote origin: %remoteUrl%

git remote add origin %remoteUrl%
if %errorlevel% neq 0 (
    echo ⚠️  Remote origin might already exist
)

REM Check current remotes
echo.
echo 📡 Current remotes:
git remote -v

REM Push to GitHub
echo.
echo 🚀 Pushing code to GitHub...

git push -u origin master
if %errorlevel% equ 0 (
    echo ✅ Code pushed successfully!
    echo.
    echo 🎉 Setup Complete!
    echo 🌐 Your repository: https://github.com/%username%/AI4X-New
    echo.
    echo 📚 Next steps:
    echo 1. Add collaborators if needed
    echo 2. Set up branch protection rules
    echo 3. Configure GitHub Actions ^(optional^)
    echo 4. Share your repository!
) else (
    echo ❌ Push failed. Please check your GitHub credentials.
    echo 💡 You may need to authenticate with GitHub first.
    echo 💡 Consider using GitHub CLI or Personal Access Token.
)

pause
