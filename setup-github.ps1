#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup script for creating and pushing to GitHub repository "AI4X New"
.DESCRIPTION
    This script helps you create a new GitHub repository and push your AI4Bharat KServe setup code.
.NOTES
    You need to manually create the repository on GitHub first.
#>

param(
    [string]$GitHubUsername = "",
    [string]$RepositoryName = "AI4X-New"
)

Write-Host "🚀 GitHub Repository Setup for AI4Bharat KServe" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green

# Check if git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "❌ Git repository not initialized. Please run 'git init' first." -ForegroundColor Red
    exit 1
}

# Check if we have commits
$commitCount = (git rev-list --count HEAD 2>$null)
if ($commitCount -eq 0) {
    Write-Host "❌ No commits found. Please make an initial commit first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git repository is ready" -ForegroundColor Green
Write-Host "📝 Current commit: $(git log --oneline -1)" -ForegroundColor Cyan

# Get GitHub username if not provided
if (-not $GitHubUsername) {
    $GitHubUsername = Read-Host "Enter your GitHub username"
}

Write-Host ""
Write-Host "📋 Manual Steps Required:" -ForegroundColor Yellow
Write-Host "1. Go to https://github.com/new" -ForegroundColor White
Write-Host "2. Repository name: $RepositoryName" -ForegroundColor White
Write-Host "3. Description: AI4Bharat KServe Setup with Web Dashboard" -ForegroundColor White
Write-Host "4. Make it Public or Private (your choice)" -ForegroundColor White
Write-Host "5. DO NOT initialize with README, .gitignore, or license" -ForegroundColor White
Write-Host "6. Click 'Create repository'" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Have you created the repository? (y/N)"
if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "❌ Please create the repository first and run this script again." -ForegroundColor Red
    exit 1
}

# Add remote origin
$remoteUrl = "https://github.com/$GitHubUsername/$RepositoryName.git"
Write-Host "🔗 Adding remote origin: $remoteUrl" -ForegroundColor Cyan

try {
    git remote add origin $remoteUrl
    Write-Host "✅ Remote origin added successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Remote origin might already exist" -ForegroundColor Yellow
}

# Check current remotes
Write-Host ""
Write-Host "📡 Current remotes:" -ForegroundColor Cyan
git remote -v

# Push to GitHub
Write-Host ""
Write-Host "🚀 Pushing code to GitHub..." -ForegroundColor Green

try {
    git push -u origin master
    Write-Host "✅ Code pushed successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Push failed. Please check your GitHub credentials." -ForegroundColor Red
    Write-Host "💡 You may need to authenticate with GitHub first." -ForegroundColor Yellow
    Write-Host "💡 Consider using GitHub CLI or Personal Access Token." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "🌐 Your repository: https://github.com/$GitHubUsername/$RepositoryName" -ForegroundColor Cyan
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Yellow
Write-Host "1. Add collaborators if needed" -ForegroundColor White
Write-Host "2. Set up branch protection rules" -ForegroundColor White
Write-Host "3. Configure GitHub Actions (optional)" -ForegroundColor White
Write-Host "4. Share your repository!" -ForegroundColor White
