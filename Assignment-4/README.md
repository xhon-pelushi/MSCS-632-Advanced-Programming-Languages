# Assignment 4 — Employee Shift Scheduler

Two implementations of the same weekly shift-scheduling engine: **Python**
(with a Tkinter GUI) and **Go**.

## Rules implemented

- 7-day week, 3 shifts per day (Morning, Afternoon, Evening)
- No employee works more than one shift per day
- An employee works at most 5 days per week
- Each shift each day needs at least 2 employees; under-staffed shifts are
  filled by randomly selecting eligible employees who have not hit their
  5-day cap
- Shift conflicts (preferred shift already full) are resolved by trying
  another open shift the same day, then carrying the request over to the
  next day
- Bonus: employees may rank a 1st and 2nd choice shift per day, and the
  scheduler honors that ranking

## Python

```
cd python
python3 cli.py     # console output
python3 gui.py     # Tkinter GUI - build a roster, then generate/view the schedule
```

Requires Python 3.10+ (standard library only; `tkinter` ships with the
default install).

## Go

```
cd go
go run .
```

Requires Go 1.22+. The sample roster (`data/employees.json`) is embedded
into the binary at build time via `go:embed`.

## Sample data

Both implementations read the same 13-employee sample roster
(`data/employees.json`) so their outputs can be compared directly.
