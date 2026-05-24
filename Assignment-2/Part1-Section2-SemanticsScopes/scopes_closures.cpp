// C++: Scopes and Closures via Lambdas
// C++ has block scope only; "closures" are lambdas with explicit capture lists.

#include <iostream>
#include <functional>
#include <memory>
#include <vector>
using namespace std;

// --- 1. Block scope ---
void blockScopeDemo() {
    int x = 10;
    {
        int x = 20;                 // shadows outer x in inner block
        cout << "inner x: " << x << endl;  // 20
    }
    cout << "outer x: " << x << endl;      // 10
}

// --- 2. Closure via lambda — capture by value [=] ---
function<int(int)> makeAdder(int n) {
    return [n](int value) {         // n captured by value at creation time
        return value + n;
    };
}

// --- 3. Mutable state — capture by reference [&] ---
function<int()> makeCounter() {
    int count = 0;
    // WARNING: captures count by ref — caller must keep count alive
    return [&count]() {
        return ++count;
    };
}

// --- 4. Self-contained counter using shared_ptr for safe ref capture ---
function<int()> safeCounter() {
    auto count = make_shared<int>(0);
    return [count]() {          // capture shared_ptr by value (ref-counted)
        return ++(*count);
    };
}

// --- 5. Static typing: compiler enforces types at compile time ---
void typingDemo() {
    int i = 42;
    // i = "hello";  // COMPILE ERROR — cannot assign string to int
    auto a = 3.14;  // auto deduces double
    cout << "\ntypeof a (auto): double, value = " << a << endl;
}

// --- 6. Loop closure: capture by value to avoid dangling reference ---
void loopClosureDemo() {
    vector<function<int()>> funcs;
    for (int k = 0; k < 3; k++) {
        funcs.push_back([k]() { return k; });  // [k] captures current k by value
    }
    cout << "\nLoop closures: ";
    for (auto& f : funcs) cout << f() << " ";  // 0 1 2 — correct
    cout << endl;
}

int main() {
    cout << "=== Block Scope ===" << endl;
    blockScopeDemo();

    cout << "\n=== Closures (Lambdas) ===" << endl;
    auto add5  = makeAdder(5);
    auto add10 = makeAdder(10);
    cout << "add5(3)  = " << add5(3)  << endl;  // 8
    cout << "add10(3) = " << add10(3) << endl;  // 13

    cout << "\n=== Safe Counter ===" << endl;
    auto c = safeCounter();
    cout << "counter: " << c() << " " << c() << " " << c() << endl; // 1 2 3

    typingDemo();
    loopClosureDemo();

    return 0;
}
