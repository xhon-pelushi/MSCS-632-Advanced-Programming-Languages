// C++: Manual Memory Management
// C++ gives the programmer full control over allocation (new/new[]) and
// deallocation (delete/delete[]). Misuse causes leaks or dangling pointers.
// Modern C++ smart pointers largely eliminate these pitfalls.

#include <iostream>
#include <memory>
#include <vector>
using namespace std;

// --- 1. Raw pointers: manual new / delete ---
void rawPointerDemo() {
    cout << "=== 1. Raw Pointer (Manual Management) ===" << endl;

    int* p = new int(42);          // heap-allocate a single int
    cout << "Allocated: *p = " << *p << endl;
    delete p;                       // must manually free
    p = nullptr;                    // set to nullptr to prevent dangling use

    // Array allocation
    int* arr = new int[5]{10, 20, 30, 40, 50};
    cout << "Array: ";
    for (int i = 0; i < 5; i++) cout << arr[i] << " ";
    cout << endl;
    delete[] arr;                   // must use delete[] for arrays
    arr = nullptr;
    cout << "Raw memory freed." << endl;
}

// --- 2. Memory leak (intentional illustration — immediately fixed) ---
void memoryLeakDemo() {
    cout << "\n=== 2. Memory Leak Illustration ===" << endl;
    // int* leak = new int(999);
    // If we return here without 'delete leak', 999 is never freed.
    // That is a memory leak — the heap grows until the process exits.
    // Fix: always pair new with delete.
    int* safe = new int(999);
    cout << "Allocated: " << *safe << endl;
    delete safe;                    // leak prevented
    cout << "Memory freed — no leak." << endl;
}

// --- 3. Dangling pointer demonstration ---
void danglingPointerDemo() {
    cout << "\n=== 3. Dangling Pointer ===" << endl;
    int* p = new int(77);
    cout << "Before delete: " << *p << endl;
    delete p;
    p = nullptr;                    // critical: null after delete
    if (p == nullptr) {
        cout << "Pointer is null — safe to check before use." << endl;
    }
    // *p after delete without nullptr-ing = undefined behavior (crash / garbage).
}

// --- 4. unique_ptr: single ownership, automatic release ---
void uniquePtrDemo() {
    cout << "\n=== 4. unique_ptr (Single Ownership) ===" << endl;
    unique_ptr<int> uptr = make_unique<int>(200);
    cout << "unique_ptr value: " << *uptr << endl;
    // No delete needed — destructor called when uptr leaves scope.

    // Transfer ownership
    unique_ptr<int> uptr2 = move(uptr);
    // uptr is now empty; uptr2 owns the int
    cout << "After move, uptr2: " << *uptr2 << endl;
}   // uptr2 goes out of scope → memory freed

// --- 5. shared_ptr: reference-counted shared ownership ---
void sharedPtrDemo() {
    cout << "\n=== 5. shared_ptr (Shared Ownership) ===" << endl;
    shared_ptr<int> sptr1 = make_shared<int>(300);
    cout << "ref count: " << sptr1.use_count() << endl;  // 1
    {
        shared_ptr<int> sptr2 = sptr1;   // ref count → 2
        cout << "ref count inside block: " << sptr1.use_count() << endl; // 2
    }   // sptr2 destroyed → ref count → 1
    cout << "ref count after block: " << sptr1.use_count() << endl;  // 1
}   // sptr1 destroyed → ref count → 0 → memory freed

// --- 6. Stack allocation: no heap, no manual management ---
void stackDemo() {
    cout << "\n=== 6. Stack Allocation ===" << endl;
    int arr[5] = {1, 2, 3, 4, 5};   // stack memory; freed when scope ends
    cout << "Stack array: ";
    for (int x : arr) cout << x << " ";
    cout << endl;
}   // arr freed here automatically

int main() {
    rawPointerDemo();
    memoryLeakDemo();
    danglingPointerDemo();
    uniquePtrDemo();
    sharedPtrDemo();
    stackDemo();
    cout << "\nAll heap memory properly released." << endl;
    return 0;
}
