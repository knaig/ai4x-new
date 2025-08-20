# 🚀 Deploy AI4Bharat Dashboard to Vercel

This guide will help you deploy your AI4Bharat Translation & Monitoring Dashboard to Vercel for public access.

## 🌟 Why Deploy to Vercel?

- **Global CDN**: Fast access from anywhere in the world
- **Automatic HTTPS**: Secure connections by default
- **Easy Deployment**: Simple CLI-based deployment
- **Free Tier**: Generous free hosting for personal projects
- **Custom Domains**: Option to use your own domain
- **Analytics**: Built-in performance monitoring

## 📋 Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Vercel CLI**: Install the command-line tool
3. **Git Repository**: Your code should be on GitHub (✅ Already done!)

## 🛠️ Installation Options

### Option 1: Install via npm (Recommended)
```bash
npm install -g vercel
```

### Option 2: Install via winget (Windows)
```cmd
winget install Vercel.Vercel
```

### Option 3: Install via Homebrew (macOS)
```bash
brew install vercel
```

## 🔐 Authentication

1. **Login to Vercel**:
   ```bash
   vercel login
   ```

2. **Follow the browser prompt** to authenticate with your Vercel account

3. **Verify login**:
   ```bash
   vercel whoami
   ```

## 🚀 Quick Deployment

### Step 1: Navigate to Frontend Directory
```bash
cd frontend
```

### Step 2: Run Deployment Script
```powershell
# Windows PowerShell
.\deploy-vercel.ps1

# Or run manually
vercel --prod
```

### Step 3: Follow the Prompts
- **Project Name**: `ai4bharat-dashboard` (or your preferred name)
- **Directory**: `./` (current directory)
- **Override**: `y` (to use our custom configuration)

## ⚙️ Configuration Files

### vercel.json
```json
{
  "version": 2,
  "builds": [
    {
      "src": "server.py",
      "use": "@vercel/python"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "server.py"
    }
  ],
  "env": {
    "AI4BHARAT_ENDPOINT": "https://your-kserve-endpoint.vercel.app",
    "DEBUG": "false"
  }
}
```

### requirements-vercel.txt
```
Flask==2.3.3
Flask-CORS==4.0.0
requests==2.31.0
Werkzeug==2.3.7
gunicorn==21.2.0
```

## 🌐 Deployment Process

1. **Build**: Vercel builds your Python Flask app
2. **Deploy**: Deploys to global edge network
3. **URL Generation**: Provides public access URL
4. **SSL Certificate**: Automatic HTTPS setup

## 🔧 Environment Variables

### Set in Vercel Dashboard
1. Go to your project dashboard
2. Navigate to Settings → Environment Variables
3. Add the following:

| Variable | Value | Description |
|----------|-------|-------------|
| `AI4BHARAT_ENDPOINT` | `https://your-kserve-endpoint.com` | Your KServe model endpoint |
| `DEBUG` | `false` | Production mode |

### Set via CLI
```bash
vercel env add AI4BHARAT_ENDPOINT
vercel env add DEBUG
```

## 📊 Post-Deployment

### 1. **Get Your URL**
After deployment, you'll receive:
- **Production URL**: `https://your-project.vercel.app`
- **Preview URLs**: For each git commit

### 2. **Test Your Dashboard**
- Open the production URL
- Test all features
- Verify API endpoints work

### 3. **Monitor Performance**
- Check Vercel Analytics
- Monitor response times
- Track usage statistics

## 🔄 Continuous Deployment

### Automatic Deployments
- **GitHub Integration**: Every push to main branch triggers deployment
- **Preview Deployments**: Pull requests get preview URLs
- **Rollback**: Easy rollback to previous versions

### Manual Deployments
```bash
# Deploy latest changes
vercel --prod

# Deploy specific branch
vercel --prod --target=staging
```

## 🌍 Custom Domain Setup

### 1. **Add Domain in Vercel**
- Go to Project Settings → Domains
- Add your custom domain
- Follow DNS configuration instructions

### 2. **DNS Configuration**
```
Type: CNAME
Name: @
Value: cname.vercel-dns.com
```

### 3. **SSL Certificate**
- Automatic SSL setup
- Renewal handled by Vercel

## 📈 Analytics & Monitoring

### Vercel Analytics
- **Performance Metrics**: Core Web Vitals
- **User Analytics**: Geographic distribution
- **Error Tracking**: Automatic error monitoring

### Custom Monitoring
- **API Health Checks**: Monitor your KServe endpoints
- **Response Time Tracking**: Built into your dashboard
- **Error Logging**: Comprehensive error reporting

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**
   - Check Python version compatibility
   - Verify all dependencies in requirements.txt
   - Check for syntax errors

2. **Runtime Errors**
   - Check environment variables
   - Verify API endpoints
   - Check Vercel function logs

3. **Performance Issues**
   - Enable Vercel Analytics
   - Check function execution time
   - Optimize Python code

### Debug Commands
```bash
# Check deployment status
vercel ls

# View function logs
vercel logs

# Check environment
vercel env ls
```

## 🔒 Security Considerations

### Production Best Practices
- **Environment Variables**: Never commit secrets
- **CORS Configuration**: Restrict to trusted domains
- **Rate Limiting**: Implement API rate limiting
- **Input Validation**: Validate all user inputs

### Vercel Security Features
- **Automatic HTTPS**: SSL certificates
- **DDoS Protection**: Built-in protection
- **Edge Security**: Global security policies

## 📚 Advanced Configuration

### Function Configuration
```json
{
  "functions": {
    "server.py": {
      "maxDuration": 30,
      "memory": 1024
    }
  }
}
```

### Headers & Redirects
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        }
      ]
    }
  ]
}
```

## 🎉 Success Checklist

- ✅ **Vercel CLI installed**
- ✅ **Authenticated with Vercel**
- ✅ **Project deployed successfully**
- ✅ **Dashboard accessible via public URL**
- ✅ **Environment variables configured**
- ✅ **Custom domain set up (optional)**
- ✅ **Analytics enabled**
- ✅ **Performance monitoring active**

## 🌟 Benefits of Vercel Deployment

1. **Global Accessibility**: Share your dashboard with anyone, anywhere
2. **Professional Presentation**: Impress clients and colleagues
3. **Easy Updates**: Deploy changes with a single command
4. **Scalability**: Handles traffic spikes automatically
5. **Cost Effective**: Free tier for personal projects
6. **Developer Experience**: Excellent CLI and dashboard

## 🚀 Next Steps After Deployment

1. **Share Your Dashboard**: Send the Vercel URL to your team
2. **Monitor Performance**: Check Vercel Analytics regularly
3. **Set Up Alerts**: Configure notifications for issues
4. **Optimize**: Use performance insights to improve
5. **Scale**: Upgrade plan if needed for production use

---

**Your AI4Bharat Dashboard will be accessible globally via Vercel! 🌍✨**
