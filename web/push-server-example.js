// Minimal Node.js example to send Web Push notifications
// Usage:
// 1. npm install web-push express body-parser
// 2. Generate VAPID keys: npx web-push generate-vapid-keys
// 3. Set VAPID_PUBLIC and VAPID_PRIVATE in code or env, run server
// 4. POST subscription JSON to /subscribe to store it (this example stores in-memory)
// 5. POST { "message": "text", "title": "Pace Update" } to /send to broadcast

const express = require('express');
const bodyParser = require('body-parser');
const webpush = require('web-push');

const app = express();
app.use(bodyParser.json());

// Replace with your generated keys or set via environment variables
const VAPID_PUBLIC = process.env.VAPID_PUBLIC || 'REPLACE_WITH_YOUR_PUBLIC_KEY';
const VAPID_PRIVATE = process.env.VAPID_PRIVATE || 'REPLACE_WITH_YOUR_PRIVATE_KEY';

webpush.setVapidDetails('mailto:you@example.com', VAPID_PUBLIC, VAPID_PRIVATE);

let subscriptions = [];

app.post('/subscribe', (req, res) => {
  const sub = req.body;
  subscriptions.push(sub);
  res.json({ ok: true });
});

app.post('/send', async (req, res) => {
  const { title = 'Pace Tracker', message = 'Update', data = {} } = req.body;
  const payload = JSON.stringify({ title, body: message, data });

  const results = await Promise.allSettled(subscriptions.map(s => webpush.sendNotification(s, payload)));
  res.json({ results });
});

app.listen(3000, () => console.log('Push server running on http://localhost:3000'));
