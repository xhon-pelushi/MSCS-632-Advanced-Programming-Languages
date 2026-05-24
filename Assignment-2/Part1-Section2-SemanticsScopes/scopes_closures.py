# Python: Scopes and Closures
# Demonstrates LEGB scope rule and closure behavior.

# --- 1. LEGB Scope rule ---
x = "global"

def outer():
    x = "enclosing"

    def inner():
        x = "local"
        print("inner  x:", x)    # local

    inner()
    print("outer  x:", x)        # enclosing

outer()
print("global x:", x)            # global

# --- 2. Closure: inner function captures enclosing variable ---
def make_adder(n):
    def adder(value):
        return value + n          # n is captured from enclosing scope
    return adder

add5  = make_adder(5)
add10 = make_adder(10)
print("\nadd5(3)  =", add5(3))   # 8
print("add10(3) =", add10(3))    # 13

# --- 3. Mutable state with nonlocal ---
def counter():
    count = 0
    def increment():
        nonlocal count            # must declare nonlocal to rebind
        count += 1
        return count
    return increment

c = counter()
print("\ncounter:", c(), c(), c())  # 1 2 3

# --- 4. Dynamic typing: same variable holds different types ---
var = 42
print("\ntype(var):", type(var))   # int
var = "hello"
print("type(var):", type(var))     # str
var = [1, 2, 3]
print("type(var):", type(var))     # list

# --- 5. Late binding in closures (common Python gotcha) ---
funcs = [lambda: i for i in range(3)]
# All three lambdas see the SAME 'i' (late binding)
print("\nLate binding:", [f() for f in funcs])  # [2, 2, 2]

# Fix: capture current value via default argument
funcs_fixed = [lambda i=i: i for i in range(3)]
print("Fixed binding:", [f() for f in funcs_fixed])  # [0, 1, 2]
