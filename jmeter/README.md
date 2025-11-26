# JMeter Load Tests for Distrischool

This folder contains a JMeter test plan (`test-plan.jmx`) and a small PowerShell script to run it using a Dockerized JMeter image.

How to run (Docker must be running):

1. Build images and ensure your services are up (via `infra/docker/docker-compose.yml`).

2. Run the JMeter test plan (PowerShell):

```powershell
cd <repo-root>
./jmeter/run-jmeter.ps1
```

Or run directly with Docker:

```powershell
# Mount the jmeter folder into the container
docker run --rm -v "${PWD}/jmeter:/test" -v "${PWD}/jmeter/results:/results" justb4/jmeter:5.5 -n -t /test/test-plan.jmx -l /results/result.jtl -j /results/jmeter.log -e -o /results/report
```

3. Results:
- `jmeter/results/result.jtl` - raw sample results
- `jmeter/results/jmeter.log` - JMeter log
- `jmeter/results/report/index.html` - HTML dashboard report

Notes & Troubleshooting:
- The JMeter test hits `http://host.docker.internal:8080` (use this when running from Docker on Windows) — change the `HTTP Request Defaults` if needed.
- The `test-plan.jmx` includes a login POST to obtain the token and uses it in subsequent requests.
- If Docker fails, ensure Docker Desktop / Engine is running (WSL backend configured for Linux images, etc.).

Tuning the test:
- Edit `test-plan.jmx` Thread Group settings:
  - Threads (users)
  - Ramp-up (seconds)
  - Loop count

Security:
- The test logs contain the token; do not check-in sensitive log files to the repository.

If you want me to run the test here, enable Docker engine (or confirm it is running in this environment) and I will re-run it and summarize results for you.