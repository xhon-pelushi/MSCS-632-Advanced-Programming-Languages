/*
 * Assignment 7 — Multi-Paradigm Problem Solving
 * C (Procedural): mean, median, and mode of a list of integers.
 *
 * A single translation unit with explicit functions, an array for storage,
 * and manual memory management for temporary working buffers.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* ---- Helpers ----------------------------------------------------------- */

static int compare_ints(const void *a, const void *b)
{
    int x = *(const int *)a;
    int y = *(const int *)b;
    return (x > y) - (x < y);
}

static int *copy_array(const int *data, int n)
{
    int *copy = malloc((size_t)n * sizeof(int));
    if (copy == NULL) {
        fprintf(stderr, "error: out of memory\n");
        exit(EXIT_FAILURE);
    }
    memcpy(copy, data, (size_t)n * sizeof(int));
    return copy;
}

/* ---- Statistics -------------------------------------------------------- */

/* Arithmetic mean of n integers. */
double calculate_mean(const int *data, int n)
{
    long sum = 0;
    int i;

    if (n <= 0) {
        return 0.0;
    }
    for (i = 0; i < n; i++) {
        sum += data[i];
    }
    return (double)sum / (double)n;
}

/*
 * Median of n integers. For an even count, returns the average of the two
 * middle values. Works on a sorted copy so the caller's array is unchanged.
 */
double calculate_median(const int *data, int n)
{
    int *sorted;
    double median;

    if (n <= 0) {
        return 0.0;
    }

    sorted = copy_array(data, n);
    qsort(sorted, (size_t)n, sizeof(int), compare_ints);

    if (n % 2 == 1) {
        median = (double)sorted[n / 2];
    } else {
        median = ((double)sorted[n / 2 - 1] + (double)sorted[n / 2]) / 2.0;
    }

    free(sorted);
    return median;
}

/*
 * Mode(s): every value that appears with the maximum frequency.
 * Writes up to max_modes values into modes_out and returns how many modes
 * were found. Allocates a temporary frequency table that is freed before return.
 */
int calculate_mode(const int *data, int n, int *modes_out, int max_modes)
{
    int *sorted;
    int i, count, best_count, mode_count, current;

    if (n <= 0 || max_modes <= 0) {
        return 0;
    }

    sorted = copy_array(data, n);
    qsort(sorted, (size_t)n, sizeof(int), compare_ints);

    /* First pass: find the highest frequency. */
    best_count = 1;
    count = 1;
    for (i = 1; i < n; i++) {
        if (sorted[i] == sorted[i - 1]) {
            count++;
            if (count > best_count) {
                best_count = count;
            }
        } else {
            count = 1;
        }
    }

    /* Second pass: collect every value that reaches best_count. */
    mode_count = 0;
    count = 1;
    current = sorted[0];
    for (i = 1; i <= n; i++) {
        if (i < n && sorted[i] == current) {
            count++;
        } else {
            if (count == best_count && mode_count < max_modes) {
                modes_out[mode_count++] = current;
            }
            if (i < n) {
                current = sorted[i];
                count = 1;
            }
        }
    }

    free(sorted);
    return mode_count;
}

/* ---- Demo driver ------------------------------------------------------- */

static void print_array(const int *data, int n)
{
    int i;
    printf("[");
    for (i = 0; i < n; i++) {
        printf("%d%s", data[i], (i + 1 < n) ? ", " : "");
    }
    printf("]");
}

int main(void)
{
    /* Sample data chosen so mean, median, and mode are all distinct. */
    int data[] = {4, 1, 2, 2, 3, 4, 4, 5};
    int n = (int)(sizeof(data) / sizeof(data[0]));
    int modes[16];
    int mode_count;
    int i;

    printf("=== C (Procedural) Statistics Calculator ===\n");
    printf("Input list: ");
    print_array(data, n);
    printf("\n");

    printf("Mean:   %.4f\n", calculate_mean(data, n));
    printf("Median: %.4f\n", calculate_median(data, n));

    mode_count = calculate_mode(data, n, modes, 16);
    printf("Mode:   ");
    for (i = 0; i < mode_count; i++) {
        printf("%d%s", modes[i], (i + 1 < mode_count) ? ", " : "");
    }
    printf(" (frequency peak)\n");

    return 0;
}
