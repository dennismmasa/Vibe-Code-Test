#!/usr/bin/env python3
"""Simple running pace tracker.

Given a race goal and progress updates, report whether the runner is ahead,
on pace, or behind.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from urllib import request


@dataclass(frozen=True)
class PaceStatus:
    status: str
    target_pace_min_per_km: float
    current_pace_min_per_km: float
    projected_finish_min: float
    pace_gap_sec_per_km: float
    projected_vs_goal_sec: float


def _parse_hhmmss(value: str) -> int:
    parts = value.strip().split(":")
    if not 1 <= len(parts) <= 3:
        raise ValueError("Time must be in s, mm:ss, or hh:mm:ss format.")
    parts = [int(p) for p in parts]
    if any(p < 0 for p in parts):
        raise ValueError("Time values must be positive.")

    if len(parts) == 1:
        seconds = parts[0]
    elif len(parts) == 2:
        minutes, seconds_part = parts
        if seconds_part >= 60:
            raise ValueError("Seconds must be < 60 in mm:ss format.")
        seconds = minutes * 60 + seconds_part
    else:
        hours, minutes, seconds_part = parts
        if minutes >= 60 or seconds_part >= 60:
            raise ValueError("Minutes and seconds must be < 60 in hh:mm:ss format.")
        seconds = hours * 3600 + minutes * 60 + seconds_part

    if seconds == 0:
        raise ValueError("Time cannot be zero.")
    return seconds


def _format_minutes(total_minutes: float) -> str:
    total_seconds = max(0, round(total_minutes * 60))
    hours, remainder = divmod(total_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{hours:d}:{minutes:02d}:{seconds:02d}" if hours else f"{minutes:d}:{seconds:02d}"


def _format_pace(min_per_km: float) -> str:
    total_seconds = round(min_per_km * 60)
    minutes, seconds = divmod(total_seconds, 60)
    return f"{minutes}:{seconds:02d} /km"


def evaluate_pace(
    goal_distance_km: float,
    goal_time_sec: int,
    elapsed_distance_km: float,
    elapsed_time_sec: int,
    tolerance_sec_per_km: float = 5.0,
) -> PaceStatus:
    if goal_distance_km <= 0:
        raise ValueError("Goal distance must be > 0.")
    if elapsed_distance_km <= 0:
        raise ValueError("Elapsed distance must be > 0.")
    if elapsed_distance_km > goal_distance_km:
        raise ValueError("Elapsed distance cannot be greater than goal distance.")

    target_pace = (goal_time_sec / 60) / goal_distance_km
    current_pace = (elapsed_time_sec / 60) / elapsed_distance_km
    projected_finish = current_pace * goal_distance_km
    pace_gap_sec = (target_pace - current_pace) * 60
    projected_vs_goal_sec = (projected_finish * 60) - goal_time_sec

    if pace_gap_sec > tolerance_sec_per_km:
        status = "ahead"
    elif pace_gap_sec < -tolerance_sec_per_km:
        status = "behind"
    else:
        status = "on pace"

    return PaceStatus(
        status=status,
        target_pace_min_per_km=target_pace,
        current_pace_min_per_km=current_pace,
        projected_finish_min=projected_finish,
        pace_gap_sec_per_km=pace_gap_sec,
        projected_vs_goal_sec=projected_vs_goal_sec,
    )


def _post_webhook(url: str, payload: dict) -> None:
    data = json.dumps(payload).encode("utf-8")
    req = request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with request.urlopen(req, timeout=10):
        pass


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Track running pace against a goal.")
    parser.add_argument("--goal-distance", type=float, required=True, help="Goal distance in km (e.g. 10 or 42.195)")
    parser.add_argument("--goal-time", required=True, help="Goal finish time (hh:mm:ss, mm:ss, or seconds)")
    parser.add_argument("--distance", type=float, required=True, help="Distance completed so far in km")
    parser.add_argument("--elapsed", required=True, help="Elapsed run time (hh:mm:ss, mm:ss, or seconds)")
    parser.add_argument(
        "--tolerance-sec-per-km",
        type=float,
        default=5.0,
        help="Tolerance before calling ahead/behind (default: 5 sec/km)",
    )
    parser.add_argument("--json", action="store_true", help="Print machine-readable JSON output")
    parser.add_argument(
        "--webhook-url",
        help="Optional webhook URL to receive JSON updates (useful for phone/watch notifications)",
    )
    return parser


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()

    try:
        goal_time_sec = _parse_hhmmss(args.goal_time)
        elapsed_time_sec = _parse_hhmmss(args.elapsed)
        result = evaluate_pace(
            goal_distance_km=args.goal_distance,
            goal_time_sec=goal_time_sec,
            elapsed_distance_km=args.distance,
            elapsed_time_sec=elapsed_time_sec,
            tolerance_sec_per_km=args.tolerance_sec_per_km,
        )
    except ValueError as exc:
        parser.error(str(exc))

    gap_abs = abs(result.pace_gap_sec_per_km)
    direction = "faster" if result.pace_gap_sec_per_km > 0 else "slower"

    payload = {
        "status": result.status,
        "target_pace": _format_pace(result.target_pace_min_per_km),
        "current_pace": _format_pace(result.current_pace_min_per_km),
        "pace_gap_sec_per_km": round(result.pace_gap_sec_per_km, 2),
        "projected_finish": _format_minutes(result.projected_finish_min),
        "projected_vs_goal_sec": round(result.projected_vs_goal_sec, 1),
    }

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        print(f"Status: {result.status.upper()}")
        print(f"Target pace: {_format_pace(result.target_pace_min_per_km)}")
        print(f"Current pace: {_format_pace(result.current_pace_min_per_km)}")
        if result.status == "on pace":
            print("Pace gap: within tolerance")
        else:
            print(f"Pace gap: {gap_abs:.1f} sec/km {direction} than target")
        print(f"Projected finish: {_format_minutes(result.projected_finish_min)}")

    if args.webhook_url:
        _post_webhook(args.webhook_url, payload)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
