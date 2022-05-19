#!/bin/env -S nim r
import os

func preprocess(data : var seq[byte]) =
    let originalLength = data.len
    # add single 1 bit
    data &= 0b1000_0000
    # set length to closest multiple of 512 bits (64 bytes), minus 8
    data.setLen (((data.len+8) div 64)+1) * 64 - 8
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