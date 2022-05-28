#!/bin/env -S nim r
import std/[sugar, parseopt, tables]
import sha

when isMainModule:
    var
        chosenCfg = builtinConfigs["sha256"]
        givenFiles : seq[string]
    
    var p = initOptParser()
    while true:
        p.next()
        # dump (p.kind, p.key, p.val, p.remainingArgs)
        case p.kind
        of cmdEnd: break
        of cmdShortOption:
            case p.key
            of "a":
                chosenCfg = builtinConfigs[p.val]
            else:
                stdout.writeLine "unrecognized flag ", p.key
                quit QuitFailure
        of cmdLongOption:
            discard
        of cmdArgument:
            givenFiles &= p.key
    
    if givenFiles.len > 0:
        for filename in givenFiles:
            echo toString(chosenCfg.sha readFile filename), "  ", filename
    else:
        echo toString(chosenCfg.sha stdin.readAll), "  -"
    
