#!/usr/bin/env python3
"""Live pace tracker loop.

Reads samples from a CSV file and continuously evaluates whether you're
ahead/on-pace/behind, with optional webhook updates.

Sample file format (one sample per line):
    distance_km,elapsed_time
Example:
    1.0,5:02
    2.0,10:01
"""

from __future__ import annotations

import argparse
import json
import time
from pathlib import Path

from pace_tracker import (
    _format_minutes,
    _format_pace,
    _parse_hhmmss,
    _post_webhook,
    evaluate_pace,
)


def _parse_sample(line: str) -> tuple[float, int]:
    parts = [p.strip() for p in line.split(",")]
    if len(parts) != 2:
        raise ValueError("Sample must be: distance_km,elapsed_time")

    distance = float(parts[0])
    elapsed = _parse_hhmmss(parts[1])
    if distance <= 0:
        raise ValueError("distance_km must be > 0")
    return distance, elapsed


def _read_latest_sample(path: Path) -> tuple[float, int] | None:
    if not path.exists():
        return None

    lines = [line.strip() for line in path.read_text().splitlines() if line.strip()]
    if not lines:
        return None

    return _parse_sample(lines[-1])


def _result_payload(result) -> dict:
    return {
        "status": result.status,
        "target_pace": _format_pace(result.target_pace_min_per_km),
        "current_pace": _format_pace(result.current_pace_min_per_km),
        "pace_gap_sec_per_km": round(result.pace_gap_sec_per_km, 2),
        "projected_finish": _format_minutes(result.projected_finish_min),
        "projected_vs_goal_sec": round(result.projected_vs_goal_sec, 1),
        "event_type": "pace_update",
        "sent_at_epoch": int(time.time()),
    }


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Continuously monitor pace from sample file updates")
    parser.add_argument("--goal-distance", type=float, required=True, help="Goal distance in km")
    parser.add_argument("--goal-time", required=True, help="Goal finish time (hh:mm:ss, mm:ss, or seconds)")
    parser.add_argument("--samples-file", required=True, help="Path to CSV file with distance_km,elapsed_time samples")
    parser.add_argument("--interval", type=float, default=5.0, help="Polling interval in seconds (default: 5)")
    parser.add_argument(
        "--notify-on",
        choices=["always", "status-change"],
        default="status-change",
        help="When to send webhook updates (default: status-change)",
    )
    parser.add_argument("--webhook-url", help="Optional webhook URL for mobile/watch notifications")
    parser.add_argument("--json", action="store_true", help="Print JSON payload per update")
    return parser


def main() -> int:
    args = _build_parser().parse_args()

    goal_time_sec = _parse_hhmmss(args.goal_time)
    sample_path = Path(args.samples_file)

    last_sample = None
    last_status = None

    print(f"Watching {sample_path} every {args.interval}s... (Ctrl+C to stop)")

    try:
        while True:
            sample = _read_latest_sample(sample_path)
            if sample is not None and sample != last_sample:
                distance, elapsed_sec = sample
                result = evaluate_pace(
                    goal_distance_km=args.goal_distance,
                    goal_time_sec=goal_time_sec,
                    elapsed_distance_km=distance,
                    elapsed_time_sec=elapsed_sec,
                )
                payload = _result_payload(result)

                should_notify = args.notify_on == "always" or result.status != last_status

                if args.json:
                    print(json.dumps(payload))
                else:
                    print(
                        f"distance={distance:.2f}km status={result.status} "
                        f"current={payload['current_pace']} projected={payload['projected_finish']}"
                    )

                if should_notify and args.webhook_url:
                    _post_webhook(args.webhook_url, payload)

                last_sample = sample
                last_status = result.status

            time.sleep(args.interval)
    except KeyboardInterrupt:
        print("Stopped.")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
