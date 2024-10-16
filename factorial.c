#include <stdio.h>

int main() {
    printf("Hello from Factorial!\n");
    int number = 10;
    int total = 1;
    for (int i=0; i < number; i++) {
        total = total * (i + 1);
    }
    printf("%d factorial is %d\n",number,total);
    return 0;
}
