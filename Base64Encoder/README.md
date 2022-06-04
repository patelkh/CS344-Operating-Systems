TITLE: Base64 Encoder

BACKGROUND: 

The Base 64 encoding is designed to represent arbitrary sequences of octets in a form that allows the use of both upper- and lowercase letters but that need not be human readable.

A 65-character subset of US-ASCII is used, enabling 6 bits to be represented per printable character.  (The extra 65th character, "=", is used to signify a special processing function.)

The encoding process represents 24-bit groups of input bits as output strings of 4 encoded characters.  Proceeding from left to right, a 24-bit input group is formed by concatenating 3 8-bit input groups. These 24 bits are then treated as 4 concatenated 6-bit groups, each of which is translated into a single character in the base 64 alphabet.

Each 6-bit group is used as an index into an array of 64 printable characters.  The character referenced by the index is placed in the output string.

Special processing is performed if fewer than 24 bits are available at the end of the data being encoded.  A full encoding quantum is always completed at the end of a quantity.  When fewer than 24 input bits are available in an input group, bits with value zero are added (on the right) to form an integral number of 6-bit groups.  Padding at the end of the data is performed using the '=' character.

EXAMPLE:

Input: foobar
Output: Zm9vYmFy
where foo = Zm9v and bar = YmFy

INSTRUCTIONS: 

Write a C program that encodes a stream of data into base64 format. Base<N> formats are a way of converting binary data into ASCII text. Base<N> is widely used in web services to transmit binary data, such as cryptographic signatures, over plaintext content headers. It's also used the same way for email (ever seen -----BEGIN PGP PUBLIC KEY BLOCK------ in an email?).
Encoded lines wrap every 76 characters. 
With no FILE or when FILE is -, read from standard input. 
e.g., ./base64enc [optional: FILE or -]

Here is the Request for Comment (RFC) that contains the base64 format specification: https://datatracker.ietf.org/doc/html/rfc4648
  
I want to point out that section 3.1 of the RFC states:
Implementations MUST NOT not add line feeds to base encoded data unless the specification referring to this document explicitly directs base encoders to add line feeds after a specific number of characters.

However, the specification above DOES explicitly direct you to add line feeds after 76 characters, so do not worry about this subsection of the RFC conflicting with the assignment.
  
COMPILE:
	
gcc -std=c99 -o base64enc base64enc.c (or)
gcc -std=c99 -Wall -Wextra -Wpedantic -Werror -o base64enc base64enc.c
