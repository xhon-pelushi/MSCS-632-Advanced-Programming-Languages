// Rust: Ownership and Borrowing
// Rust guarantees memory safety at compile time with zero runtime overhead.
// There is no garbage collector — the compiler enforces strict ownership rules.

fn calculate_length(s: &String) -> usize {
    s.len()   // s is a reference; ownership stays with the caller
}

fn append_world(s: &mut String) {
    s.push_str(", world");
}

fn create_greeting() -> String {
    let s = String::from("Hello from Rust!");
    s   // ownership moves to the caller — no dangling pointer possible
}

fn main() {
    println!("=== 1. Ownership: Move Semantics ===");
    let s1 = String::from("hello");
    let s2 = s1;            // s1 is MOVED into s2; s1 is now invalid
    // println!("{}", s1);  // compile error: value borrowed after move
    println!("s2 (after move): {}", s2);

    println!("\n=== 2. Clone: Explicit Deep Copy ===");
    let s3 = String::from("world");
    let s4 = s3.clone();    // explicit heap copy; both remain valid
    println!("s3: {}  s4: {}", s3, s4);

    println!("\n=== 3. Immutable Borrowing ===");
    let s5 = String::from("borrow me");
    let len = calculate_length(&s5);   // lend without giving up ownership
    println!("'{}' has {} characters", s5, len);  // s5 still valid

    println!("\n=== 4. Mutable Borrowing ===");
    let mut s6 = String::from("hello");
    append_world(&mut s6);  // exactly one mutable reference at a time
    println!("After mutation: {}", s6);

    println!("\n=== 5. Stack vs Heap ===");
    {
        let stack_val: i32 = 42;            // stack — no heap allocation
        let heap_val  = Box::new(100_i32);  // explicit heap allocation
        println!("stack: {}  heap: {}", stack_val, *heap_val);
    } // both dropped automatically here; no manual free needed

    println!("\n=== 6. Safe Return (no dangling pointer) ===");
    let greeting = create_greeting();  // ownership transferred from function
    println!("{}", greeting);

    println!("\n=== 7. Slice References ===");
    let sentence = String::from("ownership is safe");
    let first_word = &sentence[..9];   // slice — borrowed view, no copy
    println!("First word: '{}'", first_word);
    // sentence.clear();  // compile error: cannot mutate while borrowed

    println!("\nAll memory freed automatically — no leaks, no dangling pointers.");
}
