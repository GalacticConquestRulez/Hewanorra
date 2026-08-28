#!/usr/bin/env bash
# One-time setup to add link.hewanorraexpress.com as a new nginx site on the
# droplet. Safe to run alongside the sites already there (greenflashusa.com,
# links.greenflashusa.com) — it does not touch ufw or any other site's config.
#
# Run on the droplet, from a checkout of this repo:
#   sudo bash deploy/provision.sh
#
# Re-running is safe: once certbot has rewritten the nginx conf to add the SSL
# block, this leaves that file alone rather than overwriting HTTPS away.
set -euo pipefail

DOMAIN="link.hewanorraexpress.com"
WEB_ROOT="/var/www/hewanorra-link"
AVAIL="/etc/nginx/sites-available/${DOMAIN}"
ENABLED="/etc/nginx/sites-enabled/${DOMAIN}"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -f "${SRC}/deploy/nginx/${DOMAIN}.conf" ] || {
  echo "error: run this from a checkout of the repo"; exit 1; }

command -v nginx >/dev/null || { apt-get update && apt-get install -y nginx; }
command -v certbot >/dev/null || apt-get install -y certbot python3-certbot-nginx

mkdir -p "${WEB_ROOT}"
chown -R www-data:www-data "${WEB_ROOT}"

if [ -f "${AVAIL}" ]; then
  echo "==> ${AVAIL} already installed, leaving it alone (certbot may own it now)"
else
  echo "==> installing nginx conf"
  cp "${SRC}/deploy/nginx/${DOMAIN}.conf" "${AVAIL}"
  ln -sfn "${AVAIL}" "${ENABLED}"
fi

echo "==> testing nginx config"
nginx -t

echo "==> reloading nginx"
systemctl reload nginx

cat <<EOF

nginx is now serving ${DOMAIN} from ${WEB_ROOT}.

Next:
1. Confirm the client's DNS A record for ${DOMAIN} points at this droplet:
     dig +short ${DOMAIN}
2. Push the site up from your machine:
     ./deploy/deploy.sh root@159.223.127.113
3. Once DNS resolves here, enable HTTPS:
     certbot --nginx -d ${DOMAIN}
EOF
