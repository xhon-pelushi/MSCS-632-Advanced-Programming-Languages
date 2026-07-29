import java.util.LinkedList;
import java.util.Optional;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;
import java.util.logging.Logger;

/**
 * Thread-safe shared task queue using ReentrantLock and a Condition.
 * Workers block on getTask() when the queue is empty until a task arrives
 * or the producer signals that no more tasks will be added.
 */
public class TaskQueue {
    private static final Logger LOG = Logger.getLogger(TaskQueue.class.getName());

    private final LinkedList<Task> queue = new LinkedList<>();
    private final ReentrantLock lock = new ReentrantLock();
    private final Condition notEmpty = lock.newCondition();
    private boolean closed = false;

    public void addTask(Task task) {
        lock.lock();
        try {
            if (closed) {
                throw new IllegalStateException("Cannot add tasks after the queue is closed");
            }
            queue.addLast(task);
            LOG.info("Enqueued " + task);
            notEmpty.signal();
        } finally {
            lock.unlock();
        }
    }

    /**
     * Blocks until a task is available, or returns empty if the queue is closed
     * and drained (safe worker termination signal).
     */
    public Optional<Task> getTask() throws InterruptedException {
        lock.lock();
        try {
            while (queue.isEmpty() && !closed) {
                notEmpty.await();
            }
            if (queue.isEmpty()) {
                return Optional.empty();
            }
            Task task = queue.removeFirst();
            LOG.info("Dequeued " + task);
            return Optional.of(task);
        } finally {
            lock.unlock();
        }
    }

    /** Mark the queue closed and wake all waiting workers so they can exit. */
    public void close() {
        lock.lock();
        try {
            closed = true;
            notEmpty.signalAll();
            LOG.info("Task queue closed; remaining size=" + queue.size());
        } finally {
            lock.unlock();
        }
    }

    public int size() {
        lock.lock();
        try {
            return queue.size();
        } finally {
            lock.unlock();
        }
    }
}
