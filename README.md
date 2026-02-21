# Pace Tracker

A lightweight CLI tool that tells you whether you're **ahead**, **on pace**, or **behind** your race goal.

## 1) Basic usage

```bash
python3 pace_tracker.py \
  --goal-distance 10 \
  --goal-time 50:00 \
  --distance 4.2 \
  --elapsed 20:30
```

## 2) JSON output (for automations)

```bash
python3 pace_tracker.py \
  --goal-distance 21.1 \
  --goal-time 1:45:00 \
  --distance 10 \
  --elapsed 48:00 \
  --json
```

## 3) Send updates to your phone/watch now

```bash
python3 pace_tracker.py \
  --goal-distance 10 \
  --goal-time 50:00 \
  --distance 4.2 \
  --elapsed 20:30 \
  --webhook-url https://your-endpoint.example/hook
```

Recommended immediate setup:
- Route webhook payloads through **Pipedream / Make / Zapier**.
- Trigger an **Apple Shortcut** or push provider (Pushcut/Pushover/Telegram).
- iPhone notifications mirror to Apple Watch automatically when configured.

## 4) Next step for LIVE tracking (added)

Use `live_tracker.py` to continuously monitor a file of incoming run samples and push updates whenever status changes.

### Sample input file
Create `run_samples.csv`:

```text
1.0,5:02
2.0,10:01
```

### Start live loop

```bash
python3 live_tracker.py \
  --goal-distance 10 \
  --goal-time 50:00 \
  --samples-file run_samples.csv \
  --interval 5 \
  --notify-on status-change \
  --webhook-url https://your-endpoint.example/hook
```

Now append lines as your run progresses (`distance_km,elapsed_time`) and the tracker recalculates automatically.

## Make this real on iPhone + Apple Watch (practical roadmap)

1. **Prototype (today):**
   - Keep this Python pace logic.
   - Use webhook + automation platform to push notifications to iPhone/Watch.

2. **Field test (this week):**
   - Capture real workout samples from your phone/watch app (or export from Strava/Garmin/Apple Health bridge).
   - Feed those samples into `live_tracker.py` and tune `--tolerance-sec-per-km`.

3. **Production app (next):**
   - Build an iOS/watchOS app using:
     - `HealthKit` for workout metrics.
     - `HKWorkoutSession` / `HKLiveWorkoutBuilder` for live distance/time.
     - Local notifications/haptics for “ahead/behind” alerts.
   - Port `evaluate_pace` logic from `pace_tracker.py` directly to Swift.

4. **Ship-ready features:**
   - Smoothing window (last N seconds pace).
   - Alert cooldown (e.g., no repeat alert for 60s).
   - Offline-first behavior + background execution handling.
   - Optional cloud sync for historical runs.

## Arguments (`pace_tracker.py`)

- `--goal-distance`: total target distance in kilometers.
- `--goal-time`: target finish time (`seconds`, `mm:ss`, or `hh:mm:ss`).
- `--distance`: distance you've completed so far (km).
- `--elapsed`: your elapsed time (`seconds`, `mm:ss`, or `hh:mm:ss`).
- `--tolerance-sec-per-km`: how close to target pace counts as "on pace" (default `5`).
- `--json`: print machine-readable JSON.
- `--webhook-url`: POST JSON payload to a webhook URL.

## Arguments (`live_tracker.py`)

- `--goal-distance`: total target distance in km.
- `--goal-time`: target finish time.
- `--samples-file`: CSV file updated with latest sample (`distance_km,elapsed_time`).
- `--interval`: polling interval seconds.
- `--notify-on`: `always` or `status-change`.
- `--webhook-url`: optional webhook endpoint.
- `--json`: output each update as JSON.

## Run tests

```bash
python3 -m unittest discover -s tests -v
```
