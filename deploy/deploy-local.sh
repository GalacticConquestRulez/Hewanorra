#!/usr/bin/env bash
# Publish the links page from a checkout ON the droplet. Use this when you are
# already on the server (the alternative, deploy/deploy.sh, pushes from your
# own machine over rsync).
#
#   cd /path/to/Hewanorra && git pull && sudo bash deploy/deploy-local.sh
#
# Safe to re-run.
set -euo pipefail

WEB_ROOT="/var/www/Hewanorra"
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -f "${SRC}/index.html" ] || { echo "error: index.html not found in ${SRC} — run this from the repo"; exit 1; }
[ -d "${SRC}/assets" ]     || { echo "error: assets/ not found in ${SRC}"; exit 1; }

echo "==> copying into ${WEB_ROOT}"
install -d -o www-data -g www-data "${WEB_ROOT}" "${WEB_ROOT}/assets"
cp "${SRC}/index.html" "${WEB_ROOT}/"
cp "${SRC}/assets/"* "${WEB_ROOT}/assets/"

echo "==> fixing ownership and modes"
chown -R www-data:www-data "${WEB_ROOT}"
find "${WEB_ROOT}" -type d -exec chmod 755 {} +
find "${WEB_ROOT}" -type f -exec chmod 644 {} +

echo
echo "Published. ${WEB_ROOT} now holds:"
ls -la "${WEB_ROOT}" "${WEB_ROOT}/assets"

cat <<'EOF'

Check it:
  curl -sI https://link.hewanorraexpress.com/ | head -1
  curl -sI https://link.hewanorraexpress.com/assets/bg.mp4 | head -4
    want:  200, Content-Type: video/mp4, Accept-Ranges: bytes
    not:   Content-Encoding: gzip
EOF
