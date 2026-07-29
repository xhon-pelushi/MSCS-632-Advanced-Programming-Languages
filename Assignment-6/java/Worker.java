import java.util.Optional;
import java.util.concurrent.Callable;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Worker that repeatedly pulls tasks from the shared queue, simulates
 * computational work with a delay, and writes results to the shared store.
 */
public class Worker implements Callable<Integer> {
    private static final Logger LOG = Logger.getLogger(Worker.class.getName());

    private final int workerId;
    private final TaskQueue queue;
    private final ResultStore results;
    private final long processingDelayMs;

    public Worker(int workerId, TaskQueue queue, ResultStore results, long processingDelayMs) {
        this.workerId = workerId;
        this.queue = queue;
        this.results = results;
        this.processingDelayMs = processingDelayMs;
    }

    @Override
    public Integer call() {
        String name = "Worker-" + workerId;
        Thread.currentThread().setName(name);
        LOG.info(name + " started");
        int processed = 0;

        try {
            while (true) {
                Optional<Task> maybeTask;
                try {
                    maybeTask = queue.getTask();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    LOG.log(Level.WARNING, name + " interrupted while waiting for a task", e);
                    break;
                }

                if (maybeTask.isEmpty()) {
                    LOG.info(name + " exiting: queue closed and empty");
                    break;
                }

                Task task = maybeTask.get();
                try {
                    Thread.sleep(processingDelayMs);
                    double fare = task.computeFare();
                    String line = String.format(
                            "%d,%s,%.1f,%d,%.2f,%s",
                            task.getTripId(),
                            task.getRiderName(),
                            task.getDistanceMiles(),
                            task.getDurationMinutes(),
                            fare,
                            name);
                    results.addResult(line);
                    processed++;
                    LOG.info(String.format(
                            "%s completed %s -> fare $%.2f", name, task, fare));
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    LOG.log(Level.WARNING, name + " interrupted while processing " + task, e);
                    break;
                } catch (RuntimeException e) {
                    LOG.log(Level.SEVERE, name + " error processing " + task, e);
                }
            }
        } finally {
            LOG.info(name + " finished; processed=" + processed);
        }
        return processed;
    }
}
