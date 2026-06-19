"""Weekly shift-scheduling logic for the employee scheduler.

Rules enforced:
  - An employee works at most one shift per day.
  - An employee works at most MAX_DAYS_PER_WEEK days in the week.
  - Every shift, every day, must end up with at least MIN_PER_SHIFT employees;
    employees who have not hit their weekly cap are randomly assigned to
    under-staffed shifts.
  - If an employee's preferred shift is full, the scheduler looks for another
    open shift the same day, then carries the request over to the next day,
    before finally leaving the employee off for that day.
"""

import random

from models import DAYS, SHIFTS, MAX_DAYS_PER_WEEK, MIN_PER_SHIFT, MAX_PER_SHIFT


class ScheduleResult:
    def __init__(self, grid, roster, log):
        self.grid = grid        # day -> shift -> [employee names]
        self.roster = roster    # list[Employee], schedule/days_worked/notes filled in
        self.log = log          # list[str] of human-readable scheduling events


def _assign(employee, day, shift, grid, counts, assigned_today, note):
    employee.schedule[day] = shift
    employee.notes[day] = note
    employee.days_worked += 1
    counts[shift] += 1
    grid[day][shift].append(employee.name)
    assigned_today.add(employee.name)


def run_schedule(roster: list, seed: int | None = None) -> ScheduleResult:
    rng = random.Random(seed)
    grid = {day: {shift: [] for shift in SHIFTS} for day in DAYS}
    log = []
    deferred = []  # [(employee, preferred_shift)] carried over from the previous day

    for day in DAYS:
        assigned_today = set()
        counts = {shift: 0 for shift in SHIFTS}

        # Phase 0 - honor requests deferred from yesterday before anything else.
        carry_over, deferred = deferred, []
        for employee, wanted_shift in carry_over:
            if employee.days_worked >= MAX_DAYS_PER_WEEK or day in employee.rest_days:
                log.append(f"{day}: could not carry {employee.name} over from the prior day; stays off")
                continue
            if counts[wanted_shift] < MAX_PER_SHIFT:
                _assign(employee, day, wanted_shift, grid, counts, assigned_today, "conflict resolved on next day")
                log.append(f"{day}: {employee.name}'s shift conflict from yesterday resolved into {wanted_shift}")
            else:
                log.append(f"{day}: {employee.name}'s carried-over request for {wanted_shift} is still full; stays off")

        # Phase 1 - run everyone's ranked preference for today.
        for employee in roster:
            if employee.name in assigned_today:
                continue
            if day in employee.rest_days:
                continue
            if employee.days_worked >= MAX_DAYS_PER_WEEK:
                continue

            preferences_today = employee.preferences[day]
            placed = False
            for shift in preferences_today:
                if counts[shift] < MAX_PER_SHIFT:
                    _assign(employee, day, shift, grid, counts, assigned_today, "preferred shift")
                    placed = True
                    break

            if placed:
                continue

            # Conflict: every preferred shift is full today. Try any other open shift.
            for shift in SHIFTS:
                if shift not in preferences_today and counts[shift] < MAX_PER_SHIFT:
                    _assign(employee, day, shift, grid, counts, assigned_today, "reassigned (preferred shift full)")
                    log.append(f"{day}: {employee.name}'s preferred shift was full; moved to {shift} the same day")
                    placed = True
                    break

            if not placed:
                deferred.append((employee, preferences_today[0]))
                log.append(f"{day}: every shift is full for {employee.name}; deferring request to the next day")

        # Phase 2 - top up any shift that is still below the minimum headcount.
        # Prefer employees who aren't on a designated rest day today, so filling
        # one day's gap doesn't burn a cap slot that was meant for a later day;
        # only reach into someone's rest day if there is truly no one else left.
        for shift in SHIFTS:
            while counts[shift] < MIN_PER_SHIFT:
                candidates = [
                    e for e in roster
                    if e.name not in assigned_today and e.days_worked < MAX_DAYS_PER_WEEK and day not in e.rest_days
                ]
                if not candidates:
                    candidates = [
                        e for e in roster
                        if e.name not in assigned_today and e.days_worked < MAX_DAYS_PER_WEEK
                    ]
                if not candidates:
                    log.append(f"{day}: WARNING - could not reach the {MIN_PER_SHIFT}-person minimum for {shift}")
                    break
                chosen = rng.choice(candidates)
                _assign(chosen, day, shift, grid, counts, assigned_today, "auto-assigned to meet minimum staffing")
                log.append(f"{day}: {chosen.name} randomly assigned to {shift} to meet the minimum staffing rule")

    return ScheduleResult(grid, roster, log)


def format_schedule(result: ScheduleResult) -> str:
    lines = []
    lines.append("WEEKLY SHIFT SCHEDULE")
    lines.append("=" * 60)
    for day in DAYS:
        lines.append(f"\n{day}")
        lines.append("-" * len(day))
        for shift in SHIFTS:
            names = result.grid[day][shift] or ["(unfilled)"]
            lines.append(f"  {shift:<10}: {', '.join(names)}")

    lines.append("\n" + "=" * 60)
    lines.append("DAYS WORKED PER EMPLOYEE")
    lines.append("-" * 60)
    for employee in result.roster:
        lines.append(f"  {employee.name:<10}: {employee.days_worked} day(s)")

    lines.append("\n" + "=" * 60)
    lines.append("SCHEDULING LOG (conflicts and auto-assignments)")
    lines.append("-" * 60)
    if result.log:
        lines.extend(f"  - {entry}" for entry in result.log)
    else:
        lines.append("  (no conflicts; every preference was honored)")

    return "\n".join(lines)
