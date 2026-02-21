# Pace Tracker — Web Version

A responsive web app (PWA) for tracking and evaluating running pace in real-time. Add it to your home screen as an app on any phone or web browser.

## 🚀 Quick Start

No build or Xcode required. Just open the web app and add to your home screen.

### Option 1: Run Locally (for development)

```bash
# Start a simple HTTP server
cd web
python3 -m http.server 8000

# Open in browser
open http://localhost:8000
```

### Option 2: Deploy to GitHub Pages (free, public)

1. Push the `web/` folder to your GitHub repo.
2. Go to **Settings → Pages** and enable GitHub Pages, pointing to the `web/` folder.
3. Your app is now live at `https://yourusername.github.io/repo-name/web/`.

### Option 3: Deploy to Netlify (free, 1-click)

1. Drag & drop the `web/` folder to [Netlify](https://netlify.com).
2. Your app is live instantly with a unique URL.

### Option 4: Deploy to Vercel (free)

1. Install Vercel CLI: `npm i -g vercel`.
2. Run `vercel` from the `web/` folder.
3. Follow prompts; your app is live.

## 📱 Add to Home Screen

**iPhone (Safari):**
1. Open the web app in Safari.
2. Tap the **Share** button → tap **Add to Home Screen**.
3. Choose a name (or keep "Pace Tracker") and tap **Add**.
4. The app icon appears on your home screen!

**Android (Chrome):**
1. Open the web app in Chrome.
2. Tap the **menu** (three dots) → **Install app** (or **Add to Home Screen**).
3. The app installs as a home screen shortcut.

## Features

- ⏱ **Evaluate pace** and compare vs. goal.
- 📊 **Real-time calculations**: target pace, current pace, gap, projected finish.
- 🎨 **Color-coded status**: ahead (green), on pace (blue), behind (red).
- 🔋 **Works offline** — app is cached for offline use once installed.
- ⚡ **No installation** — just open in a browser and add to home screen.
- 📲 **Responsive design** — optimized for mobile, tablet, and desktop.

## Input Format

- **Goal Distance**: kilometers (e.g., `10`, `21.1`)
- **Goal Time**: `mm:ss`, `hh:mm:ss`, or seconds (e.g., `50:00`, `1:45:00`, `3000`)
- **Current Distance**: kilometers (e.g., `4.2`)
- **Elapsed Time**: `mm:ss` or seconds (e.g., `20:30`, `1230`)
- **Tolerance**: seconds per km difference to count as "on pace" (default: `5`)

## Examples

### Quick Test 1: Easy 10K Run
- Goal: 10 km in 50:00
- Current: 4.2 km in 20:30
- Result: **AHEAD** — pace is 4:53/km vs 5:00/km target.

### Quick Test 2: Half Marathon
- Goal: 21.1 km in 1:45:00
- Current: 10 km in 48:00
- Result: **AHEAD** — projected finish 1:41:17.

## Customization

### Change colors/theme
Edit the `<style>` section in `index.html`:
```css
body {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}
```

### Change app name/icon
Edit `manifest.json`:
```json
{
  "name": "My Custom App Name",
  "short_name": "Shortcut",
  "icons": [...]
}
```

## Troubleshooting

**App won't install:**
- Ensure you're on HTTPS (required for PWA; localhost works for dev).
- Try a different browser or device.
- Clear browser cache and try again.

**Service Worker not caching:**
- Ensure service-worker.js is in the same directory as index.html.
- Check browser DevTools → Application → Service Workers.

**Want to add Webhooks/Notifications?**
- Update the JavaScript in `index.html` to call your webhook endpoint on evaluate.
- Example: `fetch('https://your-api.com/hook', { method: 'POST', body: JSON.stringify(result) })`

## Deployment Checklist

- [ ] Clone/pull repo locally.
- [ ] Choose a hosting option (GitHub Pages, Netlify, Vercel, or local HTTP server).
- [ ] Deploy the `web/` folder.
- [ ] Open the live URL in your phone browser.
- [ ] Tap "Add to Home Screen" (Share → Add to Home Screen on iPhone; menu → Install on Android).
- [ ] Use the app!

## Next Steps

- Add GPS distance tracking (use browser Geolocation API if desired).
- Add webhook support to send results to external services.
- Build an Apple Shortcut that pairs with this web app for notifications.
- Deploy notification service (e.g., Pushcut, Telegram) to receive pace updates.

---

**Questions?** See [README.md](../README.md) for the full project overview.
