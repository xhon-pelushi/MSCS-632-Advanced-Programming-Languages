// C++: Calculate the sum of an array — SYNTAX ERROR INTRODUCED
// Error: missing semicolon after variable declaration on line 9
//        g++ reports: error: expected ';' before 'for'

#include <iostream>
using namespace std;

int calculateSum(int arr[], int size) {
    int total = 0      // <-- error: expected ';' before 'for'
    for (int i = 0; i < size; i++) {
        total += arr[i];
    }
    return total;
}

int main() {
    int numbers[] = {1, 2, 3, 4, 5};
    int size = sizeof(numbers) / sizeof(numbers[0]);
    int result = calculateSum(numbers, size);
    cout << "Sum in C++: " << result << endl;
    return 0;
}
