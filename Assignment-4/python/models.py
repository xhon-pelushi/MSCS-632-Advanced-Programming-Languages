"""Shared data model for the weekly employee shift scheduler."""

from dataclasses import dataclass, field

DAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
SHIFTS = ["Morning", "Afternoon", "Evening"]

MAX_DAYS_PER_WEEK = 5
MIN_PER_SHIFT = 2
MAX_PER_SHIFT = 4


@dataclass
class Employee:
    name: str
    preferences: dict          # day -> list of 1-2 shifts, ranked by priority
    rest_days: set             # two fixed days off for the week
    days_worked: int = 0
    schedule: dict = field(default_factory=dict)   # day -> shift assigned
    notes: dict = field(default_factory=dict)       # day -> how the assignment happened


def rest_days_for(index: int) -> set:
    """Stagger two rest days per employee round-robin across the week so every
    day keeps enough of the roster available, instead of everyone exhausting
    their 5-day cap on the same early days."""
    return {DAYS[(2 * index) % 7], DAYS[(2 * index + 1) % 7]}


def build_roster(raw_employees: list) -> list:
    roster = []
    for index, raw in enumerate(raw_employees):
        roster.append(
            Employee(
                name=raw["name"],
                preferences=raw["preferences"],
                rest_days=rest_days_for(index),
            )
        )
    return roster
