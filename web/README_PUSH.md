Web Push / Lock-screen notifications — notes and quick start

Limitations / expectations
- iOS support: as of mid-2024, web push on iOS is limited; behavior may vary by iOS version and Safari support. Android (Chrome) widely supports push notifications and lock-screen display.
- Push notifications require HTTPS and a Service Worker (this project already registers one).
- Push notifications are delivered by a push service and appear on the lock screen if the OS permits.

Quick start (client + server)
1. Generate VAPID keys (on your dev machine):
   npx web-push generate-vapid-keys
   Copy the public and private keys.

2. Run the example server (in this repo's `web` folder):
   npm init -y
   npm install express body-parser web-push
   # set env vars or edit push-server-example.js to include your keys
   VAPID_PUBLIC=<your_public_key> VAPID_PRIVATE=<your_private_key> node push-server-example.js

3. Subscribe from the client (open the app in the browser on your device):
   - Go to Options → "Enable Lock-screen Notifications" button.
   - Paste the VAPID public key and the server endpoint (e.g. https://yourserver.com/subscribe or for local test: http://<your-host>:3000/subscribe).
   - The client will POST its subscription to the server.

4. Send a test push from the server:
   POST to http://localhost:3000/send with body:
   { "title": "Pace Update", "message": "You are ahead by 5s" }

Notes
- For production, store subscriptions securely server-side and send targeted pushes.
- Consider rate-limiting pushes to avoid spamming the lock screen (e.g., only send when status changes).
- For iOS-specific delivery, verify support on your target iOS version and test thoroughly.

If you want, I can scaffold a Netlify Function or a small hosted endpoint for sending pushes, and wire the client to it.