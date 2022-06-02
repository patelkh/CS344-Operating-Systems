base64enc - Base64 encode data and print to standard output

DESCRIPTION

  base64enc encode FILE, or standard input, to standard output.
  
  With no FILE, or when FILE is -, read standard input.
  
  Encoded lines wrap every 76 characters.
 
  The data are encoded as described in the standard base64 alphabet in RFC 4648 (Links to an external site.).

NOTES

  Source code must compile without errors against the c99 standard on os1 to receive ANY credit. Example:
  gcc -std=c99 -o base64enc base64enc.c

  Source code must compile without errors for FULL credit, with the following flags:
  gcc -std=c99 -Wall -Wextra -Wpedantic -Werror -o base64enc base64enc.c


Detailed instructions

In this assignment, you will practice writing a C program that performs a simple task: encoding a stream of data into base64 format. Base<N> formats are a way of converting binary data into ASCII text. Base<N> is widely used in web services to transmit binary data, such as cryptographic signatures, over plaintext content headers. It's also used the same way for email (ever seen -----BEGIN PGP PUBLIC KEY BLOCK------ in an email?).

The specification is provided above, along with the relevant RFC (Request for comment) that contains the base64 format specification. I want to point out that section 3.1 of the RFC states:

Implementations MUST NOT not add line feeds to base encoded data unless the specification referring to this document explicitly directs base encoders to add line feeds after a specific number of characters.
However, the specification above DOES explicitly direct you to add line feeds after 76 characters, so do not worry about this subsection of the RFC conflicting with the assignment.
 
Working with binary data safely and reliably

Because you will be working with binary data, you should use a fixed-width integer type. For example, if you used a generic `char` type, you might expect it to be 8 bits, but the C standard only sets minimum sizes of the primitive data types. Since we are working with bytes, you must use an array of `uint8_t` when reading from the binary input. The uintN_t types are optionally provided by the implementation (implementation means GCC here). It's a good practice to add some preprocessor checks to your code when using optionally defined types. Since the `UINT8_MAX` macro is defined if and only if the type is available, you can explicitly check for it as shown here:

#include <stdint.h> // typedef uint8_t
// Check that uint8_t type exists
#ifndef UINT8_MAX
#error "No support for uint8_t"
#endif
 
Base64 Alphabet

I am also providing the following snippet to populate your alphabet array. Recall from the C standards (Links to an external site.) that Translation Phase 6 concatenates string literals separated by whitespace. This is convenient for splitting a long string literal across several lines:

static char const alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                               "abcdefghijklmnopqrstuvwxyz"
                               "0123456789+/=";
We are declaring this variable as static (Links to an external site.) and const (Links to an external site.). By default, file-scope variables have external linkage, meaning they are added to the global namespace for linking. Marking the static attribute in this context restricts the variable to internal linkage, which restricts its visibility to the current file only. Likewise, the const specifier allows the compiler to place this array in read-only memory. This affects optimization, because the compiler knows it can replace an array lookup with an index known at compile-time with the corresponding value in that array, since it also does not change. It also affects the system as a whole to have variables like this in read only memory, because multiple running instances of the same program can actually share the same read only blocks, reducing resource usage!

Bitwise binary operators

To properly encode the data, you need to read in three bytes (8 bits * 3 = 24 bits) and then split this into four characters to print out. This requires some bit manipulation, and it's a little bit tricky. Refer to the following snippet for some assistance:

uint8_t in[3];
uint8_t out[4];

// Upper 6 bits of byte 0
out[0] = in[0] >> 2;
// Lower 2 bits of byte 0, shift left and or with the upper 4 bits of byte 1
out[1] = ((in[0] & 0x03) << 4) | (in[1] >> 4);
// Lower 4 bits of byte 1, shift left and or with ???
out[2] = ((in[1] & 0x0F) << 2) | ???
  // You do the rest.
Also, don't forget that this gives you the index of the output character which you then need to look up in the alphabet[] array.

Guidance

This program can be fairly short. I implemented it completely with error checking in less than 100 lines. I recommend breaking this up into several pieces and organizing your program with boilerplate before beginning. Refer to the C standards (Links to an external site.) regularly throughout the assignment. Refer to the man pages on os1 as well for system call specifications.

Start with the command line argument parsing. Check the number of args, and if there is one, check if it's not "-" (strcmp(3)), and if so, open the file. Make sure the open() succeeded! If there is no argument or the argument is "-", then use STDIN_FILENO as your file descriptor number for reading from.

Next focus on reading the file in blocks of three characters. You should be writing a for loop to handle reading three characters. Remember that read() is a request not a demand. Always use size_t to iterate over arrays, not int or some other inappropriate type.

You will ask read(2) for 3 bytes of data. It is not guaranteed to read 3 bytes, even if there are more than three bytes left, requiring you to check the return value and call it again until you have three bytes in your buffer.

Only when read returns 0 do you know that you are at the end of the input. If that's the case, then you need to process the 0, 1, 2, or 3 bytes that you were able to read in this round, and add the appropriate padding. I added the padding character '=' to the alphabet array, which is at index 64. This allows you to process the data as normal, and then set the results to 64 if they are supposed to be padding characters not data. A concise for loop, as an example:

for (i = 3; i > nread; i--) out[i] = 64;
The same goes for write(2) calls. Write tells you how many bytes were written. If you ask it to write 4 byes, and it returns 3, you are not done! You must have a loop that attempts to write the entire remaining array on each iteration. Here's a sample of a generic write loop, which is very similar to how you'd do a read loop as well:

for (size_t offset = 0; offset < sizeof buf;)
{
  ssize_t n = write(STDOUT_FILENO, offset + (char *) buf, sizeof buf - offset);
  if (n < 0) {
    ... ERROR ...
  }
  offset += n;
}
