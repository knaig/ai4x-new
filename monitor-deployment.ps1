# AI4Bharat KServe Deployment Monitor
# This script monitors the deployment progress in real-time

function Write-TimestampedMessage {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Monitor-Namespace {
    param([string]$Namespace)
    
    Write-TimestampedMessage "📦 Monitoring namespace: $Namespace" "Blue"
    
    try {
        $namespace = kubectl get namespace $Namespace -o jsonpath='{.status.phase}' 2>$null
        if ($namespace -eq "Active") {
            Write-TimestampedMessage "✅ Namespace $Namespace is Active" "Green"
            return $true
        } else {
            Write-TimestampedMessage "⏳ Namespace $Namespace status: $namespace" "Yellow"
            return $false
        }
    } catch {
        Write-TimestampedMessage "❌ Namespace $Namespace not found" "Red"
        return $false
    }
}

function Monitor-Pods {
    param([string]$Namespace, [string]$LabelSelector = "")
    
    Write-TimestampedMessage "🐳 Monitoring pods in namespace: $Namespace" "Blue"
    
    try {
        if ($LabelSelector) {
            $pods = kubectl get pods -n $Namespace -l $LabelSelector -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{" "}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>$null
        } else {
            $pods = kubectl get pods -n $Namespace -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.phase}{" "}{.status.containerStatuses[0].ready}{"\n"}{end}' 2>$null
        }
        
        if ($pods) {
            $podsArray = $pods -split "`n" | Where-Object { $_ -ne "" }
            $readyCount = 0
            $totalCount = $podsArray.Count
            
            foreach ($pod in $podsArray) {
                $parts = $pod -split " "
                if ($parts.Count -ge 3) {
                    $podName = $parts[0]
                    $phase = $parts[1]
                    $ready = $parts[2]
                    
                    if ($phase -eq "Running" -and $ready -eq "true") {
                        Write-TimestampedMessage "  ✅ $podName: Running and Ready" "Green"
                        $readyCount++
                    } elseif ($phase -eq "Running") {
                        Write-TimestampedMessage "  🟡 $podName: Running but not Ready" "Yellow"
                    } elseif ($phase -eq "Pending") {
                        Write-TimestampedMessage "  ⏳ $podName: Pending" "Yellow"
                    } elseif ($phase -eq "Failed") {
                        Write-TimestampedMessage "  ❌ $podName: Failed" "Red"
                    } else {
                        Write-TimestampedMessage "  🔄 $podName: $phase" "Cyan"
                    }
                }
            }
            
            Write-TimestampedMessage "📊 Pod Status: $readyCount/$totalCount ready" "Cyan"
            return $readyCount, $totalCount
        } else {
            Write-TimestampedMessage "  ⏳ No pods found yet" "Yellow"
            return 0, 0
        }
    } catch {
        Write-TimestampedMessage "  ❌ Error monitoring pods: $($_.Exception.Message)" "Red"
        return 0, 0
    }
}

function Monitor-Service {
    param([string]$Namespace, [string]$ServiceName)
    
    Write-TimestampedMessage "🌐 Monitoring service: $ServiceName" "Blue"
    
    try {
        $service = kubectl get service $ServiceName -n $Namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null
        if ($service) {
            Write-TimestampedMessage "✅ Service $ServiceName has external IP: $service" "Green"
            return $true
        } else {
            Write-TimestampedMessage "⏳ Service $ServiceName external IP not ready yet" "Yellow"
            return $false
        }
    } catch {
        Write-TimestampedMessage "❌ Service $ServiceName not found" "Red"
        return $false
    }
}

function Monitor-InferenceService {
    param([string]$Namespace, [string]$ServiceName)
    
    Write-TimestampedMessage "🤖 Monitoring InferenceService: $ServiceName" "Blue"
    
    try {
        $status = kubectl get inferenceservice $ServiceName -n $Namespace -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>$null
        $url = kubectl get inferenceservice $ServiceName -n $Namespace -o jsonpath='{.status.url}' 2>$null
        
        if ($status -eq "True") {
            Write-TimestampedMessage "✅ InferenceService $ServiceName is Ready" "Green"
            if ($url) {
                Write-TimestampedMessage "🌐 Service URL: $url" "Cyan"
            }
            return $true
        } else {
            Write-TimestampedMessage "⏳ InferenceService $ServiceName status: $status" "Yellow"
            return $false
        }
    } catch {
        Write-TimestampedMessage "❌ InferenceService $ServiceName not found" "Red"
        return $false
    }
}

function Monitor-Events {
    param([string]$Namespace)
    
    Write-TimestampedMessage "📋 Recent events in namespace: $Namespace" "Blue"
    
    try {
        $events = kubectl get events -n $Namespace --sort-by='.lastTimestamp' | Select-Object -First 5
        if ($events) {
            foreach ($event in $events) {
                $timestamp = $event.LastTimestamp
                $type = $event.Type
                $reason = $event.Reason
                $message = $event.Message
                
                $color = switch ($type) {
                    "Normal" { "Green" }
                    "Warning" { "Yellow" }
                    default { "White" }
                }
                
                Write-TimestampedMessage "  [$timestamp] $type/$reason: $message" $color
            }
        } else {
            Write-TimestampedMessage "  ⏳ No recent events" "Yellow"
        }
    } catch {
        Write-TimestampedMessage "  ❌ Error getting events: $($_.Exception.Message)" "Red"
    }
}

# Main monitoring loop
Write-TimestampedMessage "🔍 Starting AI4Bharat KServe Deployment Monitor" "Green"
Write-TimestampedMessage "=============================================" "Green"
Write-TimestampedMessage "Press Ctrl+C to stop monitoring" "Yellow"
Write-TimestampedMessage ""

$startTime = Get-Date
$iteration = 0

try {
    while ($true) {
        $iteration++
        $currentTime = Get-Date
        $elapsed = $currentTime - $startTime
        
        Write-TimestampedMessage "🔄 Monitoring iteration $iteration (Elapsed: $($elapsed.TotalMinutes.ToString('F1')) minutes)" "Cyan"
        Write-TimestampedMessage "==================================================" "Cyan"
        
        # Monitor namespaces
        $kserveNamespace = Monitor-Namespace "kserve"
        $ai4bharatNamespace = Monitor-Namespace "ai4bharat-serving"
        
        # Monitor KServe controller
        if ($kserveNamespace) {
            $kserveReady, $kserveTotal = Monitor-Pods "kserve" "app=kserve-controller-manager"
        }
        
        # Monitor AI4Bharat serving
        if ($ai4bharatNamespace) {
            $ai4bharatReady, $ai4bharatTotal = Monitor-Pods "ai4bharat-serving"
            
            # Monitor InferenceService
            $inferenceServiceReady = Monitor-InferenceService "ai4bharat-serving" "ai4bharat-bert"
        }
        
        # Monitor events
        if ($ai4bharatNamespace) {
            Monitor-Events "ai4bharat-serving"
        }
        
        Write-TimestampedMessage ""
        
        # Check if everything is ready
        if ($kserveNamespace -and $ai4bharatNamespace -and $inferenceServiceReady) {
            Write-TimestampedMessage "🎉 All components are ready! Deployment complete!" "Green"
            Write-TimestampedMessage "⏱️ Total deployment time: $($elapsed.TotalMinutes.ToString('F2')) minutes" "Cyan"
            break
        }
        
        # Wait before next iteration
        Start-Sleep -Seconds 10
        Write-TimestampedMessage ""
    }
} catch {
    Write-TimestampedMessage "🛑 Monitoring stopped by user" "Yellow"
}

Write-TimestampedMessage "🔍 Final status check:" "Cyan"
Write-TimestampedMessage "==================================================" "Cyan"

# Final status check
if ($kserveNamespace) {
    Write-TimestampedMessage "📦 KServe namespace: Active" "Green"
} else {
    Write-TimestampedMessage "📦 KServe namespace: Not ready" "Red"
}

if ($ai4bharatNamespace) {
    Write-TimestampedMessage "📦 AI4Bharat namespace: Active" "Green"
} else {
    Write-TimestampedMessage "📦 AI4Bharat namespace: Not ready" "Red"
}

if ($inferenceServiceReady) {
    Write-TimestampedMessage "🤖 InferenceService: Ready" "Green"
    $url = kubectl get inferenceservice ai4bharat-bert -n ai4bharat-serving -o jsonpath='{.status.url}' 2>$null
    if ($url) {
        Write-TimestampedMessage "🌐 Service URL: $url" "Cyan"
    }
} else {
    Write-TimestampedMessage "🤖 InferenceService: Not ready" "Red"
}

Write-TimestampedMessage ""
Write-TimestampedMessage "💡 Next steps:" "Cyan"
Write-TimestampedMessage "   .\test-model-calls.ps1" "White"
Write-TimestampedMessage "   .\test-with-curl.ps1" "White"
Write-TimestampedMessage "   python test-model.py <service-url>" "White"
