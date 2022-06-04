TITLE: Archive

INSTRUCTIONS:

Recursively store files and directories into a single archive file.
When at least one FILE is specified, create a new archive.
If FILE is a directory, add all of its contents to the archive file, recursively.
When no FILE argument is specified, unpack the ARCHIVE file. 

The archive format is in the form [(filename length):(filename)[children...](file size):(file contents)]....

For example, the file "testfile" which contains the text "hello world!\n", would be endcoded as:

8:testfile13:hello world!

A directory, "testdir" that contains testfile would then be encoded as:

8:testdir/8:testfile13:hello world!
0:

COMPILE: 

gcc -std=c99 -o archive archive.c (or)
gcc -std=c99 -Wall -Wextra -Wpedantic -Werror -o archive archive.c
