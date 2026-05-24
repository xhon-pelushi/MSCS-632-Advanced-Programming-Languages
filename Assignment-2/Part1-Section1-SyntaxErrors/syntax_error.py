# Python: Calculate the sum of an array — SYNTAX ERROR INTRODUCED
# Error: missing colon at end of function definition (line 3)

def calculate_sum(arr)       # <-- SyntaxError: expected ':'
    total = 0
    for num in arr:
        total += num
    return total

numbers = [1, 2, 3, 4, 5]
result = calculate_sum(numbers)
print("Sum in Python:", result)
