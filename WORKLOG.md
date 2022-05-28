Worklog
=======
05/19/2022
----------

Angela: Before this, we mainly tried researching and finding different resources for SHA-256. We found this website: https://blog.boot.dev/cryptography/how-sha-2-works-step-by-step-sha-256/ that gave us the basic steps and pseudocode for how it works. We're also working on delegating tasks and I'll look into code for rotating bits and xor-ing them. At home, I wrote up some code and then realized that the code I used wrote for this wasn't compatible with the structures that Yusuf was doing. I also haven't translated the code from python to Nim yet.

Yusuf: I started work on the pre-processing section of the SHA-256 algorithm. We also created each of the files we needed in the repo. At the CS Dojo, I continued by creating the chunk loop and started working on the `createMessageSchedule` function.

05/20/2022
----------

We talked about why binary strings (i.e. `"00110000"`) shouldn't be used for bitwise or mathematical operations. We then implemented the `rightRotate` function and used it to finish the `createMessageSchedule` function. Angela also learned Nim syntax and caught up with Yusuf's code.

Yusuf: At home, I fixed syntax errors, then realized that our code was producing a different output from the guide. After a lot of investigating, and cleaning up code while I was at it, I realized that we had accidentally used `rightRotate` in two places where a simple right-shift was required. With that fixed, step 5 of the guide is truly complete.

05/22/2022
----------

Angela: I started looking how we could structure our presentation slides. I did an introduction summary to hashing functions and put a rudimentary outline of how I want the rest of the slides to look.

05/23/2022
----------

Yusuf: From home (because I was absent), I prepared the skeleton code for the last parts of the algorithm. I also helped Angela understand the significance of a collision method being found for a hash algorithm.

Angela: I researched history of SHA algorithms to provide some context in our presentation slides and finished the compression function by filling in Yusuf's skeleton code. 

05/24/2022
----------

We finished the algorithm and made sure it worked even with multiple chunks. We spent the period doing research on the reasoning behind the SHA-256 algorithm (which was not an easy question to answer). We also brainstormed ideas on how we could extend our tool, what kind of presentation we would give, and what homework we could assign to the students. Ideas that came up included "customization" with different constants, extending it into a hashcat-like program (only for SHA), and telling the students to brute force a hash using our own short password list.

05/25/2022
----------

We decided on what we wanted to do for our presentation & assignment. We also refactored the code to allow for multiple hashes to be executed (encapsulated function instead of globals), and troubleshooted `brew` and `nim` and Angela's laptop (I hate MacOS). 

05/26/2022
----------

Angela: I finished up most of the presentation including the "create message schedule" and the context section. Meanwhile, Yusuf strongly persuaded me to switch from Atom to VSCode.

Yusuf: I worked towards generalizing the hash algorithm to allow for SHA-224 and SHA-256, and eventually SHA-512 and SHA-384.

05/27/2022
----------

Yusuf: I started to split the code up into multiple files (to separate user interaction from the actual algorithm), and got a minimal CLI set up to choose a hash algorithm and provide a list of files to hash. I also brainstormed ways I could implement SHA-512-like hashes (of 64-bit words) without copying and pasting a bunch of code, while also keeping it readable.
