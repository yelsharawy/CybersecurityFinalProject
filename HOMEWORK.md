### Practice tasks:

*Note that these are optional guiding questions to practice using the tool* 

1. Run `echo -n 'hello world' | ./sha-ya` and compare it to the results of `echo -n 'hello world' | sha256sum` to confirm that to confirm that the program is working as intended. What is the output?
2. Repeat task 1 for sha224. What is the output? `Hint: try ./sha-ya --help`
3. What flags can be used to change the intial hash values (h0-h7) and the output length? Try using only those flags to make it work like SHA-224.

### Homework:

*Note this part is not optional*

4. Set the intial hash value to `0000000000000000000000000000000000000000000000000000000000000000`. What is the output?
5. Using the -w flag and wordlist.txt, find the password with the SHA-256 hash of `5edc50ed2b24e384cf04e0032f63bd9e6e95f5e7b122c0ddf38e2f7919ce0ea6`
   <details>
   <summary>Hint</summary>
   How can you filter the output to show only the hash you want? This isn't a feature given by our program, because there's an easy way to do it.
   </details>
6. Find the password with the SHA-224 hash of `e6da2f61bf439a85ea214cc5b4acd62948b907766305b22b83c9259d`.
7. With the initial hash as `2113e239ba69ff6219136d85516a850d8e715ae061a63f85b8c077bf52cd802d` and final length as 4, find the password with the hash of `f8106b4d8238ec18c3e146178ebc6ef6`
