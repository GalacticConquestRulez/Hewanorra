# Hewanorra Express — links page

The link-in-bio page for [Hewanorra Express](https://hewanorraexpress.com),
St. Lucia's water ferry service. Served at **link.hewanorraexpress.com**.

One static `index.html` plus four assets. No build step, no dependencies,
no server-side code.

```
index.html            the page (all CSS and JS inline)
assets/bg.mp4         background footage, 1080×1920 @ 30fps
assets/bg-poster.jpg  first frame, shown while the video loads
assets/logo.png       the mark
assets/og.jpg         link-preview image
```

## Hosting

Runs on the Green Flash droplet, alongside `greenflashusa.com` and
`links.greenflashusa.com`, from `/var/www/hewanorra-link`.

The domain belongs to the client; the server does not. Their web guy points
the subdomain here with a single DNS record, and deploys stay on our side:

| Type | Name    | Value              |
| ---- | ------- | ------------------ |
| A    | `link`  | `159.223.127.113`  |

## First-time setup

On the droplet, from a checkout of this repo:

```bash
sudo bash deploy/provision.sh
```

This adds the nginx site and reloads. It does not touch `ufw` or any other
site's config, and re-running it leaves an existing conf alone — certbot
rewrites that file in place, so overwriting it would delete HTTPS.

Then, once DNS resolves to the droplet:

```bash
certbot --nginx -d link.hewanorraexpress.com
```

## Deploying a change

From your machine:

```bash
./deploy/deploy.sh root@159.223.127.113
```

Nothing to build — it rsyncs `index.html` and `assets/` up. `--delete` is
scoped to this site's own root.

## Editing the page

Each link is one `<a class="card">` block. Copy a block, change the `href`,
the `.name` and the `.sub` text. The four booking cards
(`.card--book`) open Calendly in an overlay; the script skips any card whose
`href` is still `#`, so nothing loads from Calendly until a real URL is in.

Two things worth knowing before changing them:

- **The subdomain is baked in.** The canonical URL and the OpenGraph and
  Twitter tags are written as `https://link.hewanorraexpress.com/`. Moving
  the page to a different hostname means updating those, or link previews
  break.
- **Don't gzip the MP4.** The nginx conf deliberately leaves `video/mp4` out
  of `gzip_types` — compressing it breaks the byte-range requests Safari
  needs, and the background silently falls back to a still image on iPhone.

## Verifying a deploy

```bash
dig +short link.hewanorraexpress.com     # points at the droplet
curl -sI https://link.hewanorraexpress.com/assets/bg.mp4
#   want:  Content-Type: video/mp4
#          Accept-Ranges: bytes
#   not:   Content-Encoding: gzip
```

Then open it on a real iPhone and confirm the background plays. iOS autoplay
rules are stricter than any desktop browser, so that is the one check a
desktop cannot stand in for.
