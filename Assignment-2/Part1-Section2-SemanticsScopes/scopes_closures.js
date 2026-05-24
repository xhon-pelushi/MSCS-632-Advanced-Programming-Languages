// JavaScript: Scopes and Closures
// Demonstrates var (function-scoped) vs let (block-scoped) and closure behavior.

// --- 1. var is function-scoped (not block-scoped) ---
function varScope() {
    for (var i = 0; i < 3; i++) {
        // i is hoisted to function scope
    }
    console.log("var i after loop:", i); // 3 — still accessible!
}
varScope();

// --- 2. let/const are block-scoped ---
function letScope() {
    for (let j = 0; j < 3; j++) {
        // j is confined to the for-block
    }
    try {
        console.log(j);
    } catch (e) {
        console.log("let j after loop: ReferenceError —", e.message);
    }
}
letScope();

// --- 3. Closure capturing enclosing scope ---
function makeAdder(n) {
    return function(value) {  // closes over n
        return value + n;
    };
}

const add5  = makeAdder(5);
const add10 = makeAdder(10);
console.log("\nadd5(3)  =", add5(3));   // 8
console.log("add10(3) =", add10(3));    // 13

// --- 4. Counter closure with mutable state ---
function counter() {
    let count = 0;
    return () => ++count;   // arrow function, implicit return
}

const c = counter();
console.log("\ncounter:", c(), c(), c()); // 1 2 3

// --- 5. var closure gotcha (same as Python late binding) ---
const varFuncs = [];
for (var k = 0; k < 3; k++) {
    varFuncs.push(() => k);          // all share same var k
}
console.log("\nvar loop closures:", varFuncs.map(f => f())); // [3,3,3]

// Fix: use let (each iteration gets its own binding)
const letFuncs = [];
for (let k = 0; k < 3; k++) {
    letFuncs.push(() => k);
}
console.log("let loop closures:", letFuncs.map(f => f()));   // [0,1,2]

// --- 6. Dynamic typing with implicit coercion ---
let val = 42;
console.log("\ntypeof val:", typeof val);       // number
val = "hello";
console.log("typeof val:", typeof val);         // string
console.log("'5' + 3 =", "5" + 3);             // "53" (string concat)
console.log("'5' - 3 =", "5" - 3);             // 2   (numeric coercion)
