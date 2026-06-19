"""Console entry point: load the sample roster, build the week's schedule, print it."""

import json
from pathlib import Path

from models import build_roster
from scheduler import run_schedule, format_schedule

DATA_FILE = Path(__file__).parent / "data" / "employees.json"


def main():
    raw_employees = json.loads(DATA_FILE.read_text())
    roster = build_roster(raw_employees)
    result = run_schedule(roster, seed=42)
    print(format_schedule(result))


if __name__ == "__main__":
    main()
