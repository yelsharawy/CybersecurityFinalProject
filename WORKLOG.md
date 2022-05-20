05/19/2022

Angela: Before this, we mainly tried researching and finding different resources for SHA-256. We found this website: https://blog.boot.dev/cryptography/how-sha-2-works-step-by-step-sha-256/ that gave us the basic steps and pseudocode for how it works. We're also working on delegating tasks and I'll look into code for rotating bits and xor-ing them. At home, I wrote up some code and then realized that the code I used wrote for this wasn't compatible with the structures that Yusuf was doing. I also haven't translated the code from python to Nim yet.

Yusuf: I started work on the pre-processing section of the SHA-256 algorithm. We also created each of the files we needed in the repo. At the CS Dojo, I continued by creating the chunk loop and started working on the `createMessageSchedule` function.
