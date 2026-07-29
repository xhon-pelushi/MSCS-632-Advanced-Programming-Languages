import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.logging.ConsoleHandler;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

/**
 * Multi-threaded ride-trip data processing system.
 * Producers enqueue trip tasks; a fixed pool of workers process them in parallel
 * and append results to a shared CSV file under lock protection.
 */
public class DataProcessingSystem {
    private static final Logger LOG = Logger.getLogger(DataProcessingSystem.class.getName());
    private static final int WORKER_COUNT = 4;
    private static final long PROCESSING_DELAY_MS = 80;

    public static void main(String[] args) {
        configureLogging();
        Path output = Path.of("results_java.csv");
        if (args.length > 0) {
            output = Path.of(args[0]);
        }

        TaskQueue queue = new TaskQueue();
        ExecutorService pool = Executors.newFixedThreadPool(WORKER_COUNT);
        List<Future<Integer>> futures = new ArrayList<>();

        try (ResultStore results = new ResultStore(output)) {
            LOG.info("Starting Java data processing system with " + WORKER_COUNT + " workers");

            for (int i = 1; i <= WORKER_COUNT; i++) {
                futures.add(pool.submit(new Worker(i, queue, results, PROCESSING_DELAY_MS)));
            }

            List<Task> sampleTrips = sampleTrips();
            for (Task task : sampleTrips) {
                queue.addTask(task);
            }
            LOG.info("Enqueued " + sampleTrips.size() + " trip tasks");
            queue.close();

            int total = 0;
            for (Future<Integer> future : futures) {
                try {
                    total += future.get();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    LOG.log(Level.SEVERE, "Main thread interrupted waiting for workers", e);
                } catch (ExecutionException e) {
                    LOG.log(Level.SEVERE, "Worker failed", e.getCause());
                }
            }

            LOG.info("All workers finished. Total trips processed=" + total
                    + ", results written=" + results.getResults().size());
            System.out.println();
            System.out.println("=== Java Multi-threaded Data Processing System ===");
            System.out.println("Workers: " + WORKER_COUNT);
            System.out.println("Trips submitted: " + sampleTrips.size());
            System.out.println("Trips processed: " + total);
            System.out.println("Results file: " + results.getOutputPath().toAbsolutePath());
            System.out.println("--- Results ---");
            for (String line : results.getResults()) {
                System.out.println(line);
            }
        } catch (IOException e) {
            LOG.log(Level.SEVERE, "Failed to open or write results file", e);
            System.err.println("Fatal I/O error: " + e.getMessage());
        } finally {
            pool.shutdown();
            try {
                if (!pool.awaitTermination(5, TimeUnit.SECONDS)) {
                    LOG.warning("Forcing executor shutdown");
                    pool.shutdownNow();
                }
            } catch (InterruptedException e) {
                pool.shutdownNow();
                Thread.currentThread().interrupt();
            }
            LOG.info("Executor shut down; system terminated safely");
        }
    }

    private static List<Task> sampleTrips() {
        return List.of(
                new Task(101, "Alice", 3.2, 12),
                new Task(102, "Bob", 8.5, 24),
                new Task(103, "Carla", 1.1, 6),
                new Task(104, "Diego", 12.0, 35),
                new Task(105, "Elena", 5.4, 18),
                new Task(106, "Farid", 2.0, 9),
                new Task(107, "Gina", 15.7, 42),
                new Task(108, "Hiro", 4.3, 15),
                new Task(109, "Ivy", 6.8, 21),
                new Task(110, "Jamal", 9.2, 28),
                new Task(111, "Kara", 0.8, 4),
                new Task(112, "Leo", 11.3, 31)
        );
    }

    private static void configureLogging() {
        Logger root = Logger.getLogger("");
        root.setLevel(Level.INFO);
        for (var handler : root.getHandlers()) {
            root.removeHandler(handler);
        }
        ConsoleHandler handler = new ConsoleHandler();
        handler.setLevel(Level.INFO);
        handler.setFormatter(new SimpleFormatter());
        root.addHandler(handler);
    }
}
