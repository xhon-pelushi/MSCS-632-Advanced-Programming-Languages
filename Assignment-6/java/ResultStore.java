import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Shared results list and output file, guarded by a ReentrantLock so
 * concurrent workers never corrupt the in-memory list or interleaved file lines.
 */
public class ResultStore implements AutoCloseable {
    private static final Logger LOG = Logger.getLogger(ResultStore.class.getName());

    private final List<String> results = new ArrayList<>();
    private final ReentrantLock lock = new ReentrantLock();
    private final BufferedWriter writer;
    private final Path outputPath;

    public ResultStore(Path outputPath) throws IOException {
        this.outputPath = outputPath;
        Files.createDirectories(outputPath.getParent() == null
                ? Path.of(".")
                : outputPath.getParent());
        this.writer = Files.newBufferedWriter(
                outputPath,
                StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING,
                StandardOpenOption.WRITE);
        writer.write("trip_id,rider,distance_mi,duration_min,fare_usd,worker");
        writer.newLine();
    }

    public void addResult(String line) {
        lock.lock();
        try {
            results.add(line);
            writer.write(line);
            writer.newLine();
            writer.flush();
        } catch (IOException e) {
            LOG.log(Level.SEVERE, "Failed to write result line: " + line, e);
        } finally {
            lock.unlock();
        }
    }

    public List<String> getResults() {
        lock.lock();
        try {
            return Collections.unmodifiableList(new ArrayList<>(results));
        } finally {
            lock.unlock();
        }
    }

    public Path getOutputPath() {
        return outputPath;
    }

    @Override
    public void close() {
        lock.lock();
        try {
            writer.close();
            LOG.info("Result file closed: " + outputPath.toAbsolutePath());
        } catch (IOException e) {
            LOG.log(Level.SEVERE, "Error closing result file", e);
        } finally {
            lock.unlock();
        }
    }
}
