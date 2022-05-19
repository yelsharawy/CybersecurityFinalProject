#!/bin/env -S nim r
import std/[os, strutils]

# "toString" for viewing data in binary
proc `$`(s : seq[byte]) : string =
    const bytesPerLine = 8
    for i in countup(0, s.len-7, bytesPerLine):
        for j in i..<min(s.len, i+8):
            result &= (int s[j]).toBin(8)
            result &= " "
        result[^1] = '\n' # replace last space with newline
    # result.setLen result.len-1 # trim off last newline

proc preprocess(data : var seq[byte]) =
    let originalLength = data.len
    # add single 1 bit
    data &= 0b1000_0000
    # set length to closest multiple of 512 bits (64 bytes), minus 8
    data.setLen (((data.len+7) div 64)+1) * 64 - 8
    for i in countdown(7, 0):
        data &= byte(originalLength shr (i*8))
    assert data.len mod 64 == 0

when isMainModule:
    var # read from first argument, or stdin if none given
        inputStr = if paramCount() >= 1: readFile(paramStr(1)) else: stdin.readAll
        data : seq[byte]
    
    for c in inputStr:
        data &= byte c
    
    echo data
    preprocess(data)
    echo data
    echo data.len