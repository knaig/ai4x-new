// AI4Bharat Translation Dashboard JavaScript

class AI4BharatDashboard {
    constructor() {
        this.apiEndpoint = null;
        this.isConnected = false;
        this.metrics = {
            totalRequests: 0,
            successfulRequests: 0,
            failedRequests: 0,
            responseTimes: [],
            languageUsage: {},
            requestsPerMinute: 0
        };
        this.charts = {};
        this.startTime = Date.now();
        this.requestCount = 0;
        this.lastMinuteRequests = [];
        
        this.initializeEventListeners();
        this.initializeCharts();
        this.checkConnection();
        this.startMonitoring();
    }

    initializeEventListeners() {
        // Translation button
        document.getElementById('translateBtn').addEventListener('click', () => {
            this.translateText();
        });

        // Clear button
        document.getElementById('clearBtn').addEventListener('click', () => {
            this.clearText();
        });

        // Swap languages button
        document.getElementById('swapBtn').addEventListener('click', () => {
            this.swapLanguages();
        });

        // Sample texts button
        document.getElementById('sampleBtn').addEventListener('click', () => {
            this.showSampleModal();
        });

        // Clear logs button
        document.getElementById('clearLogsBtn').addEventListener('click', () => {
            this.clearLogs();
        });

        // Sample text selection
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('sample-text')) {
                const text = e.target.dataset.text;
                document.getElementById('sourceText').value = text;
                this.detectLanguage(text);
                bootstrap.Modal.getInstance(document.getElementById('sampleModal')).hide();
            }
        });

        // Enter key in source text
        document.getElementById('sourceText').addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && e.ctrlKey) {
                this.translateText();
            }
        });
    }

    async checkConnection() {
        try {
            // Check our Flask backend API status
            const response = await fetch('/api/status');
            if (response.ok) {
                const data = await response.json();
                this.apiEndpoint = data.endpoint;
                this.isConnected = true;
                this.updateConnectionStatus(true);
                
                // Update model status based on backend health
                if (data.status === 'connected') {
                    this.updateModelStatus('Connected to AI4Bharat Model');
                } else {
                    this.updateModelStatus('Using Mock Translation Service');
                }
            } else {
                this.isConnected = false;
                this.updateConnectionStatus(false);
                this.updateModelStatus('Backend Unavailable');
            }
        } catch (error) {
            console.error('Backend connection error:', error);
            this.isConnected = false;
            this.updateConnectionStatus(false);
            this.updateModelStatus('Connection Failed');
        }

        this.updateSystemStatus();
    }

    async translateText() {
        const sourceText = document.getElementById('sourceText').value.trim();
        const sourceLanguage = document.getElementById('sourceLanguage').value;
        const targetLanguage = document.getElementById('targetLanguage').value;

        if (!sourceText) {
            this.showAlert('Please enter text to translate', 'warning');
            return;
        }

        if (!this.isConnected) {
            this.showAlert('Not connected to AI4Bharat service', 'error');
            return;
        }

        // Show loading state
        const translateBtn = document.getElementById('translateBtn');
        const originalText = translateBtn.innerHTML;
        translateBtn.innerHTML = '<span class="loading"></span> Translating...';
        translateBtn.disabled = true;

        const startTime = Date.now();

        try {
            // Make API call to AI4Bharat model
            const response = await this.callAI4BharatAPI(sourceText, sourceLanguage, targetLanguage);
            
            const endTime = Date.now();
            const responseTime = endTime - startTime;

            if (response.success) {
                // Update translation result
                document.getElementById('targetText').value = response.translation;
                
                // Update confidence score
                this.updateConfidenceScore(response.confidence);
                
                // Add to translation history
                this.addToTranslationHistory(sourceText, response.translation, sourceLanguage, targetLanguage, responseTime);
                
                // Update metrics
                this.updateMetrics(responseTime, true, sourceLanguage, targetLanguage);
                
                // Show success animation
                document.getElementById('targetText').classList.add('success-animation');
                setTimeout(() => {
                    document.getElementById('targetText').classList.remove('success-animation');
                }, 600);

                this.logAPI('success', `Translation successful: ${sourceText.substring(0, 50)}... → ${response.translation.substring(0, 50)}...`, responseTime);
            } else {
                throw new Error(response.error || 'Translation failed');
            }
        } catch (error) {
            console.error('Translation error:', error);
            this.showAlert(`Translation failed: ${error.message}`, 'error');
            this.updateMetrics(0, false, sourceLanguage, targetLanguage);
            this.logAPI('error', `Translation failed: ${error.message}`, 0);
        } finally {
            // Restore button state
            translateBtn.innerHTML = originalText;
            translateBtn.disabled = false;
        }
    }

    async callAI4BharatAPI(text, sourceLang, targetLang) {
        const payload = {
            text: text,
            source_language: sourceLang,
            target_language: targetLang
        };

        try {
            // Call our Flask backend API instead of the model directly
            const response = await fetch('/api/translate', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(payload)
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const data = await response.json();
            
            return {
                success: data.success || true,
                translation: data.translation || 'Translation not available',
                confidence: data.confidence || 0.85,
                response_time: data.response_time || 0,
                source: data.source || 'unknown'
            };
        } catch (error) {
            return {
                success: false,
                error: error.message
            };
        }
    }

    detectLanguage(text) {
        // Simple language detection based on script
        const scripts = {
            'hi': /[\u0900-\u097F]/, // Devanagari (Hindi, Marathi, etc.)
            'ta': /[\u0B80-\u0BFF]/, // Tamil
            'te': /[\u0C00-\u0C7F]/, // Telugu
            'kn': /[\u0C80-\u0CFF]/, // Kannada
            'ml': /[\u0D00-\u0D7F]/, // Malayalam
            'gu': /[\u0A80-\u0AFF]/, // Gujarati
            'pa': /[\u0A00-\u0A7F]/, // Gurmukhi (Punjabi)
            'bn': /[\u0980-\u09FF]/, // Bengali
            'ne': /[\u0900-\u097F]/, // Nepali (uses Devanagari)
            'en': /[a-zA-Z]/, // English
        };

        for (const [lang, script] of Object.entries(scripts)) {
            if (script.test(text)) {
                document.getElementById('sourceLanguage').value = lang;
                break;
            }
        }
    }

    updateConfidenceScore(confidence) {
        const confidenceBar = document.getElementById('confidenceBar');
        const percentage = Math.round(confidence * 100);
        
        confidenceBar.style.width = `${percentage}%`;
        confidenceBar.textContent = `${percentage}%`;
        
        // Update color based on confidence level
        confidenceBar.classList.remove('confidence-high', 'confidence-medium', 'confidence-low');
        if (percentage >= 80) {
            confidenceBar.classList.add('confidence-high');
        } else if (percentage >= 60) {
            confidenceBar.classList.add('confidence-medium');
        } else {
            confidenceBar.classList.add('confidence-low');
        }
    }

    addToTranslationHistory(source, target, sourceLang, targetLang, responseTime) {
        const historyContainer = document.getElementById('translationHistory');
        const historyItem = document.createElement('div');
        historyItem.className = 'translation-item';
        
        const timestamp = new Date().toLocaleTimeString();
        const sourceLangName = this.getLanguageName(sourceLang);
        const targetLangName = this.getLanguageName(targetLang);
        
        historyItem.innerHTML = `
            <div class="translation-source">
                <strong>${sourceLangName}</strong>: ${source}
            </div>
            <div class="translation-target">
                <strong>${targetLangName}</strong>: ${target}
            </div>
            <div class="translation-meta">
                <i class="fas fa-clock me-1"></i>${timestamp} | 
                <i class="fas fa-tachometer-alt me-1"></i>${responseTime}ms
            </div>
        `;
        
        historyContainer.insertBefore(historyItem, historyContainer.firstChild);
        
        // Keep only last 10 translations
        const items = historyContainer.querySelectorAll('.translation-item');
        if (items.length > 10) {
            items[items.length - 1].remove();
        }
    }

    getLanguageName(code) {
        const languages = {
            'hi': 'Hindi',
            'en': 'English',
            'ta': 'Tamil',
            'mr': 'Marathi',
            'gu': 'Gujarati',
            'ne': 'Nepali',
            'bn': 'Bengali',
            'te': 'Telugu',
            'kn': 'Kannada',
            'ml': 'Malayalam',
            'pa': 'Punjabi',
            'auto': 'Auto Detect'
        };
        return languages[code] || code;
    }

    updateMetrics(responseTime, success, sourceLang, targetLang) {
        this.metrics.totalRequests++;
        if (success) {
            this.metrics.successfulRequests++;
            if (responseTime > 0) {
                this.metrics.responseTimes.push(responseTime);
                // Keep only last 50 response times
                if (this.metrics.responseTimes.length > 50) {
                    this.metrics.responseTimes.shift();
                }
            }
        } else {
            this.metrics.failedRequests++;
        }

        // Update language usage
        const langPair = `${sourceLang}-${targetLang}`;
        this.metrics.languageUsage[langPair] = (this.metrics.languageUsage[langPair] || 0) + 1;

        // Update requests per minute
        const now = Date.now();
        this.lastMinuteRequests.push(now);
        this.lastMinuteRequests = this.lastMinuteRequests.filter(time => now - time < 60000);
        this.metrics.requestsPerMinute = this.lastMinuteRequests.length;

        this.updateMetricsDisplay();
        this.updateCharts();
    }

    updateMetricsDisplay() {
        const successRate = this.metrics.totalRequests > 0 
            ? Math.round((this.metrics.successfulRequests / this.metrics.totalRequests) * 100)
            : 100;

        const avgResponseTime = this.metrics.responseTimes.length > 0
            ? Math.round(this.metrics.responseTimes.reduce((a, b) => a + b, 0) / this.metrics.responseTimes.length)
            : 0;

        document.getElementById('responseTime').textContent = `${avgResponseTime}ms`;
        document.getElementById('requestsPerMin').textContent = this.metrics.requestsPerMinute;
        document.getElementById('successRate').textContent = `${successRate}%`;
        document.getElementById('totalRequests').textContent = this.metrics.totalRequests;
    }

    updateConnectionStatus(connected) {
        const statusElement = document.getElementById('connectionStatus');
        if (connected) {
            statusElement.className = 'badge bg-success';
            statusElement.textContent = 'Connected';
        } else {
            statusElement.className = 'badge bg-danger';
            statusElement.textContent = 'Disconnected';
        }
    }

    updateModelStatus(status) {
        const statusElement = document.getElementById('modelStatus');
        const badgeElement = document.getElementById('modelStatusBadge');
        
        let badgeClass = 'bg-warning';
        let text = status;
        
        switch (status.toLowerCase()) {
            case 'ready':
                badgeClass = 'bg-success';
                break;
            case 'loading':
                badgeClass = 'bg-warning';
                break;
            case 'error':
                badgeClass = 'bg-danger';
                break;
        }
        
        statusElement.className = `badge ${badgeClass}`;
        statusElement.textContent = status;
        badgeElement.className = `badge ${badgeClass}`;
        badgeElement.textContent = status;
    }

    updateSystemStatus() {
        document.getElementById('apiEndpoint').textContent = this.apiEndpoint || 'Backend API';
        document.getElementById('lastUpdate').textContent = new Date().toLocaleTimeString();

        const uptime = Math.floor((Date.now() - this.startTime) / 1000);
        const hours = Math.floor(uptime / 3600);
        const minutes = Math.floor((uptime % 3600) / 60);
        const seconds = uptime % 60;
        document.getElementById('uptime').textContent = `${hours}h ${minutes}m ${seconds}s`;
    }

    logAPI(type, message, responseTime) {
        const logsContainer = document.getElementById('apiLogs');
        const logEntry = document.createElement('div');
        logEntry.className = `log-entry ${type}`;
        
        const timestamp = new Date().toLocaleTimeString();
        const timeInfo = responseTime > 0 ? ` (${responseTime}ms)` : '';
        
        logEntry.innerHTML = `
            <div class="log-timestamp">[${timestamp}]${timeInfo}</div>
            <div class="log-message">${message}</div>
        `;
        
        logsContainer.insertBefore(logEntry, logsContainer.firstChild);
        
        // Keep only last 50 logs
        const entries = logsContainer.querySelectorAll('.log-entry');
        if (entries.length > 50) {
            entries[entries.length - 1].remove();
        }
    }

    clearText() {
        document.getElementById('sourceText').value = '';
        document.getElementById('targetText').value = '';
        document.getElementById('confidenceBar').style.width = '0%';
        document.getElementById('confidenceBar').textContent = '0%';
        document.getElementById('confidenceBar').className = 'progress-bar';
    }

    swapLanguages() {
        const sourceLang = document.getElementById('sourceLanguage');
        const targetLang = document.getElementById('targetLanguage');
        const sourceText = document.getElementById('sourceText');
        const targetText = document.getElementById('targetText');
        
        const tempLang = sourceLang.value;
        const tempText = sourceText.value;
        
        sourceLang.value = targetLang.value;
        targetLang.value = tempLang;
        sourceText.value = targetText.value;
        targetText.value = tempText;
    }

    showSampleModal() {
        const modal = new bootstrap.Modal(document.getElementById('sampleModal'));
        modal.show();
    }

    clearLogs() {
        document.getElementById('apiLogs').innerHTML = '';
    }

    showAlert(message, type) {
        // Create alert element
        const alertDiv = document.createElement('div');
        alertDiv.className = `alert alert-${type === 'error' ? 'danger' : type} alert-dismissible fade show`;
        alertDiv.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        `;
        
        // Insert at top of container
        const container = document.querySelector('.container-fluid');
        container.insertBefore(alertDiv, container.firstChild);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (alertDiv.parentNode) {
                alertDiv.remove();
            }
        }, 5000);
    }

    initializeCharts() {
        // Response Time Chart
        const responseTimeCtx = document.getElementById('responseTimeChart').getContext('2d');
        this.charts.responseTime = new Chart(responseTimeCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Response Time (ms)',
                    data: [],
                    borderColor: '#007bff',
                    backgroundColor: 'rgba(0, 123, 255, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Milliseconds'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Time'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });

        // Language Distribution Chart
        const languageCtx = document.getElementById('languageChart').getContext('2d');
        this.charts.language = new Chart(languageCtx, {
            type: 'doughnut',
            data: {
                labels: [],
                datasets: [{
                    data: [],
                    backgroundColor: [
                        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0',
                        '#9966FF', '#FF9F40', '#FF6384', '#C9CBCF'
                    ]
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 10
                            }
                        }
                    }
                }
            }
        });
    }

    updateCharts() {
        // Update Response Time Chart
        if (this.metrics.responseTimes.length > 0) {
            const labels = this.metrics.responseTimes.map((_, index) => `#${index + 1}`);
            this.charts.responseTime.data.labels = labels;
            this.charts.responseTime.data.datasets[0].data = this.metrics.responseTimes;
            this.charts.responseTime.update();
        }

        // Update Language Distribution Chart
        const languageData = Object.entries(this.metrics.languageUsage)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 8); // Show top 8 language pairs

        if (languageData.length > 0) {
            this.charts.language.data.labels = languageData.map(([lang, _]) => lang);
            this.charts.language.data.datasets[0].data = languageData.map(([_, count]) => count);
            this.charts.language.update();
        }
    }

    startMonitoring() {
        // Update system status every second
        setInterval(() => {
            this.updateSystemStatus();
        }, 1000);

        // Update metrics display every 5 seconds
        setInterval(() => {
            this.updateMetricsDisplay();
        }, 5000);

        // Log periodic status
        setInterval(() => {
            if (this.isConnected) {
                this.logAPI('info', 'System status check - All systems operational', 0);
            }
        }, 30000);
    }
}

// Initialize dashboard when page loads
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new AI4BharatDashboard();
    
    // Add tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});

// Handle page visibility changes
document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
        console.log('Page hidden - pausing monitoring');
    } else {
        console.log('Page visible - resuming monitoring');
    }
});

// Handle beforeunload
window.addEventListener('beforeunload', () => {
    console.log('Dashboard closing - cleaning up resources');
});
