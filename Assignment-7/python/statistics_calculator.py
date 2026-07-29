#!/usr/bin/env python3
"""
Assignment 7 — Multi-Paradigm Problem Solving
Python (Object-Oriented): mean, median, and mode of a list of integers.

A StatisticsCalculator class encapsulates the data and exposes each
statistic as a method, using lists and dictionaries for storage.
"""

from __future__ import annotations

from collections import Counter
from typing import List


class StatisticsCalculator:
    """Object-oriented calculator for basic descriptive statistics."""

    def __init__(self, data: List[int]) -> None:
        if not isinstance(data, list):
            raise TypeError("data must be a list of integers")
        # Keep a defensive copy so callers cannot mutate our state.
        self._data: List[int] = list(data)

    @property
    def data(self) -> List[int]:
        """Return a copy of the stored integers."""
        return list(self._data)

    def mean(self) -> float:
        """Return the arithmetic average of the stored integers."""
        if not self._data:
            return 0.0
        return sum(self._data) / len(self._data)

    def median(self) -> float:
        """
        Return the middle value of the sorted data.
        For an even count, average the two central values.
        """
        if not self._data:
            return 0.0
        sorted_data = sorted(self._data)
        n = len(sorted_data)
        mid = n // 2
        if n % 2 == 1:
            return float(sorted_data[mid])
        return (sorted_data[mid - 1] + sorted_data[mid]) / 2.0

    def mode(self) -> List[int]:
        """
        Return the most frequently occurring integer(s).
        Uses a dictionary (via Counter) to tally frequencies.
        """
        if not self._data:
            return []
        counts = Counter(self._data)
        max_freq = max(counts.values())
        # Preserve ascending order for stable, readable output.
        return sorted(value for value, freq in counts.items() if freq == max_freq)

    def summary(self) -> str:
        """Return a multi-line summary of all three statistics."""
        modes = self.mode()
        mode_str = ", ".join(str(m) for m in modes)
        return (
            f"Input list: {self._data}\n"
            f"Mean:   {self.mean():.4f}\n"
            f"Median: {self.median():.4f}\n"
            f"Mode:   {mode_str} (frequency peak)"
        )


def main() -> None:
    # Sample data chosen so mean, median, and mode are all distinct.
    calc = StatisticsCalculator([4, 1, 2, 2, 3, 4, 4, 5])
    print("=== Python (Object-Oriented) Statistics Calculator ===")
    print(calc.summary())


if __name__ == "__main__":
    main()
