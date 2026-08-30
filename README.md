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
`links.greenflashusa.com`, from `/var/www/Hewanorra`.

The domain belongs to the client; the server does not. Their web guy points
the subdomain here with a single DNS record, and deploys stay on our side:

| Type | Name    | Value              |
| ---- | ------- | ------------------ |
| A    | `link`  | `159.223.127.113`  |

## Where things live

Two separate locations, which is easy to trip over:

| | |
| --- | --- |
| `/root/Hewanorra` (or wherever you clone) | the **source** checkout — git, deploy scripts |
| `/var/www/Hewanorra` | what nginx actually **serves** |

Cloning the repo does not publish the site. A deploy step copies the page
and its assets from the checkout into the web root.

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

Two ways, depending on where you are. Both copy `index.html` and `assets/`
into `/var/www/Hewanorra` — there is nothing to build.

On the droplet, from a checkout:

```bash
git pull && sudo bash deploy/deploy-local.sh
```

Or from your own machine, over rsync:

```bash
./deploy/deploy.sh root@159.223.127.113
```

`--delete` on the rsync path is scoped to this site's own root.

## Editing the page

Each link is one `<a class="card">` block. Copy a block, change the `href`,
the `.name` and the `.sub` text. The four booking cards
(`.card--book`) open Calendly in an overlay; the script skips any card whose
`href` is still `#`, so nothing loads from Calendly until a real URL is in.

## Connecting the contact form

The form posts to Formspree. To wire it up, set the endpoint near the top of
the page's second `<script>` block:

```js
var FORMSPREE_ENDPOINT = "https://formspree.io/f/xxxxxxxx";
```

That is the only change needed. Setting it also gives the form a real
`action`, so it still works for anyone with JavaScript off — Formspree
accepts the plain POST and shows its own confirmation page.

While the value is empty the form still validates, but sends nothing and
says so, pointing people at the phone number instead. That way it can be
demoed without silently swallowing a real enquiry.

The form includes Formspree's `_gotcha` honeypot for spam, and sets
`_subject` so notification emails are identifiable.

## Editing the links

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
