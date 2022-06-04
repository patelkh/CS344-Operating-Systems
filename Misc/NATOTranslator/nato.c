#include <stdio.h>
#include <ctype.h>

/* The NATO Translator Program */ 
int main() {
    const char *nato[] = {
        "Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot",
        "Golf", "Hotel", "India", "Juliett", "Kilo", "Lima",
        "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo",
        "Sierra", "Tango", "Uniform", "Victor", "Whiskey",
        "Xray", "Yankee", "Zulu"
    };
    char phrase[64];
    char ch;
    int i;
 
    //get word/phrase from standard input (stdin)
    printf("Enter a word or phrase: ");
    fgets(phrase,64,stdin);
 
    i = 0;
    while(phrase[i]) {
        ch = toupper(phrase[i]);
        //isalpha() checks if a character is an alphabet or not
        if(isalpha(ch)) {
            //ch=N=78
            //   A=65
            //   78-65=13
            //nato[13] = November
            printf("%s ",nato[ch-'A']);
            fflush(stdout);
        }
        i++;
        //if end of buffer, end loop
        if( i==64 )
            break;
    }
    putchar('\n');
    fflush(stdout);
 
    return(0);
}