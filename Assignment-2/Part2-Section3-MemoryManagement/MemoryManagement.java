// Java: Garbage Collection
// Java uses a tracing garbage collector (GC). The programmer allocates objects
// with 'new' but never frees them — the JVM reclaims unreachable heap objects.

public class MemoryManagement {

    // A simple linked-list node to demonstrate heap allocation and GC.
    static class Node {
        int value;
        Node next;

        Node(int value) {
            this.value = value;
        }

        // finalize() is called by the GC just before reclaiming the object.
        @Override
        protected void finalize() {
            System.out.println("  GC collecting Node(" + value + ")");
        }
    }

    // --- 1. Basic heap allocation ---
    static void heapAllocationDemo() {
        System.out.println("=== 1. Heap Allocation ===");
        Node head = new Node(1);
        head.next  = new Node(2);
        head.next.next = new Node(3);

        System.out.print("Linked list: ");
        for (Node n = head; n != null; n = n.next) {
            System.out.print(n.value + " ");
        }
        System.out.println();

        head = null;  // entire list becomes unreachable → eligible for GC
        System.out.println("References cleared — nodes eligible for GC.");
    }

    // --- 2. Stack vs heap lifetime ---
    static void stackVsHeap() {
        System.out.println("\n=== 2. Stack vs Heap ===");
        int    stackVar = 42;          // primitive: allocated on the stack
        Integer heapVar = Integer.valueOf(999);  // object: allocated on heap

        System.out.println("Stack primitive: " + stackVar);
        System.out.println("Heap Integer:    " + heapVar);
        // stackVar and heapVar go out of scope here;
        // stackVar freed immediately; heapVar becomes GC-eligible.
    }

    // --- 3. Generating garbage to trigger GC ---
    static void gcPressureDemo() throws InterruptedException {
        System.out.println("\n=== 3. GC Pressure Demo ===");
        long before = Runtime.getRuntime().freeMemory();
        System.out.println("Free memory before: " + before / 1024 + " KB");

        for (int i = 0; i < 200_000; i++) {
            // Each iteration creates a short-lived string — immediate garbage.
            @SuppressWarnings("unused")
            String temp = "temporary_" + i;
        }

        System.gc();            // hint to run GC (JVM may ignore it)
        Thread.sleep(100);      // give GC a moment

        long after = Runtime.getRuntime().freeMemory();
        System.out.println("Free memory after GC: " + after / 1024 + " KB");
        System.out.println("GC reclaimed approx: " + (after - before) / 1024 + " KB");
    }

    // --- 4. No memory leaks for short-lived objects ---
    static void noLeakDemo() {
        System.out.println("\n=== 4. No Manual Free Needed ===");
        // Java cannot have dangling pointers — references are always valid
        // or null. Once set to null the object is reclaimed by GC.
        int[] arr = new int[1_000_000];
        arr[0] = 1;
        System.out.println("Allocated 1M-element array, arr[0]=" + arr[0]);
        arr = null;   // drop reference; memory returned to GC
        System.out.println("Reference dropped — GC will reclaim the array.");
    }

    public static void main(String[] args) throws InterruptedException {
        heapAllocationDemo();
        stackVsHeap();
        gcPressureDemo();
        noLeakDemo();

        System.gc();
        Thread.sleep(200);
        System.out.println("\nProgram complete — JVM GC managed all memory.");
    }
}
