# Deploy / CI Secrets and SSH setup

This file explains how to add the required secrets to GitHub Actions and how to install the public key on your deploy server.

## Secrets used by CI

- SERVER_SSH_KEY - The *private* SSH key used by the workflow to access the server (PEM/OPENSSH private key). Do NOT commit the private key into the repository — add it as a GitHub Actions secret.
- SERVER_HOST - Hostname or IP of the server where the app will be deployed.
- SERVER_USER - Username used to connect to the server.
- SERVER_PORT (optional) - SSH port to use if different than 22.
- VERBOSE_SSH (optional) - Set to `true` if you want the verbose SSH test (`ssh -vvv`) in CI. Default: false.

Additionally, the build step checks the following environment variables for running integration tests. These are also configured as secrets if you want the pipeline to run integration tests:
- SPRING_DATASOURCE_URL
- DB_HOST
- POSTGRES_DB
- KAFKA_BOOTSTRAP_SERVERS

## How to set the secret (SERVER_SSH_KEY)

1. Generate a key locally (if you don't have one already):

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/distrischool_deploy_key -C "distrischool deploy key"

# Keep it private on your machine only; do NOT commit it to repository
```

2. Copy the **private key** (the file ending in e.g., `distrischool_deploy_key`) and paste into your GitHub Actions secret `SERVER_SSH_KEY`:

- GitHub web UI: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`
- Name: `SERVER_SSH_KEY`
- Value: contents of `~/.ssh/distrischool_deploy_key` (include the full header and footer lines, e.g. "-----BEGIN OPENSSH PRIVATE KEY-----" ...)

3. Add the public key to the server's `authorized_keys` under the user specified by `SERVER_USER` so that the workflow can SSH in using the private key:

```bash
# from your local machine
cat ~/.ssh/distrischool_deploy_key.pub
# copy and paste the output

# on the server (or via existing SSH access)
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo 'ssh-rsa AAAA...your-public-key...' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

4. Add `SERVER_HOST`, `SERVER_USER`, and (if needed) `SERVER_PORT` in the repo secrets similarly.

## Validation steps (manual test)

From your machine where you have the private key file `~/.ssh/distrischool_deploy_key`:

```bash
ssh -i ~/.ssh/distrischool_deploy_key <USER>@<HOST> -p <PORT> -o StrictHostKeyChecking=no 'echo SSH_OK; whoami; hostname; docker --version; docker-compose --version'
```

Make sure that:
- `whoami` returns the user you configured
- `docker --version` and `docker-compose --version` work (or you have the right permissions)
- The user can `git pull` if needed

## Security notes
- Never commit a private key to the repository
- Use GitHub Secrets to store private data
- Use a dedicated deploy key or account where possible
- Consider using `webfactory/ssh-agent` or `appleboy/ssh-action` to avoid writing private key files on the runner

## Using `webfactory/ssh-agent`
You can replace the manual `Install SSH Key` step with `webfactory/ssh-agent` or `appleboy/ssh-action`:

```yaml
- uses: webfactory/ssh-agent@v0.5.3
  with:
    ssh-private-key: ${{ secrets.SERVER_SSH_KEY }}
```

Or use `appleboy/ssh-action` to run remote commands directly without writing the key to disk.

---

If you want me to add either of these actions to the CI workflow and remove lower-level key-handling, say which one you prefer and I will make the change.
