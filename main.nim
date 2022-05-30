#!/bin/env -S nim r
import std/[sugar, parseopt, tables]
import sha

when isMainModule:
    var
        chosenCfg = builtinConfigs["sha256"]
        toHash : seq[tuple[data, label : string]]
    
    var p = initOptParser()
    while true:
        p.next()
        # dump (p.kind, p.key, p.val, p.remainingArgs)
        case p.kind
        of cmdEnd: break
        of cmdShortOption:
            case p.key
            of "a": # choose algorithm
                chosenCfg = builtinConfigs[p.val]
            of "w": # add wordlist
                for hashStr in lines(p.val):
                    toHash &= (hashStr, "".dup(addQuoted(hashStr)))
            of "": # just "-" given as an argument -- treat as stdin
                toHash &= (stdin.readAll, "-")
            else:
                stdout.writeLine "unrecognized flag ", p.key
                quit QuitFailure
        of cmdLongOption:
            discard
        of cmdArgument:
            toHash &= (readFile(p.key), p.key)
    
    if toHash.len == 0:
        toHash &= (stdin.readAll, "-")
    
    for (data, label) in toHash:
        echo toString(chosenCfg.sha(data)), "  ", label
    
