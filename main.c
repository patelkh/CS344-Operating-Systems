#include <stdio.h>
#include <stdlib.h> //Need for dynamic memory allocation
#include <string.h> //Needed to access string functions



//Structure for movie information 
struct movie {
    char *title;
    int year;
    char *language[100]; 
    double *ratingValue;
    struct movie *next;
};

//Parse the string which is comma delimited and create movie structure 
struct movie *createMovie(char *currLine) {
    //creates and initalizes currMovie pointer to 'movie' structure above 
    struct movie *currMovie = malloc(sizeof(struct movie));

    char *saveptr;
    //printf("%p\n", (void *)saveptr); //syntax for printing memory address the pointer points to 
    //int x = sizeof(currMovie);
    //printf("%d\n\n", x);

    char *token = strtok_r(currLine, ",", &saveptr); //strtok_r(string, delim, string pointer)
    //printf("%s\n", token);
    currMovie -> title = calloc(strlen(token)+1, sizeof(char)); //calloc(numItems, itemSize)
    strcpy(currMovie -> title, token); //strcpy(destination, string)
    //printf("%s \n", (*currMovie).title);

    token = strtok_r(NULL, ",", &saveptr);
    //printf("%s\n", token);
    //int num = atoi(token);
    //printf("%d\n", year);
    currMovie -> year = atoi(token);
    printf("%d\n", (*currMovie).year);
    

    // token = strtok_r(NULL, "\n", &saveptr);
    // currMovie -> ratingValue = calloc(1, sizeof(double));
    // strcpy(currMovie -> ratingValue, token);

    // currMovie -> next = NULL;
    return currMovie;
};

//Passing filePath as parameter 
//movieFile is a pointer to type file; allows communication between file and program
struct movie *processFile(char *filePath) {
    //Initialize the file pointer 
    FILE *movieFile = fopen(filePath, "r"); 
    
    char *currLine = NULL; //address of buffer containing the string/line 
    size_t len = 0; //allocated size 
    ssize_t nread; //number of characters read; while loop exits when this is -1
    char *token;
    int count = 0; //initialize count 
    
    struct movie *head = NULL;
    struct movie *tail = NULL;


    //getLine() reads an entire line from movieFile, storing the address of the buffer containing the text into *currLine; *currLine and len will be updated to reflect the buffer address and allocated size, respectively 
    //getLine() returns the number of characters read, which is stored in nread 
    while ((nread = getline(&currLine, &len, movieFile)) != -1) {
        if (count > 0) {
            struct movie *newNode = createMovie(currLine); //passing address of string as argument 

            if (head == NULL){
                head = newNode;
                tail = newNode;
            } 
            else {
                tail -> next = newNode;
                tail = newNode;
            }
            count += 1;
        } else {
            count += 1;
        }
    }
    free(currLine);
    fclose(movieFile);
    return 0;

};


//Reminders: user-entered file name is stored at argv[1]
int main(int argc, char *argv[]) {

    //If a file name is not provided, return failure 
    if (argc < 2) {
        printf("You must provide the name of the file to process e.g., movies movies_sample_1.txt.\n");
        exit(1);
    }; 

    //When your program starts it must read all data from the file and process it
    struct movie *list = processFile(argv[1]);
    return 0;

}