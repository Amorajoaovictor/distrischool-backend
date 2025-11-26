# Run JMeter test plan with Docker
# Usage: open PowerShell in workspace root and run: ./jmeter/run-jmeter.ps1

$resultsDir = Join-Path (Resolve-Path .\jmeter) results
if (-Not (Test-Path $resultsDir)) { New-Item -ItemType Directory -Path $resultsDir -Force | Out-Null }

# Remove existing results
Remove-Item -Path "$resultsDir\*" -Force -Recurse -ErrorAction SilentlyContinue

# Docker run - use host.docker.internal to reach localhost from container
docker run --rm -v "$(Resolve-Path .\jmeter):/test" -v "${resultsDir}:/results" justb4/jmeter:5.5 \
  -n -t /test/test-plan.jmx -l /results/result.jtl -j /results/jmeter.log -e -o /results/report

Write-Host "JMeter run finished. Results available in $resultsDir" -ForegroundColor Green
Write-Host "Open HTML report under $resultsDir\report/index.html" -ForegroundColor Yellow