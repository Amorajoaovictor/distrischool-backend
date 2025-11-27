# Run JMeter test plan with Docker
# Usage: Navigate to the distrischool folder and run: .\jmeter\run-jmeter.ps1
# Make sure Docker Desktop is running and your services are up (docker compose up -d in infra/docker)

param(
    [int]$Threads = 60,  # Total threads: 10 Admin + 30 Student + 20 Teacher
    [int]$Duration = 60  # Duration in seconds (optional)
)

Write-Host "=== Distrischool JMeter Load Test ===" -ForegroundColor Cyan
Write-Host "Preparing test environment..." -ForegroundColor Yellow

# Get the script directory (jmeter folder)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$jmeterDir = $scriptDir

# Create results directory if it doesn't exist
$resultsDir = Join-Path $jmeterDir "results"
if (-Not (Test-Path $resultsDir)) { 
    New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null 
    Write-Host "Created results directory: $resultsDir" -ForegroundColor Green
}

# Clean up old results
Write-Host "Cleaning up old results..." -ForegroundColor Yellow
Remove-Item -Path "$resultsDir\*" -Force -Recurse -ErrorAction SilentlyContinue

# Verify Docker is running
try {
    docker version | Out-Null
    Write-Host "Docker is running" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check if services are up
Write-Host "Checking if gateway is reachable..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
    Write-Host "Gateway is UP and responding" -ForegroundColor Green
} catch {
    Write-Host "WARNING: Gateway at localhost:8080 is not responding. Make sure services are running." -ForegroundColor Red
    Write-Host "Run: cd infra/docker ; docker compose up -d" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne 'y') { exit 1 }
}

# Run JMeter test
Write-Host "`nStarting JMeter load test..." -ForegroundColor Cyan
Write-Host "Test Plan: test-plan.jmx" -ForegroundColor White
Write-Host "Thread Groups:" -ForegroundColor White
Write-Host "  - Admin Users: 10 threads, 5 loops" -ForegroundColor White
Write-Host "  - Student Users: 30 threads, 10 loops" -ForegroundColor White
Write-Host "  - Teacher Users: 20 threads, 10 loops" -ForegroundColor White
Write-Host "`nResults will be saved to: $resultsDir" -ForegroundColor White
Write-Host "Running test... (this may take a few minutes)`n" -ForegroundColor Yellow

# Docker run - use host.docker.internal to reach localhost from container
docker run --rm `
    -v "${jmeterDir}:/test" `
    -v "${resultsDir}:/results" `
    justb4/jmeter:5.5 `
    -n `
    -t /test/test-plan.jmx `
    -l /results/result.jtl `
    -j /results/jmeter.log `
    -e `
    -o /results/report

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== JMeter Test Completed Successfully ===" -ForegroundColor Green
    Write-Host "`nResults Summary:" -ForegroundColor Cyan
    Write-Host "  - JTL File: $resultsDir\result.jtl" -ForegroundColor White
    Write-Host "  - JMeter Log: $resultsDir\jmeter.log" -ForegroundColor White
    Write-Host "  - HTML Report: $resultsDir\report\index.html" -ForegroundColor White
    Write-Host "`nTo view the HTML report, open:" -ForegroundColor Yellow
    Write-Host "  $resultsDir\report\index.html" -ForegroundColor Cyan
    
    # Ask if user wants to open the report
    $openReport = Read-Host "`nOpen HTML report now? (y/n)"
    if ($openReport -eq 'y') {
        Start-Process "$resultsDir\report\index.html"
    }
} else {
    Write-Host "`n=== JMeter Test Failed ===" -ForegroundColor Red
    Write-Host "Check the log file for details: $resultsDir\jmeter.log" -ForegroundColor Yellow
    exit 1
}