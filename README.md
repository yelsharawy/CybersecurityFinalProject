# CybersecurityFinalProject
Implementation of SHA-256, with guidance from [this page](https://blog.boot.dev/cryptography/how-sha-2-works-step-by-step-sha-256/).

```
Usage: sha-ya [OPTION]... [FILE]...
Print SHA256 or SHA224 checksums.

With no FILE, or when FILE is -, read standard input.

  -a, --algo {sha224|sha256}    choose SHA algorithm to use
  -w, --wordlist <file>         hash each line of this file separately
  -i, --initial <hash>          set initial hash, as 64 characters of hex
  -l, --length <n>              set final hash length (1 <= n <= 8)
  -h, --help                    display this help and exit

The order of the options and arguments does not matter: `--initial` and `--length` always take precedence over `--algo`.

Note that SHA256 would be configured like so:
    --initial:6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19
    --length:8
and SHA224 like so:
    --initial:c1059ed8367cd5073070dd17f70e5939ffc00b316858151164f98fa7befa4fa4
    --length:7
```