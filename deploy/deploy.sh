#!/usr/bin/env bash
# Ships the links page to the droplet. Run from your machine, any time you
# want to publish a change:
#
#   ./deploy/deploy.sh root@YOUR_DROPLET_IP
#
# There is no build step — the page is static. --delete is scoped to this
# site's own root, so nothing else on the droplet is touched.
set -euo pipefail

TARGET="${1:?Usage: deploy.sh user@your-droplet-ip}"
REMOTE_ROOT="/var/www/hewanorra-links"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${REPO_ROOT}"
[ -f index.html ] || { echo "error: index.html not found in ${REPO_ROOT}"; exit 1; }

echo "==> syncing to ${TARGET}:${REMOTE_ROOT}"
# No trailing slash on `assets`, so it lands as ${REMOTE_ROOT}/assets/.
rsync -az --delete --chmod=D755,F644 \
  index.html assets \
  "${TARGET}:${REMOTE_ROOT}/"

echo "==> fixing ownership"
ssh "${TARGET}" "chown -R www-data:www-data ${REMOTE_ROOT}"

echo
echo "Deployed to ${TARGET}:${REMOTE_ROOT}"
echo "Check it: https://links.hewanorraexpress.com/"
