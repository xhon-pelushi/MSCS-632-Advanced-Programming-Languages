// Console entry point: load the sample roster, build the week's schedule, print it.
package main

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"log"
)

//go:embed data/employees.json
var employeesJSON []byte

func main() {
	var raw []RawEmployee
	if err := json.Unmarshal(employeesJSON, &raw); err != nil {
		log.Fatalf("failed to parse embedded employee data: %v", err)
	}

	roster := BuildRoster(raw)
	result := RunSchedule(roster, 42)
	fmt.Println(FormatSchedule(result))
}
