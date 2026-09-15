#!/usr/bin/env python3
"""Deterministic gate between the LLM's receipt extraction and the ledger
write. The model reads the photo; this script is the one thing that decides
whether what it read is well-formed enough to become a row. An unrecognized
category is coerced to "other" rather than rejected -- merchants are not a
closed set and a new one should not block a real receipt.
"""
import json
import sys
from datetime import date
from pathlib import Path

REQUIRED_FIELDS = ("merchant", "total", "date", "category")


def fail(field, reason):
    print(f"{field}: {reason}", file=sys.stderr)
    return 1


def main():
    if len(sys.argv) != 2:
        print("usage: validate_extraction.py '<json>'", file=sys.stderr)
        return 2

    try:
        extracted = json.loads(sys.argv[1])
    except json.JSONDecodeError as exc:
        return fail("json", f"not valid JSON: {exc}")

    if not isinstance(extracted, dict):
        return fail("json", "must be a JSON object")

    missing = [f for f in REQUIRED_FIELDS if f not in extracted]
    if missing:
        return fail(",".join(missing), "missing")

    merchant = extracted["merchant"]
    if not isinstance(merchant, str) or not merchant.strip():
        return fail("merchant", "must be a non-empty string")

    total = extracted["total"]
    if isinstance(total, bool) or not isinstance(total, (int, float)):
        return fail("total", "must be a number")
    if total <= 0:
        return fail("total", "must be positive")

    try:
        date.fromisoformat(extracted["date"])
    except (TypeError, ValueError):
        return fail("date", "must be YYYY-MM-DD and a real calendar date")

    config_path = Path(__file__).resolve().parent.parent / "config.json"
    categories = json.loads(config_path.read_text()).get("categories", [])
    category = extracted["category"]
    if category not in categories:
        category = "other"

    print(json.dumps({
        "merchant": merchant.strip(),
        "total": total,
        "date": extracted["date"],
        "category": category,
    }))
    return 0


if __name__ == "__main__":
    sys.exit(main())
