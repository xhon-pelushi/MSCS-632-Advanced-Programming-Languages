// Multi-threaded (multi-goroutine) ride-trip data processing system.
// Channels serve as the concurrency-safe task queue; a mutex guards the
// shared results slice and output file writer.
package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"math"
	"os"
	"sync"
	"time"
)

const (
	workerCount        = 4
	processingDelay    = 80 * time.Millisecond
	defaultResultsFile = "results_go.csv"
)

// Task is a single ride-trip processing job.
type Task struct {
	TripID          int
	RiderName       string
	DistanceMiles   float64
	DurationMinutes int
}

func (t Task) String() string {
	return fmt.Sprintf("Trip#%d [%s, %.1f mi, %d min]",
		t.TripID, t.RiderName, t.DistanceMiles, t.DurationMinutes)
}

func (t Task) ComputeFare() float64 {
	raw := 2.50 + (t.DistanceMiles * 1.75) + (float64(t.DurationMinutes) * 0.35)
	return math.Round(raw*100) / 100
}

// ResultStore is a mutex-protected shared results list + CSV file.
type ResultStore struct {
	mu      sync.Mutex
	results [][]string
	file    *os.File
	writer  *csv.Writer
	path    string
}

func NewResultStore(path string) (*ResultStore, error) {
	f, err := os.Create(path)
	if err != nil {
		return nil, fmt.Errorf("create results file: %w", err)
	}
	w := csv.NewWriter(f)
	header := []string{"trip_id", "rider", "distance_mi", "duration_min", "fare_usd", "worker"}
	if err := w.Write(header); err != nil {
		f.Close()
		return nil, fmt.Errorf("write CSV header: %w", err)
	}
	w.Flush()
	if err := w.Error(); err != nil {
		f.Close()
		return nil, fmt.Errorf("flush CSV header: %w", err)
	}
	return &ResultStore{file: f, writer: w, path: path}, nil
}

func (r *ResultStore) Add(row []string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.results = append(r.results, row)
	if err := r.writer.Write(row); err != nil {
		return fmt.Errorf("write result row: %w", err)
	}
	r.writer.Flush()
	if err := r.writer.Error(); err != nil {
		return fmt.Errorf("flush result row: %w", err)
	}
	return nil
}

func (r *ResultStore) Results() [][]string {
	r.mu.Lock()
	defer r.mu.Unlock()
	out := make([][]string, len(r.results))
	copy(out, r.results)
	return out
}

func (r *ResultStore) Path() string {
	return r.path
}

func (r *ResultStore) Close() error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.writer.Flush()
	errFlush := r.writer.Error()
	errClose := r.file.Close()
	if errFlush != nil {
		return errFlush
	}
	return errClose
}

func worker(id int, tasks <-chan Task, results *ResultStore, wg *sync.WaitGroup) {
	defer wg.Done()
	name := fmt.Sprintf("Worker-%d", id)
	log.Printf("%s started", name)
	processed := 0

	for task := range tasks {
		time.Sleep(processingDelay)
		fare := task.ComputeFare()
		row := []string{
			fmt.Sprintf("%d", task.TripID),
			task.RiderName,
			fmt.Sprintf("%.1f", task.DistanceMiles),
			fmt.Sprintf("%d", task.DurationMinutes),
			fmt.Sprintf("%.2f", fare),
			name,
		}
		if err := results.Add(row); err != nil {
			log.Printf("%s error writing result for %s: %v", name, task, err)
			continue
		}
		processed++
		log.Printf("%s completed %s -> fare $%.2f", name, task, fare)
	}

	log.Printf("%s finished; processed=%d", name, processed)
}

func sampleTrips() []Task {
	return []Task{
		{101, "Alice", 3.2, 12},
		{102, "Bob", 8.5, 24},
		{103, "Carla", 1.1, 6},
		{104, "Diego", 12.0, 35},
		{105, "Elena", 5.4, 18},
		{106, "Farid", 2.0, 9},
		{107, "Gina", 15.7, 42},
		{108, "Hiro", 4.3, 15},
		{109, "Ivy", 6.8, 21},
		{110, "Jamal", 9.2, 28},
		{111, "Kara", 0.8, 4},
		{112, "Leo", 11.3, 31},
	}
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	log.SetPrefix("")

	outPath := defaultResultsFile
	if len(os.Args) > 1 {
		outPath = os.Args[1]
	}

	results, err := NewResultStore(outPath)
	if err != nil {
		log.Fatalf("Fatal: could not open results store: %v", err)
	}
	defer func() {
		if cerr := results.Close(); cerr != nil {
			log.Printf("Error closing results file: %v", cerr)
		} else {
			log.Printf("Result file closed: %s", results.Path())
		}
	}()

	// Buffered channel acts as the shared, concurrency-safe task queue.
	tasks := make(chan Task, 16)

	var wg sync.WaitGroup
	log.Printf("Starting Go data processing system with %d workers", workerCount)
	for i := 1; i <= workerCount; i++ {
		wg.Add(1)
		go worker(i, tasks, results, &wg)
	}

	trips := sampleTrips()
	for _, t := range trips {
		log.Printf("Enqueued %s", t)
		tasks <- t
	}
	log.Printf("Enqueued %d trip tasks", len(trips))
	close(tasks) // safe termination: workers exit when channel drains

	wg.Wait()
	rows := results.Results()
	log.Printf("All workers finished. Results written=%d", len(rows))

	fmt.Println()
	fmt.Println("=== Go Multi-threaded Data Processing System ===")
	fmt.Printf("Workers: %d\n", workerCount)
	fmt.Printf("Trips submitted: %d\n", len(trips))
	fmt.Printf("Trips processed: %d\n", len(rows))
	fmt.Printf("Results file: %s\n", results.Path())
	fmt.Println("--- Results ---")
	for _, row := range rows {
		fmt.Println(joinCSV(row))
	}
}

func joinCSV(row []string) string {
	out := ""
	for i, col := range row {
		if i > 0 {
			out += ","
		}
		out += col
	}
	return out
}
