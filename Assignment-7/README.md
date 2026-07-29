# Assignment 7 — Multi-Paradigm Problem Solving

Mean, median, and mode for a list of integers, implemented three ways:

| Language | Paradigm | Entry point |
|----------|----------|-------------|
| **C** | Procedural | [`c/statistics.c`](./c/statistics.c) |
| **OCaml** | Functional | [`ocaml/statistics.ml`](./ocaml/statistics.ml) |
| **Python** | Object-oriented | [`python/statistics_calculator.py`](./python/statistics_calculator.py) |

All three programs use the same sample input `[4, 1, 2, 2, 3, 4, 4, 5]` and produce matching results (mean 3.125, median 3.5, mode 4).

## Run

### C

```bash
cd c
gcc -Wall -Wextra -O2 -o statistics statistics.c
./statistics
```

### OCaml

```bash
cd ocaml
ocamlc -o statistics statistics.ml
./statistics
```

### Python

```bash
cd python
python3 statistics_calculator.py
```

## Design notes

- **C** — single file with `calculate_mean`, `calculate_median`, and `calculate_mode`; arrays plus `malloc`/`free` for temporary sorted copies.
- **OCaml** — immutable lists composed with `List.fold_left`, `List.map`, and `List.filter`; no mutable references.
- **Python** — `StatisticsCalculator` class with `mean()`, `median()`, and `mode()` methods; list + `Counter` dictionary for frequencies.
