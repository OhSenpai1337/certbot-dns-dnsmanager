# certbot-dns-dnsmanager

Certbot DNS-01 hooks for ISPsystem DNS Manager API.
This project automates DNS TXT record creation and deletion through the ISPsystem DNS Manager API using Certbot's `--manual-auth-hook` and `--manual-cleanup-hook`.
Use it to obtain Let's Encrypt certificates, including wildcard certificates such as `*.site.com`.

## Requirements
- Python 3
- curl
- dig
- Certbot

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/OhSenpai1337/certbot-dns-dnsmanager.git
cd certbot-dns-dnsmanager
```

### 2. Configure API access

Copy the example configuration and edit it:

```bash
nano config.sh
```

Set your DNS Manager API credentials:

```bash
API_HOST="your-dnsmanager-host.example.com"
API_USERNAME="your-username"
API_PASSWORD="your-password"
```

Use the API host expected by your ISPsystem installation.

### 3. Install Certbot

Install Certbot using the official instructions for your operating system:

https://certbot.eff.org/instructions?ws=other&os=snap

Ensure that `curl`, `python3`, and `dig` are also installed.

## Usage

### Obtain a certificate

Run Certbot with the DNS-01 challenge and the provided hooks:

```bash
sudo certbot certonly \
  --manual \
  --preferred-challenges dns-01 \
  --manual-auth-hook "/opt/certbot_isp/authenticator.sh" \
  --manual-cleanup-hook "/opt/certbot_isp/cleanup.sh" \
  --email info@site.com \
  --agree-tos \
  --no-eff-email \
  -d site.com \
  -d '*.site.com'
```

Replace `info@site.com` with your email address and `site.com` with your domain.

The hooks create the required `_acme-challenge` TXT record through the ISPsystem DNS Manager API, wait for DNS propagation, and remove the TXT record during cleanup.

### Renew a certificate

For certificates created using these hooks, renewal can be attempted with:

```bash
sudo certbot renew
```

Certbot must be able to access the hook scripts and their configuration during renewal. Verify that the hooks are configured correctly and that renewal works in your environment.

To test renewal without issuing a production certificate:

```bash
sudo certbot renew --dry-run
```

## How it works

1. Certbot starts the authentication hook.
2. The hook authenticates against the ISPsystem DNS Manager API.
3. A TXT record is created for `_acme-challenge`.
4. The hook checks DNS propagation through Cloudflare's public resolver (`1.1.1.1`).
5. Certbot performs the DNS-01 challenge.
6. The cleanup hook deletes the TXT record.

## Notes

- Wildcard certificates require the DNS-01 challenge.
- DNS propagation may take longer than expected, depending on your DNS provider and resolver caches.
- Keep `config.sh` private and never commit real API credentials.
- The cleanup hook runs after challenge processing; failed issuance may require checking for leftover TXT records.

## License

See the repository for license information.
