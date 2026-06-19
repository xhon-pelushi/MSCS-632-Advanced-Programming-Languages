package main

// Weekly shift-scheduling logic for the employee scheduler.
//
// Rules enforced:
//   - An employee works at most one shift per day.
//   - An employee works at most MaxDaysPerWeek days in the week.
//   - Every shift, every day, must end up with at least MinPerShift
//     employees; employees who have not hit their weekly cap are randomly
//     assigned to under-staffed shifts.
//   - If an employee's preferred shift is full, the scheduler looks for
//     another open shift the same day, then carries the request over to
//     the next day, before finally leaving the employee off for that day.

import (
	"fmt"
	"math/rand"
	"strings"
)

type deferredRequest struct {
	employee    *Employee
	wantedShift string
}

// ScheduleResult holds the finished weekly grid, the roster (with each
// employee's per-day schedule filled in), and a log of every conflict or
// auto-assignment that happened while building the schedule.
type ScheduleResult struct {
	Grid   map[string]map[string][]string // day -> shift -> employee names
	Roster []*Employee
	Log    []string
}

func contains(values []string, target string) bool {
	for _, v := range values {
		if v == target {
			return true
		}
	}
	return false
}

func assign(e *Employee, day, shift string, grid map[string]map[string][]string,
	counts map[string]int, assignedToday map[string]bool, note string) {
	e.Schedule[day] = shift
	e.Notes[day] = note
	e.DaysWorked++
	counts[shift]++
	grid[day][shift] = append(grid[day][shift], e.Name)
	assignedToday[e.Name] = true
}

func RunSchedule(roster []*Employee, seed int64) *ScheduleResult {
	rng := rand.New(rand.NewSource(seed))

	grid := map[string]map[string][]string{}
	for _, day := range Days {
		grid[day] = map[string][]string{}
		for _, shift := range Shifts {
			grid[day][shift] = []string{}
		}
	}

	var log []string
	var deferred []deferredRequest

	for _, day := range Days {
		assignedToday := map[string]bool{}
		counts := map[string]int{}
		for _, shift := range Shifts {
			counts[shift] = 0
		}

		// Phase 0 - honor requests deferred from yesterday before anything else.
		carryOver := deferred
		deferred = nil
		for _, req := range carryOver {
			e := req.employee
			if e.DaysWorked >= MaxDaysPerWeek || e.RestDays[day] {
				log = append(log, fmt.Sprintf("%s: could not carry %s over from the prior day; stays off", day, e.Name))
				continue
			}
			if counts[req.wantedShift] < MaxPerShift {
				assign(e, day, req.wantedShift, grid, counts, assignedToday, "conflict resolved on next day")
				log = append(log, fmt.Sprintf("%s: %s's shift conflict from yesterday resolved into %s", day, e.Name, req.wantedShift))
			} else {
				log = append(log, fmt.Sprintf("%s: %s's carried-over request for %s is still full; stays off", day, e.Name, req.wantedShift))
			}
		}

		// Phase 1 - run everyone's ranked preference for today.
		for _, e := range roster {
			if assignedToday[e.Name] {
				continue
			}
			if e.RestDays[day] {
				continue
			}
			if e.DaysWorked >= MaxDaysPerWeek {
				continue
			}

			preferencesToday := e.Preferences[day]
			placed := false
			for _, shift := range preferencesToday {
				if counts[shift] < MaxPerShift {
					assign(e, day, shift, grid, counts, assignedToday, "preferred shift")
					placed = true
					break
				}
			}
			if placed {
				continue
			}

			// Conflict: every preferred shift is full today. Try any other open shift.
			for _, shift := range Shifts {
				if !contains(preferencesToday, shift) && counts[shift] < MaxPerShift {
					assign(e, day, shift, grid, counts, assignedToday, "reassigned (preferred shift full)")
					log = append(log, fmt.Sprintf("%s: %s's preferred shift was full; moved to %s the same day", day, e.Name, shift))
					placed = true
					break
				}
			}

			if !placed {
				deferred = append(deferred, deferredRequest{employee: e, wantedShift: preferencesToday[0]})
				log = append(log, fmt.Sprintf("%s: every shift is full for %s; deferring request to the next day", day, e.Name))
			}
		}

		// Phase 2 - top up any shift that is still below the minimum headcount.
		// Prefer employees who aren't on a designated rest day today, so filling
		// one day's gap doesn't burn a cap slot meant for a later day; only
		// reach into someone's rest day if there is truly no one else left.
		for _, shift := range Shifts {
			for counts[shift] < MinPerShift {
				candidates := eligibleCandidates(roster, assignedToday, day, true)
				if len(candidates) == 0 {
					candidates = eligibleCandidates(roster, assignedToday, day, false)
				}
				if len(candidates) == 0 {
					log = append(log, fmt.Sprintf("%s: WARNING - could not reach the %d-person minimum for %s", day, MinPerShift, shift))
					break
				}
				chosen := candidates[rng.Intn(len(candidates))]
				assign(chosen, day, shift, grid, counts, assignedToday, "auto-assigned to meet minimum staffing")
				log = append(log, fmt.Sprintf("%s: %s randomly assigned to %s to meet the minimum staffing rule", day, chosen.Name, shift))
			}
		}
	}

	return &ScheduleResult{Grid: grid, Roster: roster, Log: log}
}

func eligibleCandidates(roster []*Employee, assignedToday map[string]bool, day string, excludeRestDay bool) []*Employee {
	var candidates []*Employee
	for _, e := range roster {
		if assignedToday[e.Name] || e.DaysWorked >= MaxDaysPerWeek {
			continue
		}
		if excludeRestDay && e.RestDays[day] {
			continue
		}
		candidates = append(candidates, e)
	}
	return candidates
}

func FormatSchedule(result *ScheduleResult) string {
	var b strings.Builder

	b.WriteString("WEEKLY SHIFT SCHEDULE\n")
	b.WriteString(strings.Repeat("=", 60) + "\n")
	for _, day := range Days {
		b.WriteString("\n" + day + "\n")
		b.WriteString(strings.Repeat("-", len(day)) + "\n")
		for _, shift := range Shifts {
			names := result.Grid[day][shift]
			label := "(unfilled)"
			if len(names) > 0 {
				label = strings.Join(names, ", ")
			}
			b.WriteString(fmt.Sprintf("  %-10s: %s\n", shift, label))
		}
	}

	b.WriteString("\n" + strings.Repeat("=", 60) + "\n")
	b.WriteString("DAYS WORKED PER EMPLOYEE\n")
	b.WriteString(strings.Repeat("-", 60) + "\n")
	for _, e := range result.Roster {
		b.WriteString(fmt.Sprintf("  %-10s: %d day(s)\n", e.Name, e.DaysWorked))
	}

	b.WriteString("\n" + strings.Repeat("=", 60) + "\n")
	b.WriteString("SCHEDULING LOG (conflicts and auto-assignments)\n")
	b.WriteString(strings.Repeat("-", 60) + "\n")
	if len(result.Log) == 0 {
		b.WriteString("  (no conflicts; every preference was honored)\n")
	} else {
		for _, entry := range result.Log {
			b.WriteString("  - " + entry + "\n")
		}
	}

	return strings.TrimRight(b.String(), "\n")
}
