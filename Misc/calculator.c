#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {

    /*
    Author: Kay Patel
    Accept formatted data from the standard input using the standard library
    */
    int user_option;
    int num1;
    int num2;
    int result; 

    printf("Menu: \n");
    printf("1 - Addition\n2 - Subtraction\n3 - Multiplication\n4 - Division\n");
    printf("Selection an option from the menu: ");
    scanf("%d", &user_option);

    printf("Enter a number: ");
    scanf("%d", &num1);
    printf("Enter another number: ");
    scanf("%d", &num2);

    switch(user_option) {
        case 1: 
            result = num1 + num2;
            printf("The sum of %d and %d is %d\n", num1, num2, result);
        case 2: 
            result = num1 - num2;
            printf("The difference of %d and %d is %d\n", num1, num2, result);
        case 3:
            result = num1 * num2;
            printf("The product of %d and %d is %d\n", num1, num2, result);
        case 4: 
            //check num2
            if(num2 == 0) {
                printf("Zero Division Error\n");
                break;
            }
            result = num1 / num2;
            printf("%d divided by %d is %d\n", num1, num2, result);
    }

    return 0;
}