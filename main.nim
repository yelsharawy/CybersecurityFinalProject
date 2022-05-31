#!/bin/env -S nim r
import std/[sugar, parseopt, tables, options, strutils]
import sha

when isMainModule:
    var
        # a `HashConfig` object that indicates the initial hash, round constants, and final length to use
        chosenCfg = builtinConfigs["sha256"]
        # list of strings to hash, together with labels for outputting with
        toHash : seq[tuple[data, label : string]]
    
    var p = initOptParser()
    
    # template to get value from option / next argument
    template getVal : untyped =
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
    template setConfig : untyped =
        if getVal() notin builtinConfigs:
            stderr.writeLine "unknown hash kind: ".dup(addQuoted(getVal()))
            quit QuitFailure
        chosenCfg = builtinConfigs[getVal()]
    
    template addWordlist : untyped =
        for hashStr in lines(getVal()):
            toHash &= (hashStr, "".dup(addQuoted(hashStr)))
    
    template showHelp(quitCode = QuitSuccess) : untyped =
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
"""
        quit quitCode

    template unrecognizedFlag : untyped =
        stderr.writeLine "unknown option: ".dup(addQuoted(p.key))
        showHelp QuitFailure
    
    while true:
        p.next()
        # dump (p.kind, p.key, p.val, p.remainingArgs)
        case p.kind
        of cmdEnd: break
        of cmdShortOption:
            case p.key.normalize
            of "a": setConfig() # choose algorithm
            of "w": addWordlist() # add wordlist
            of "": # just "-" given as an argument -- treat as stdin
                toHash &= (stdin.readAll, "-")
            of "h": showHelp()
            else:
                unrecognizedFlag()
        of cmdLongOption:
            case p.key.normalize
            of "algo": setConfig()
            of "wordlist": addWordlist()
            of "help": showHelp()
            else: unrecognizedFlag()
        of cmdArgument:
            toHash &= (readFile(p.key), p.key)
    
    if toHash.len == 0:
        toHash &= (stdin.readAll, "-")
    
    for (data, label) in toHash:
        echo toString(chosenCfg.sha(data)), "  ", label
    
