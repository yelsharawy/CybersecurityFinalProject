# Introduction to SHA-256

SHA-256 is a cryptographic hash function part of the SHA-2 family that generates a unique 256-bit (32 byte) signature for any input text. SHA stands for Secure Hash Algorithm.

## What is hashing?

Hashing is a one-way process of scrambling raw information that cannot be reverse-engineered back to its original form. This function is called the hash function and we call the output a hash value/digest. On the other hand, encryption is a two-way process that can be decrypted into a readable form again.

<img src="https://www.simplilearn.com/ice9/free_resources_article_thumb/hashing1.PNG" width="780" height="500" />

### Characteristics of the SHA algorithm:

* Input message length: In order to make sure the algorithm is as random as possible, the input message length should be maximum of 2^64 - 1 bits.
* Digest Length: The hash digest will always be 256 bits in size. Bigger digests usually suggest significantly more costly and spacious calculations.
* Irreversible Digest: The hash function will not return any form of the original plaintext by any means and will also return the same output given the same input.

## Context on SHA applications

### History of SHA hash functions

The SHA family algorithm was originally created developed by the US National Security Agency (NSA) and published by the National Institute of Standards and Technology (NIST). Its first version SHA-0, published in 1930, had a 160 bit digest length and 40 digit long has values. However, SHA-0 was eventually cracked

### Applications of Hashing

## Breakdown of Hash Algorithm
Step 1: Initiate Hash Values and Round Constants

These 8 hash values are defined by the first 32 bits of the fractional parts of the square roots of the first 8 primes: 2, 3, 5, 7, 11, 13, 17, 19.

h0 := 0x6a09e667
h1 := 0xbb67ae85
h2 := 0x3c6ef372
h3 := 0xa54ff53a
h4 := 0x510e527f
h5 := 0x9b05688c
h6 := 0x1f83d9ab
h7 := 0x5be0cd19

These 64 round constants represent the first 32 bits of the fractional parts of the cube roots of the firsst 64 primes from 2 to 311.


k = [0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5 0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
0xd807aa98 0x12835b01 0x243185be 0x550c7dc3 0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc 0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7 0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13 0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3 0xd192e819 0xd6990624 0xf40e3585 0x106aa070
0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5 0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208 0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2]

Step 2: Pre-Processing

The message is first converted to binary and then padded by first appending a 1, followed by enough 0s until the message is 448 bits. The length of the message which is 64 bits is then added to the end, producing a message that is 512 bits long. This explains why the input message length should be maximum of 2^64 - 1 bits.

data =
01101000 01100101 01101100 01101100 01101111 00100000 01110111 01101111
01110010 01101100 01100100 10000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 01011000
Resource: https://www.simplilearn.com/tutorials/cyber-security-tutorial/sha-256-algorithm
