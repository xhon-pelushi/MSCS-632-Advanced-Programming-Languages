/**
 * A single ride-trip processing job pulled from the shared queue.
 */
public class Task {
    private final int tripId;
    private final String riderName;
    private final double distanceMiles;
    private final int durationMinutes;

    public Task(int tripId, String riderName, double distanceMiles, int durationMinutes) {
        this.tripId = tripId;
        this.riderName = riderName;
        this.distanceMiles = distanceMiles;
        this.durationMinutes = durationMinutes;
    }

    public int getTripId() {
        return tripId;
    }

    public String getRiderName() {
        return riderName;
    }

    public double getDistanceMiles() {
        return distanceMiles;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    /** Simulated fare: base + per-mile + per-minute. */
    public double computeFare() {
        return 2.50 + (distanceMiles * 1.75) + (durationMinutes * 0.35);
    }

    @Override
    public String toString() {
        return String.format(
                "Trip#%d [%s, %.1f mi, %d min]",
                tripId, riderName, distanceMiles, durationMinutes);
    }
}
