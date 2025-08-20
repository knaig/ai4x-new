# AI4Bharat Model API Test Script using curl
# This script demonstrates how to make API calls using curl

function Write-TimestampedMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Test-ModelWithCurl {
    param(
        [string]$ServiceUrl,
        [string]$Text,
        [string]$Language
    )
    
    Write-TimestampedMessage "🚀 Testing $Language with curl..." "Blue"
    $startTime = Get-Date
    
    try {
        # Create the curl command
        $curlCommand = "curl -X POST `"$ServiceUrl/v1/models/ai4bharat-bert:predict`" -H `"Content-Type: application/json`" -d '{\"instances\": [\"$Text\"]}'"
        
        Write-TimestampedMessage "📝 Command: $curlCommand" "Cyan"
        
        # Execute curl command
        $response = Invoke-Expression $curlCommand
        
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-TimestampedMessage "✅ Request completed in $($duration.TotalMilliseconds.ToString('F0')) ms" "Green"
        Write-TimestampedMessage "📝 Input: $Text" "Cyan"
        Write-TimestampedMessage "🎯 Response: $response" "Yellow"
        
        return $true
    } catch {
        $endTime = Get-Date
        $duration = $endTime - $startTime
        Write-TimestampedMessage "❌ Request failed in $($duration.TotalMilliseconds.ToString('F0')) ms" "Red"
        Write-TimestampedMessage "Error: $($_.Exception.Message)" "Red"
        return $false
    }
}

# Main execution
Write-TimestampedMessage "🧪 Starting AI4Bharat Model API Tests with curl" "Green"
Write-TimestampedMessage "===============================================" "Green"

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

# Test different languages
$testCases = @(
    @{ Text = "नमस्ते, कैसे हो आप?"; Language = "Hindi" },
    @{ Text = "Hello, how are you?"; Language = "English" },
    @{ Text = "வணக்கம், எப்படி இருக்கிறீர்கள்?"; Language = "Tamil" },
    @{ Text = "नमस्कार, तुम्ही कसे आहात?"; Language = "Marathi" }
)

$successCount = 0
$totalStartTime = Get-Date

foreach ($testCase in $testCases) {
    Write-TimestampedMessage "--- Testing $($testCase.Language) ---" "White"
    if (Test-ModelWithCurl -ServiceUrl $serviceUrl -Text $testCase.Text -Language $testCase.Language) {
        $successCount++
    }
    Start-Sleep -Seconds 1  # Small delay between requests
}

$totalEndTime = Get-Date
$totalDuration = $totalEndTime - $totalStartTime

Write-TimestampedMessage "📊 Test results:" "Cyan"
Write-TimestampedMessage "   ✅ Successful: $successCount/$($testCases.Count)" "Green"
Write-TimestampedMessage "   ❌ Failed: $($testCases.Count - $successCount)/$($testCases.Count)" "Red"
Write-TimestampedMessage "   ⏱️ Total time: $($totalDuration.TotalSeconds.ToString('F2')) seconds" "Yellow"

Write-TimestampedMessage "🎉 All tests completed!" "Green"
Write-TimestampedMessage ""
Write-TimestampedMessage "💡 Manual curl examples:" "Cyan"
Write-TimestampedMessage "   # Health check" "White"
Write-TimestampedMessage "   curl `"$serviceUrl/v1/models/ai4bharat-bert`"" "White"
Write-TimestampedMessage ""
Write-TimestampedMessage "   # Hindi text prediction" "White"
Write-TimestampedMessage "   curl -X POST `"$serviceUrl/v1/models/ai4bharat-bert:predict`" -H `"Content-Type: application/json`" -d '{\"instances\": [\"नमस्ते, कैसे हो आप?\"]}'" "White"
Write-TimestampedMessage ""
Write-TimestampedMessage "   # English text prediction" "White"
Write-TimestampedMessage "   curl -X POST `"$serviceUrl/v1/models/ai4bharat-bert:predict`" -H `"Content-Type: application/json`" -d '{\"instances\": [\"Hello, how are you?\"]}'" "White"
