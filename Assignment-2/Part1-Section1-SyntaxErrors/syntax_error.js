// JavaScript: Calculate the sum of an array — SYNTAX ERROR INTRODUCED
// Error: space inside the function call identifier on line 12
//        "calculate Sum" is two separate tokens; JS expects one identifier

function calculateSum(arr) {
    let total = 0;
    for (let num of arr) {
        total += num;
    }
    return total;
}

let numbers = [1, 2, 3, 4, 5];
let result = calculate Sum(numbers);   // <-- SyntaxError: Unexpected identifier 'Sum'
console.log("Sum in JavaScript:", result);
