# Assignment 6 — Multi-threaded Data Processing System

A ride-trip fare processor implemented independently in **Java** and **Go**.
Four workers pull trip tasks from a shared queue, simulate computational work,
and write fare results to a shared CSV file under proper synchronization.

## Design

- **Task** — trip ID, rider name, distance, duration; `computeFare()`.
- **Shared queue** — `addTask()` / `getTask()` with language-appropriate sync.
- **Workers (4)** — retrieve tasks, sleep briefly to simulate work, write results.
- **Result store** — mutex/lock-guarded in-memory list + CSV output file.
- **Logging** — worker start, task completion, errors, and clean shutdown.

## Java

Uses `ReentrantLock` + `Condition` for the queue, `Executors.newFixedThreadPool`
for workers, and try/catch for `InterruptedException` / `IOException`.

```bash
cd java
javac *.java
java DataProcessingSystem
```

## Go

Uses a buffered channel as the task queue, goroutines as workers, `sync.WaitGroup`
for join, `sync.Mutex` for the results file, and `defer` for cleanup.

```bash
cd go
go run .
```

## Repository

https://github.com/xhon-pelushi/MSCS-632-Advanced-Programming-Languages/tree/main/Assignment-6
