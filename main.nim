#!/bin/env -S nim r
import std/[sugar, parseopt, tables, options]
import sha

when isMainModule:
    var
        # a `HashConfig` object that indicates the initial hash, round constants, and final length to use
        chosenCfg = builtinConfigs["sha256"]
        # list of strings to hash, together with labels for outputting with
        toHash : seq[tuple[data, label : string]]
    
    var p = initOptParser()
    
    # template 
    template getVal : untyped =
        if p.kind == cmdArgument: p.key
        elif p.val != "": p.val
        else:
            let flag = p.key
            p.next()
            if p.kind != cmdArgument:
                stderr.writeLine "expected argument for flag ".dup(addQuoted(flag))
                quit QuitFailure
            p.key
    
    while true:
        p.next()
        # dump (p.kind, p.key, p.val, p.remainingArgs)
        case p.kind
        of cmdEnd: break
        of cmdShortOption:
            case p.key
            of "a": # choose algorithm
                chosenCfg = builtinConfigs[getVal()]
            of "w": # add wordlist
                for hashStr in lines(getVal()):
                    toHash &= (hashStr, "".dup(addQuoted(hashStr)))
            of "": # just "-" given as an argument -- treat as stdin
                toHash &= (stdin.readAll, "-")
            else:
                stderr.writeLine "unrecognized flag ", p.key
                quit QuitFailure
        of cmdLongOption:
            stderr.writeLine "unrecognized flag ", p.key
            quit QuitFailure
        of cmdArgument:
            toHash &= (readFile(p.key), p.key)
    
    if toHash.len == 0:
        toHash &= (stdin.readAll, "-")
    
    for (data, label) in toHash:
        echo toString(chosenCfg.sha(data)), "  ", label
    
