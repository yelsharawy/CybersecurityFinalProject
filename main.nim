#!/bin/env -S nim r
import std/[sugar, parseopt, tables, options, strutils]
import sha

when isMainModule:
    var
        # a `HashConfig` object that indicates the initial hash, round constants, and final length to use
        chosenCfg = builtinConfigs["sha256"]
        # list of strings to hash, together with labels for outputting with
        toHash : seq[tuple[data, label : string]]
        # contains given hash, or nothing
        initialHash : Option[Hash]
        # contains given length, or nothing
        hashLength : Option[int]
    
    var p = initOptParser()
    
    # template to get value from option / next argument
    template getVal : string =
        case p.kind
        of cmdArgument: p.key
        elif p.val != "": p.val
        else:
            let flag = p.key
            p.next()
            if p.kind != cmdArgument:
                stderr.writeLine "expected argument for flag: ".dup(addQuoted(flag))
                quit QuitFailure
            p.key
    
    # each command is defined as a template
    # so we don't have to copy & paste the code in multiple places
    template setConfig =
        let val = getVal().replace("-","").normalize
        if val notin builtinConfigs:
            stderr.writeLine "unknown hash kind: ".dup(addQuoted(getVal()))
            quit QuitFailure
        chosenCfg = builtinConfigs[val]
    
    template addWordlist =
        for hashStr in lines(getVal()):
            toHash &= (hashStr, "".dup(addQuoted(hashStr)))
    
    template setInitialHash =
        if initialHash.isSome:
            stderr.writeLine "initial hash can only be given once"
            quit QuitFailure
        let val = getVal()
        for c in val:
            if c notin HexDigits:
                stderr.writeLine "initial hash must be given in hex; invalid char: ".dup(addQuoted(c))
                quit QuitFailure
        if val.len != 64:
            stderr.writeLine "initial hash must be 64 characters of hex"
            quit QuitFailure
        
        var givenHash : Hash
        for i in countup(0, val.high, 8):
            givenHash &= fromHex[uint32](val[i..<i+8])
        initialHash = some(givenHash)
    
    template setLength =
        if hashLength.isSome:
            stderr.writeLine "hash length can only be given once"
            quit QuitFailure
        try:
            hashLength = some(parseInt(getVal()))
            if hashLength.unsafeGet notin 1..8:
                stderr.writeLine "length must be between 1 and 8 inclusive"
                quit QuitFailure
        except ValueError:
            stderr.writeLine "invalid integer: ".dup(addQuoted(getVal()))
            quit QuitFailure
    
    template showHelp(quitCode = QuitSuccess) =
        stderr.write """
Usage: sha-ya [OPTION]... [FILE]...
Print or check SHA256 or SHA224 checksums.

With no FILE, or when FILE is -, read standard input.

  -a, --algo {sha224|sha256}    choose SHA algorithm to use
  -w, --wordlist <file>         hash each line of this file separately
  -i, --initial <hash>          set initial hash, as 64 characters of hex
  -l, --length <n>              set final hash length (1 <= n <= 8)
  -h, --help                    display this help and exit

The order of the options and arguments does not matter: `-i` and `-l` always take precedence over `-a`.

Note that SHA256 would be configured like so:
    --initial:6a09e667bb67ae853c6ef372a54ff53a510e527f9b05688c1f83d9ab5be0cd19
    --length:8
and SHA224 like so:
    --initial:c1059ed8367cd5073070dd17f70e5939ffc00b316858151164f98fa7befa4fa4
    --length:7
"""
        quit quitCode

    template unrecognizedFlag : untyped =
        stderr.writeLine "unknown option: ".dup(addQuoted(p.key))
        showHelp QuitFailure
    
    # argument parsing loop
    while true:
        p.next()
        # dump (p.kind, p.key, p.val, p.remainingArgs)
        case p.kind
        of cmdEnd: break
        of cmdShortOption:
            case p.key.normalize
            of "a": setConfig() 
            of "w": addWordlist()
            of "i": setInitialHash()
            of "l": setLength()
            of "": # just "-" given as an argument -- treat as stdin
                toHash &= (stdin.readAll, "-")
            of "h": showHelp()
            else:
                unrecognizedFlag()
        of cmdLongOption:
            case p.key.normalize
            of "algo": setConfig()
            of "wordlist": addWordlist()
            of "initial": setInitialHash()
            of "length": setLength()
            of "help": showHelp()
            else: unrecognizedFlag()
        of cmdArgument:
            toHash &= (readFile(p.key), p.key)
    
    # set initialHash & hashLength, if given
    if initialHash.isSome: chosenCfg.initialHash = initialHash.unsafeGet
    if hashLength.isSome: chosenCfg.hashLength = hashLength.unsafeGet
    
    if toHash.len == 0:
        toHash &= (stdin.readAll, "-")
    
    for (data, label) in toHash:
        echo toString(chosenCfg.sha(data)), "  ", label
    
