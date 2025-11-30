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

## OpenSSH format

- The private key you provided (starting with `-----BEGIN OPENSSH PRIVATE KEY-----`) is accepted by the workflow and by `webfactory/ssh-agent` used in CI.
If you receive an `error in libcrypto` when adding the key to `ssh-agent`, convert the key to PEM format which is better supported on some runners:

```bash
# Convert an OpenSSH key to PEM format (non-passphrase) locally
ssh-keygen -p -f ~/.ssh/distrischool_deploy_key -N "" -m PEM
```

If the key is passphrase-protected, you'll need to remove the passphrase for CI to use it without an interactive prompt (or use an ssh-agent that can load passphrased keys). To remove a passphrase:

```bash
ssh-keygen -p -f ~/.ssh/distrischool_deploy_key -P 'old-passphrase' -N '' -m PEM
```

If you cannot remove the passphrase, consider generating a dedicated CI deploy key without a passphrase and adding it to the server's `authorized_keys`.

## How to set the secret (SERVER_SSH_KEY)

1. Generate a key locally (if you don't have one already):

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/distrischool_deploy_key -C "distrischool deploy key"
# Keep it private on your machine only; do NOT commit it to repository
```

2. Copy the **private key** and paste it into your GitHub Actions secret `SERVER_SSH_KEY`:

- GitHub web UI: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`
- Name: `SERVER_SSH_KEY`
- Value: contents of `~/.ssh/distrischool_deploy_key` (include the full header and footer lines, e.g., `-----BEGIN OPENSSH PRIVATE KEY-----` ...)

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

## How to add the secret using GH CLI (example)

```bash
# Replace owner/repo accordingly
gh secret set SERVER_SSH_KEY -R owner/repo --body "$(cat ~/.ssh/distrischool_deploy_key)"
gh secret set SERVER_HOST -R owner/repo --body "your.server.com"
gh secret set SERVER_USER -R owner/repo --body "deployuser"
gh secret set SERVER_PORT -R owner/repo --body "22"
gh secret set VERBOSE_SSH -R owner/repo --body "false"
```

Note: If your private key is in OpenSSH format (the one you posted), it's supported by the pipeline and `webfactory/ssh-agent` will load the key correctly.

## Troubleshooting
- If the CI step `ssh -vvv` or `ssh` fails with `Permission denied`, make sure the public key is added to the server's `~/.ssh/authorized_keys` and that it's in the correct file format.
- If `ssh` is blocked by firewall, ensure port 22 (or your `SERVER_PORT`) is accessible from the GitHub runner.
- If `docker` requires `sudo`, make sure the deploy user is in the docker group or use `sudo` in docker commands.

### If you accidentally pasted the private key in public

- If you accidentally pasted the private key into the repository, a PR, or public chat, **rotate the key immediately**: delete the old key from the server `authorized_keys`, generate a new key, add the new public key to the server, and replace `SERVER_SSH_KEY` secret.
	- To remove from server:
	```bash
	# on the server as the deploy user
	# remove the old line from ~/.ssh/authorized_keys
	sed -i '/<your-key-fingerprint-or-key-prompt>/d' ~/.ssh/authorized_keys
	```
	- To rotate and add new secret:
	```bash
	ssh-keygen -t rsa -b 4096 -f ~/.ssh/new_distrischool_deploy_key -C "distrischool deploy key" -N ""
	gh secret set SERVER_SSH_KEY -R owner/repo --body "$(cat ~/.ssh/new_distrischool_deploy_key)"
	```

## Security notes
- Never commit a private key to the repository
- Use GitHub Secrets to store private data
- Use a dedicated deploy key or account where possible
- Consider using `webfactory/ssh-agent` or `appleboy/ssh-action` to avoid writing private key files on the runner
