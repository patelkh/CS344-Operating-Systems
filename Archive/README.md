archive - pack and unpack archive files

DESCRIPTION

  Recursively store files and directories into a single archive file.
  
  When at least one FILE is specified, create a new archive.

  If FILE is a directory, add all of its contents to the archive file, recursively. 
  
  When no FILE argument is specified, unpack the ARCHIVE file.

NOTES

  Source code must compile without errors againt the c99 standard on os1 to receive ANY credit. Example:
  gcc -std=c99 -o archive archive.c

  Source code must compile without errors for FULL credit, with the following flags:
  gcc -std=c99 -Wall -Wextra -Wpedantic -Werror -o archive archive.c


Detailed instructions

In this assignment, you will write a program that parses files and directory structures to produce archive files that can then be unpacked to reproduce the archived files and directories.

Archive format

The archive format is in the form [(filename length):(filename)[children...](file size):(file contents)].... For example, the file "testfile" which contains the text "hello world!\n", would be endcoded as:

8:testfile13:hello world!

A directory, "testdir" that contains testfile would then be encoded as:
8:testdir/8:testfile13:hello world!
0:
 

The order in which entries appear does not matter, as long as the file structure is maintained. Directories are differentiated by ending in a trailing slash ("/") while files do not.

Guidance

This assignment is considerably more challenging than the previous assignment, so plan out your code carefully. You are not required to perform any error checking of archived file contents, and you may overwrite existing files during un-archiving (unpacking) without giving warning or prompting. However you should error-check function calls that could fail, like opening a file, writing, reading, etc, and not assume that command line arguments refer to existing files. Useful snippets are given below for you to use in your program.

I recommend that you begin by writing the algorithm to archive a single text file. Remember that the "%zu" format specifier can be used to write size_t variables (the value of sizeof) to a stream using printf. Never use a string variable as the format string, such as:

printf(filename)        BAD!
      vs 
printf("%s", filename)  GOOD!
 

Once you have a function that can encode a single file, add a for loop to your main function that loops over the FILE arguments and appends them to the ARCHIVE file one-by-one. This should not require any modification to your encoding algorithm; you're just appending more encoded files.

At this point, you are ready to encode directories. Add an if-block to your code to differentiate whether the current file is a directory or a regular file (you can ignore the possibility of other types of files). If the file is a directory, write its name to the archive file as normal, change the working directory to point to the directory in question, and then open the directory (which should now be "./") and iterate over its contents. Don't forget, you'll come across "." and ".." in the directory entries, so you'll want to check dirent.d_name for matches to "." or ".." and skip them to avoid infinite recursion. For each child, simply call your encoding function on it recursively. Once all children are exhausted, change back to the previous working directory. Write a zero to the archive to indicate the end of the encoding of that directory, and continue on with the next file(s) to process.

Once you can pack() directories and files recurisvely, it's time to write the unpacker. First, read the filename length, allocate a buffer to hold the filename, and read it in. If the filename ends in a "/", it is a directory and you should call mkpath to ensure that it exists, and then change the working directory to it. Then, continue on parsing the next files. Whenever you hit a filename length of zero, you know you're done with that directory, and can cd back to where you started from (go up a level in the directory structure). The output of your unpacking should be identical to the file(s) that went into the archive, including any empty directories, etc.

Be careful about using scanf and whitespace. We explicitly use a colon as a separator after numeric values instead of whitespace. Why? Imagine if the file contents started with a series of spaces; scanf would consume these after reaching the file size, and then we would end up not reading the file from the beginning. Not good! What if your file path has a space in it and you're using scanf? It will stop early and not return the full path. For this reason, you must use another function like fread, to read the specific number of bytes for the file path and file data. You will need to use a buffer and a loop to copy file contents data in and out of the archive.

You can find examples of archive files in this format in the /scratch/archive_examples directory on os1.
