TITLE: Base64 Encoder

INSTRUCTIONS: 
Write a C program that encodes a stream of data into base64 format. Base<N> formats are a way of converting binary data into ASCII text. Base<N> is widely used in web services to transmit binary data, such as cryptographic signatures, over plaintext content headers. It's also used the same way for email (ever seen -----BEGIN PGP PUBLIC KEY BLOCK------ in an email?).
Encoded lines wrap every 76 characters. 
With no FILE or when FILE is -, read from standard input. 
e.g., ./base64enc [optional: FILE or -]

Here is the Request for Comment that contains the base64 format specification:
RFC 4648: https://datatracker.ietf.org/doc/html/rfc4648
  
I want to point out that section 3.1 of the RFC states:
Implementations MUST NOT not add line feeds to base encoded data unless the specification referring to this document explicitly directs base encoders to add line feeds after a specific number of characters.

However, the specification above DOES explicitly direct you to add line feeds after 76 characters, so do not worry about this subsection of the RFC conflicting with the assignment.
  
NOTES

  Source code must compile without errors against the c99 standard on os1 to receive ANY credit. Example:
  gcc -std=c99 -o base64enc base64enc.c

  Source code must compile without errors for FULL credit, with the following flags:
  gcc -std=c99 -Wall -Wextra -Wpedantic -Werror -o base64enc base64enc.c
