package main

// Shared data model for the weekly employee shift scheduler.

var Days = []string{"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}
var Shifts = []string{"Morning", "Afternoon", "Evening"}

const (
	MaxDaysPerWeek = 5
	MinPerShift    = 2
	MaxPerShift    = 4
)

// RawEmployee mirrors the shape of data/employees.json.
type RawEmployee struct {
	Name        string              `json:"name"`
	Preferences map[string][]string `json:"preferences"`
}

// Employee tracks one worker's preferences plus the schedule built for them.
type Employee struct {
	Name        string
	Preferences map[string][]string // day -> 1-2 shifts, ranked by priority
	RestDays    map[string]bool     // two fixed days off for the week
	DaysWorked  int
	Schedule    map[string]string // day -> shift assigned
	Notes       map[string]string // day -> how the assignment happened
}

// RestDaysFor staggers two rest days per employee round-robin across the
// week so every day keeps enough of the roster available, instead of
// everyone exhausting their 5-day cap on the same early days.
func RestDaysFor(index int) map[string]bool {
	return map[string]bool{
		Days[(2*index)%7]:   true,
		Days[(2*index+1)%7]: true,
	}
}

func BuildRoster(raw []RawEmployee) []*Employee {
	roster := make([]*Employee, 0, len(raw))
	for index, r := range raw {
		roster = append(roster, &Employee{
			Name:        r.Name,
			Preferences: r.Preferences,
			RestDays:    RestDaysFor(index),
			Schedule:    map[string]string{},
			Notes:       map[string]string{},
		})
	}
	return roster
}
