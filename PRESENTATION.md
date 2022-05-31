# Introduction to SHA-256

SHA-256 is a cryptographic hash function part of the SHA-2 family that generates a unique 256-bit (32 byte) signature for any input text. SHA stands for Secure Hash Algorithm.

## What is hashing?

Hashing is a one-way process of scrambling raw information that cannot be reverse-engineered back to its original form. This function is called the hash function and we call the output a hash value/digest. On the other hand, encryption is a two-way process that can be decrypted into a readable form again.

![Hash diagram](https://www.simplilearn.com/ice9/free_resources_article_thumb/hashing1.PNG)

### Characteristics of the SHA-2 algorithm:

* Block cipher: The input is padded with a single 1 bit, then as many zeros as it takes to fit a multiple of 512-bit (64-byte) blocks. So a message of 10 characters would be extended to 64 bytes, and a message of 100 characters would be extended to 128 bytes.
  * The last 8 bytes of padding are used to store the message's length. In order to fit this format, the input message length cannot be more than 2^64 - 1 bits. Putting the length at the end, in combination with the single 1 bit of padding, promotes diffusion of otherwise indistinguishable messages (e.g. `"hello world"` vs `"hello world\00"`).
* Digest Length: The hash digest will always be a fixed length. SHA-256 generates a 256-bit hash (64 characters of hex), and SHA-224 generates a 224-bit hash (56 characters of hex).
  * SHA-224 generates a shorter hash, which is technically less secure, but the chances of a collision are already so low that, in some applications, it can be favorable to save those 4 bytes per hash.
  * SHA-512 also exists for longer input messages and a more secure hash. For a shorter hash on large data, SHA-384, or a family of "SHA-512/t" hashes can be used.

## Context on SHA applications

### History of SHA hash functions

The SHA family algorithm was originally created developed by the US National Security Agency (NSA) and published by the National Institute of Standards and Technology (NIST). Its first version, SHA-0, published in 1930, had a 160 bit digest length and 40 digit long has values. However, they found security issues with SHA-0 and developed SHA-1 which was also eventually found to have vulnerabilities.
* As a practical demonstration, Google engineers constructed a collision between two valid and visually similar PDF files: https://shattered.io

NSA, in collaboration with NIST (the National Institute of Science and Technology) designed SHA-2 to be more secure than SHA-1 by increasing collision resistance. A hash function is collision resistant if's difficult to find two inputs that hash to the same output (two inputs a and b s.t H(a) = H(b), where a ≠ b).

### Applications of Hashing

Applications include: 

Passwords: Most websites convert user passwords into a hash value before storing it. During login, the hash value is recalculated and compared with the one stores in the database. 

Image integrity: When a file is uploaded to a website, its hash is stored. When a user downloads the file, its hash is recalculated and compared to ensure data integrity.

## Review of terminology

From Mr. K's Cybersecurity website:
* **confusion** is the technique to ensure you do not give clues about the plain text in your ciphertext. This means we want the relationship between the ciphertext and the plaintext to be as complex as possible. Ceasar Cipher has poor confusion, while polyalphabetic cipers have better confusion, enigmacode has much better confusion.
* **diffusion** is the spreading of the statistical structure of the plaintext over the bulk of the ciphertext. This is done by transposing or permuting the data. This occurs in hashing when a small change modifies the entire result.

## Breakdown of Hash Algorithm
### Step 1: Initiate Hash Values and Round Constants

The algorithm works by taking in one chunk at a time and modifying the resulting hash based on it. For SHA-256, the hash starts as these 8 32-bit values, which come from the first 32 bits of the fractional parts of the square roots of the first 8 primes: 2, 3, 5, 7, 11, 13, 17, 19.

```
h0 := 0x6a09e667 
h1 := 0xbb67ae85
h2 := 0x3c6ef372
h3 := 0xa54ff53a
h4 := 0x510e527f
h5 := 0x9b05688c
h6 := 0x1f83d9ab
h7 := 0x5be0cd19
```

These 64 round constants, used for further confusion, represent the first 32 bits of the fractional parts of the cube roots of the first 64 primes from 2 to 311.

```
k =
0x428a2f98 0x71374491 0xb5c0fbcf 0xe9b5dba5 0x3956c25b 0x59f111f1 0x923f82a4 0xab1c5ed5
0xd807aa98 0x12835b01 0x243185be 0x550c7dc3 0x72be5d74 0x80deb1fe 0x9bdc06a7 0xc19bf174
0xe49b69c1 0xefbe4786 0x0fc19dc6 0x240ca1cc 0x2de92c6f 0x4a7484aa 0x5cb0a9dc 0x76f988da
0x983e5152 0xa831c66d 0xb00327c8 0xbf597fc7 0xc6e00bf3 0xd5a79147 0x06ca6351 0x14292967
0x27b70a85 0x2e1b2138 0x4d2c6dfc 0x53380d13 0x650a7354 0x766a0abb 0x81c2c92e 0x92722c85
0xa2bfe8a1 0xa81a664b 0xc24b8b70 0xc76c51a3 0xd192e819 0xd6990624 0xf40e3585 0x106aa070
0x19a4c116 0x1e376c08 0x2748774c 0x34b0bcb5 0x391c0cb3 0x4ed8aa4a 0x5b9cca4f 0x682e6ff3
0x748f82ee 0x78a5636f 0x84c87814 0x8cc70208 0x90befffa 0xa4506ceb 0xbef9a3f7 0xc67178f2
```

### Step 2: Pre-Processing

The message is first taken as binary and then padded by first appending a 1, followed by enough 0s until the message is 448 bits. The length of the message in bits, as a 64-bit word, is then added to the end, producing a message that is 512 bits long. This explains why the input message length should be maximum of 2^64 - 1 bits.  
As an example, we're using `"hello world"` (no newline or terminating null at the end) as our input message. Note the single `1` that marks the end of the message, and `01011000` (88 bits) at the end.
```
data =
01101000 01100101 01101100 01101100 01101111 00100000 01110111 01101111
01110010 01101100 01100100 10000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 01011000
```

### Step 3: Chunk Loop

Because this is a block cipher, the data must be split into 512-bit chunks to be processed one at a time. The remaining steps (besides the final one) are executed on each chunk.

### Step 4: Create Message Schedule

The chunk is copied into a new array where each entry is a big-endian 32-bit word, then 48 more 32-bit entries are added, initialized to zero. Now we have an array with indexes 0-63.

``` 
w =
01101000011001010110110001101100 01101111001000000111011101101111 
01110010011011000110010010000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000001011000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
... 
... 
00000000000000000000000000000000 00000000000000000000000000000000
```

We apply the following algorithm to replace the padded 0's. They rely on values 15, 7, and 2 words before it, for quick diffusion:
```
For i from w[16…63]:
    s0 = (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
    s1 = (w[i- 2] rightrotate 17) xor (w[i- 2] rightrotate 19) xor (w[i- 2] rightshift 10)
    w[i] = w[i-16] + s0 + w[i-7] + s1
```
``` 
w =
01101000011001010110110001101100 01101111001000000111011101101111 
01110010011011000110010010000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000 
00000000000000000000000000000000 00000000000000000000000000000000
00000000000000000000000000000000 00000000000000000000000000000000
00000000000000000000000000000000 00000000000000000000000001011000
00110111010001110000001000110111 10000110110100001100000000110001
11010011101111010001000100001011 01111000001111110100011110000010
00101010100100000111110011101101 01001011001011110111110011001001
00110001111000011001010001011101 10001001001101100100100101100100
01111111011110100000011011011010 11000001011110011010100100111010
... 
... 
00010001010000101111110110101101 10110000101100000001110111011001 
10011000111100001100001101101111 01110010000101111011100000011110
10100010110101000110011110011010 00000001000011111001100101111011
11111100000101110100111100001010 11000010110000101110101100010110
```

### Step 5: Compression

Now that we have a diffused message schedule, we need to change the hash in an irreversible way. Copies of the hash variables are defined as `a-h`, and are changed by each word in the message schedule, along with the round constants, through this process:
![Compression diagram](https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/SHA-2.svg/600px-SHA-2.svg.png)
Where:
* `S1 = (e rightrotate 6) xor (e rightrotate 11) xor (e rightrotate 25)`
* `ch = (e and f) xor ((not e) and g)`
* `maj = (a and b) xor (a and c) xor (b and c)`
* `S0 = (a rightrotate 2) xor (a rightrotate 13) xor (a rightrotate 22)`

The red boxes indicate addition. Note that it's not an easy task to reverse even one iteration, let alone all 64.

### Step 6: Modify Final Values

Now that `a-h` have been thoroughly modified, we modify `h0-h7` simply by adding corresponding variables:
```
h0 = h0 + a = 10111001010011010010011110111001
h1 = h1 + b = 10010011010011010011111000001000
h2 = h2 + c = 10100101001011100101001011010111
h3 = h3 + d = 11011010011111011010101111111010
h4 = h4 + e = 11000100100001001110111111100011
h5 = h5 + f = 01111010010100111000000011101110
h6 = h6 + g = 10010000100010001111011110101100
h7 = h7 + h = 11100010111011111100110111101001
```

### Step 7: Slap it all together

```
digest = h0 append h1 append h2 append h3 append h4 append h5 append h6 append h7
```

Resource:
* https://www.simplilearn.com/tutorials/cyber-security-tutorial/sha-256-algorithm
* https://brilliant.org/wiki/secure-hashing-algorithms/
* https://www.simplilearn.com/tutorials/cyber-security-tutorial/sha-256-algorithm
* https://blog.boot.dev/cryptography/how-sha-2-works-step-by-step-sha-256/
