# AI4Bharat Model API Test Script with Timestamps
# This script demonstrates how to make API calls to your deployed model

function Write-TimestampedMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Test-ModelHealth {
    param([string]$ServiceUrl)
    
    Write-TimestampedMessage "🔍 Testing model health..." "Blue"
    $startTime = Get-Date
    
    try {
        $response = Invoke-RestMethod -Uri "$ServiceUrl/v1/models/ai4bharat-bert" -Method Get -TimeoutSec 10
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-TimestampedMessage "✅ Model health check passed in $($duration.TotalMilliseconds.ToString('F0')) ms" "Green"
        return $true
    } catch {
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-TimestampedMessage "❌ Model health check failed in $($duration.TotalMilliseconds.ToString('F0')) ms" "Red"
        Write-TimestampedMessage "Error: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-ModelPrediction {
    param(
        [string]$ServiceUrl,
        [string]$Text,
        [string]$Language
    )
    
    Write-TimestampedMessage "🚀 Testing prediction for $Language text..." "Blue"
    $startTime = Get-Date
    
    try {
        $payload = @{
            instances = @($Text)
        } | ConvertTo-Json -Depth 10
        
        $headers = @{
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri "$ServiceUrl/v1/models/ai4bharat-bert:predict" -Method Post -Body $payload -Headers $headers -TimeoutSec 30
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-TimestampedMessage "✅ Prediction successful in $($duration.TotalMilliseconds.ToString('F0')) ms" "Green"
        Write-TimestampedMessage "📝 Input: $Text" "Cyan"
        Write-TimestampedMessage "🎯 Response: $($response | ConvertTo-Json -Depth 10)" "Yellow"
        
        return $true
    } catch {
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-TimestampedMessage "❌ Prediction failed in $($duration.TotalMilliseconds.ToString('F0')) ms" "Red"
        Write-TimestampedMessage "Error: $($_.Exception.Message)" "Red"
        return $false
    }
}

function Test-BatchPredictions {
    param([string]$ServiceUrl)
    
    Write-TimestampedMessage "📚 Testing batch predictions with multiple languages..." "Blue"
    
    $testCases = @(
        @{ Text = "नमस्ते, कैसे हो आप?"; Language = "Hindi" },
        @{ Text = "Hello, how are you?"; Language = "English" },
        @{ Text = "வணக்கம், எப்படி இருக்கிறீர்கள்?"; Language = "Tamil" },
        @{ Text = "नमस्कार, तुम्ही कसे आहात?"; Language = "Marathi" },
        @{ Text = "नमस्कार, तपाईं कसरी हुनुहुन्छ?"; Language = "Nepali" },
        @{ Text = "नमस्कार, તમે કેમ છો?"; Language = "Gujarati" }
    )
    
    $successCount = 0
    $totalStartTime = Get-Date
    
    foreach ($testCase in $testCases) {
        Write-TimestampedMessage "--- Testing $($testCase.Language) ---" "White"
        if (Test-ModelPrediction -ServiceUrl $ServiceUrl -Text $testCase.Text -Language $testCase.Language) {
            $successCount++
        }
        Start-Sleep -Seconds 1  # Small delay between requests
    }
    
    $totalEndTime = Get-Date
    $totalDuration = $totalEndTime - $totalStartTime
    
    Write-TimestampedMessage "📊 Batch test results:" "Cyan"
    Write-TimestampedMessage "   ✅ Successful: $successCount/$($testCases.Count)" "Green"
    Write-TimestampedMessage "   ❌ Failed: $($testCases.Count - $successCount)/$($testCases.Count)" "Red"
    Write-TimestampedMessage "   ⏱️ Total time: $($totalDuration.TotalSeconds.ToString('F2')) seconds" "Yellow"
}

function Test-PerformanceMetrics {
    param([string]$ServiceUrl)
    
    Write-TimestampedMessage "⚡ Testing performance metrics..." "Blue"
    
    $testText = "Hello, this is a performance test"
    $iterations = 10
    $responseTimes = @()
    
    Write-TimestampedMessage "Running $iterations iterations..." "Cyan"
    
    for ($i = 1; $i -le $iterations; $i++) {
        $startTime = Get-Date
        
        try {
            $payload = @{ instances = @($testText) } | ConvertTo-Json -Depth 10
            $headers = @{ "Content-Type" = "application/json" }
            
            $response = Invoke-RestMethod -Uri "$ServiceUrl/v1/models/ai4bharat-bert:predict" -Method Post -Body $payload -Headers $headers -TimeoutSec 30
            
            $endTime = Get-Date
            $duration = $endTime - $startTime
            $responseTimes += $duration.TotalMilliseconds
            
            Write-TimestampedMessage "  Iteration $i`: $($duration.TotalMilliseconds.ToString('F0')) ms" "White"
        } catch {
            Write-TimestampedMessage "  Iteration $i`: Failed" "Red"
        }
        
        Start-Sleep -Milliseconds 200
    }
    
    if ($responseTimes.Count -gt 0) {
        $avgResponseTime = ($responseTimes | Measure-Object -Average).Average
        $minResponseTime = ($responseTimes | Measure-Object -Minimum).Minimum
        $maxResponseTime = ($responseTimes | Measure-Object -Maximum).Maximum
        
        Write-TimestampedMessage "📈 Performance Summary:" "Cyan"
        Write-TimestampedMessage "   📊 Average: $($avgResponseTime.ToString('F2')) ms" "Green"
        Write-TimestampedMessage "   🚀 Fastest: $($minResponseTime.ToString('F2')) ms" "Green"
        Write-TimestampedMessage "   🐌 Slowest: $($maxResponseTime.ToString('F2')) ms" "Yellow"
    }
}

# Main execution
Write-TimestampedMessage "🧪 Starting AI4Bharat Model API Tests" "Green"
Write-TimestampedMessage "=====================================" "Green"

# Get the service URL
Write-TimestampedMessage "🔍 Getting service URL..." "Blue"
try {
    $serviceUrl = kubectl get inferenceservice ai4bharat-bert -n ai4bharat-serving -o jsonpath='{.status.url}'
    if (-not $serviceUrl) {
        Write-TimestampedMessage "❌ Could not get service URL. Please check if the model is deployed." "Red"
        Write-TimestampedMessage "💡 Run: kubectl get inferenceservices -n ai4bharat-serving" "Yellow"
        exit 1
    }
    Write-TimestampedMessage "✅ Service URL: $serviceUrl" "Green"
} catch {
    Write-TimestampedMessage "❌ Error getting service URL: $($_.Exception.Message)" "Red"
    exit 1
}

# Test model health
if (-not (Test-ModelHealth -ServiceUrl $serviceUrl)) {
    Write-TimestampedMessage "❌ Model is not healthy. Please check the deployment." "Red"
    exit 1
}

# Test batch predictions
Test-BatchPredictions -ServiceUrl $serviceUrl

# Test performance metrics
Test-PerformanceMetrics -ServiceUrl $serviceUrl

Write-TimestampedMessage "🎉 All tests completed!" "Green"
Write-TimestampedMessage ""
Write-TimestampedMessage "💡 You can also test manually with:" "Cyan"
Write-TimestampedMessage "   curl -X POST `"$serviceUrl/v1/models/ai4bharat-bert:predict`" `"White"
Write-TimestampedMessage "     -H `"Content-Type: application/json`" `"White"
Write-TimestampedMessage "     -d '{\"instances\": [\"नमस्ते, कैसे हो आप?\"]}'" "White"
