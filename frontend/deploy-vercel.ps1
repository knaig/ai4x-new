#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Deploy AI4Bharat Dashboard to Vercel
.DESCRIPTION
    This script helps you deploy your AI4Bharat dashboard to Vercel
.NOTES
    You need to have Vercel CLI installed and be logged in
#>

Write-Host "🚀 Vercel Deployment for AI4Bharat Dashboard" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green

# Check if Vercel CLI is installed
try {
    $vercelVersion = vercel --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Vercel CLI found: $vercelVersion" -ForegroundColor Green
    } else {
        throw "Vercel CLI not found"
    }
} catch {
    Write-Host "❌ Vercel CLI not found. Installing..." -ForegroundColor Red
    Write-Host "💡 Please install Vercel CLI first:" -ForegroundColor Yellow
    Write-Host "   npm install -g vercel" -ForegroundColor White
    Write-Host "   or" -ForegroundColor White
    Write-Host "   winget install Vercel.Vercel" -ForegroundColor White
    exit 1
}

# Check if user is logged in to Vercel
try {
    $vercelWhoami = vercel whoami 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Logged in as: $vercelWhoami" -ForegroundColor Green
    } else {
        Write-Host "❌ Not logged in to Vercel. Please login first:" -ForegroundColor Red
        Write-Host "   vercel login" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Error checking Vercel login status" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 Deployment Steps:" -ForegroundColor Yellow
Write-Host "1. Project will be deployed to Vercel" -ForegroundColor White
Write-Host "2. You'll get a public URL for your dashboard" -ForegroundColor White
Write-Host "3. Dashboard will be accessible from anywhere" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Ready to deploy? (y/N)"
if ($continue -ne "y" -and $continue -ne "Y") {
    Write-Host "❌ Deployment cancelled" -ForegroundColor Red
    exit 1
}

# Deploy to Vercel
Write-Host ""
Write-Host "🚀 Deploying to Vercel..." -ForegroundColor Green
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

try {
    vercel --prod
    Write-Host ""
    Write-Host "🎉 Deployment successful!" -ForegroundColor Green
    Write-Host "🌐 Your dashboard is now live on Vercel!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📚 Next steps:" -ForegroundColor Yellow
    Write-Host "1. Share the Vercel URL with others" -ForegroundColor White
    Write-Host "2. Set up custom domain if desired" -ForegroundColor White
    Write-Host "3. Configure environment variables" -ForegroundColor White
    Write-Host "4. Monitor deployment analytics" -ForegroundColor White
} catch {
    Write-Host "❌ Deployment failed. Please check the error messages above." -ForegroundColor Red
    Write-Host "💡 Common issues:" -ForegroundColor Yellow
    Write-Host "   - Network connectivity" -ForegroundColor White
    Write-Host "   - Vercel account limits" -ForegroundColor White
    Write-Host "   - Build errors" -ForegroundColor White
}
