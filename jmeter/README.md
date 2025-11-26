# JMeter Load Tests for Distrischool

This folder contains a JMeter test plan (`test-plan.jmx`) and a PowerShell script to run it using a Dockerized JMeter image.

## Test Configuration

The test plan includes **3 thread groups** simulating different user types:

### 1. Admin Users
- **Threads:** 10 users
- **Loops:** 5 iterations per user
- **Ramp-up:** 10 seconds
- **Credentials:** `admin@distrischool.com` / `admin123`
- **Endpoints Tested:**
  - POST `/api/auth/login` (get admin token)
  - GET `/api/alunos` (all students)
  - GET `/api/teachers` (all teachers)

### 2. Student Users
- **Threads:** 30 users
- **Loops:** 10 iterations per user
- **Ramp-up:** 20 seconds
- **Credentials:** `aluno.teste.2025072@unifor.br` / `81aca49c`
- **Endpoints Tested:**
  - POST `/api/auth/login` (get student token)
  - GET `/api/alunos/me` (own profile)
  - GET `/api/alunos` (all students - may be restricted by RBAC)

### 3. Teacher Users
- **Threads:** 20 users
- **Loops:** 10 iterations per user
- **Ramp-up:** 15 seconds
- **Credentials:** `professor.teste.prof.60@unifor.br` / `77037428`
- **Endpoints Tested:**
  - POST `/api/auth/login` (get teacher token)
  - GET `/api/alunos` (all students)
  - GET `/api/alunos/13` (specific student)
  - GET `/api/teachers` (all teachers)

**Total Load:** ~60 concurrent users with 500+ total requests

## Prerequisites

1. **Docker Desktop** must be running (WSL2 backend recommended for Windows)
2. **Distrischool services** must be up and running:
   ```powershell
   cd infra/docker
   docker compose up -d
   ```
3. Verify gateway is reachable at `http://localhost:8080`

## How to Run

### Option 1: Using the PowerShell Script (Recommended)

Navigate to the workspace root and run:

```powershell
.\jmeter\run-jmeter.ps1
```

The script will:
- ✅ Check if Docker is running
- ✅ Verify gateway health at localhost:8080
- ✅ Clean up old results
- ✅ Run the JMeter test in a Docker container
- ✅ Generate HTML dashboard report
- ✅ Offer to open the report automatically

### Option 2: Manual Docker Command

```powershell
cd C:\Users\amora\distrischool

docker run --rm `
  -v "${PWD}/jmeter:/test" `
  -v "${PWD}/jmeter/results:/results" `
  justb4/jmeter:5.5 `
  -n -t /test/test-plan.jmx `
  -l /results/result.jtl `
  -j /results/jmeter.log `
  -e -o /results/report
```

## Results

After running the test, you'll find:

- **`results/result.jtl`** - Raw sample results (CSV format)
- **`results/jmeter.log`** - JMeter execution log
- **`results/report/index.html`** - **📊 HTML Dashboard Report** (open in browser)

### Viewing the Report

Open the HTML report in your browser:

```powershell
Start-Process .\jmeter\results\report\index.html
```

The dashboard includes:
- Response time percentiles (50th, 90th, 95th, 99th)
- Throughput (requests/second)
- Error rate percentage
- Active threads over time
- Response time over time graphs

## Tuning the Test

Edit `test-plan.jmx` (in JMeter GUI or text editor) to modify:

- **Thread count** - Number of concurrent users per group
- **Loop count** - Iterations per thread
- **Ramp-up time** - How quickly threads start (in seconds)
- **Endpoints** - Add/remove HTTP Samplers
- **Think time** - Add delays between requests (use Constant Timer)

## Troubleshooting

### ❌ Docker not found
Make sure Docker Desktop is installed and running.

### ❌ Gateway not responding
Verify services are up:
```powershell
cd infra/docker
docker compose ps
docker compose up -d  # Restart if needed
```

Test gateway manually:
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/actuator/health"
```

### ❌ Login failures (401 Unauthorized)
- Verify credentials in `test-plan.jmx` match your database
- Check auth-service logs: `docker logs docker-auth-service-1`

### ❌ High error rate in results
- Check service logs for specific errors
- Reduce thread count or increase ramp-up time
- Verify database/Kafka are healthy

### ❌ host.docker.internal not resolving (Linux)
On Linux, replace `host.docker.internal` with `172.17.0.1` (Docker bridge IP) or use `--network=host` in docker run command.

## Security Notes

⚠️ **Do not commit sensitive data:**
- The `results/` folder contains tokens in logs
- Add `jmeter/results/` to `.gitignore`
- Use test credentials only (never production credentials)

## Advanced Usage

### Running from JMeter GUI

1. Download JMeter: https://jmeter.apache.org/download_jmeter.cgi
2. Extract and run: `bin/jmeter.bat` (Windows) or `bin/jmeter.sh` (Linux/Mac)
3. Open `test-plan.jmx`
4. Modify as needed
5. Click the green "Start" button (▶️)

### CI/CD Integration

Add to your pipeline (GitHub Actions, Jenkins, etc.):

```yaml
- name: Run JMeter Load Test
  run: |
    cd infra/docker
    docker compose up -d
    sleep 30  # Wait for services to be ready
    cd ../..
    ./jmeter/run-jmeter.ps1
```

### Distributed Testing

For higher loads, use JMeter's distributed mode with multiple worker nodes (requires JMeter server setup on multiple machines).

## Resources

- [JMeter Documentation](https://jmeter.apache.org/usermanual/index.html)
- [JMeter Best Practices](https://jmeter.apache.org/usermanual/best-practices.html)
- [Docker JMeter Image](https://hub.docker.com/r/justb4/jmeter)
