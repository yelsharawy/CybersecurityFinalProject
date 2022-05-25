#!/bin/env -S nim r
import std/[os, strutils, endians, sugar]

type Hash = array[8, uint32]

proc `$`(a : Hash) : string =
    for x in a:
        result &= x.toHex 8

const roundConstants : array[64, uint32] = [
    0x428a2f98'u32, 0x71374491'u32, 0xb5c0fbcf'u32, 0xe9b5dba5'u32, 0x3956c25b'u32, 0x59f111f1'u32, 0x923f82a4'u32, 0xab1c5ed5'u32,
    0xd807aa98'u32, 0x12835b01'u32, 0x243185be'u32, 0x550c7dc3'u32, 0x72be5d74'u32, 0x80deb1fe'u32, 0x9bdc06a7'u32, 0xc19bf174'u32,
    0xe49b69c1'u32, 0xefbe4786'u32, 0x0fc19dc6'u32, 0x240ca1cc'u32, 0x2de92c6f'u32, 0x4a7484aa'u32, 0x5cb0a9dc'u32, 0x76f988da'u32,
    0x983e5152'u32, 0xa831c66d'u32, 0xb00327c8'u32, 0xbf597fc7'u32, 0xc6e00bf3'u32, 0xd5a79147'u32, 0x06ca6351'u32, 0x14292967'u32,
    0x27b70a85'u32, 0x2e1b2138'u32, 0x4d2c6dfc'u32, 0x53380d13'u32, 0x650a7354'u32, 0x766a0abb'u32, 0x81c2c92e'u32, 0x92722c85'u32,
    0xa2bfe8a1'u32, 0xa81a664b'u32, 0xc24b8b70'u32, 0xc76c51a3'u32, 0xd192e819'u32, 0xd6990624'u32, 0xf40e3585'u32, 0x106aa070'u32,
    0x19a4c116'u32, 0x1e376c08'u32, 0x2748774c'u32, 0x34b0bcb5'u32, 0x391c0cb3'u32, 0x4ed8aa4a'u32, 0x5b9cca4f'u32, 0x682e6ff3'u32,
    0x748f82ee'u32, 0x78a5636f'u32, 0x84c87814'u32, 0x8cc70208'u32, 0x90befffa'u32, 0xa4506ceb'u32, 0xbef9a3f7'u32, 0xc67178f2'u32
]

# "toString" for viewing data in binary
proc `$`[T : SomeInteger](s : seq[T]) : string =
    const valsPerLine = 8 div sizeof(T)
    result &= '\n'
    for i in countup(0, s.high, valsPerLine):
        for j in i..<min(s.len, i+valsPerLine):
            result &= (int s[j]).toBin sizeof(T)*8
            result &= " "
        result[^1] = '\n' # replace last space with newline
    result.setLen result.len-1 # trim off last newline

proc preprocess(data : var seq[byte]) =
    let # original length in bits
        bitLen = data.len.uint*8

    # add single 1 bit
    data &= 0b1000_0000
    # set length to closest multiple of 512 bits (64 bytes), minus 64 bits (8 bytes)
    data.setLen (((data.len+7) div 64)+1) * 64
    bigEndian64(addr data[^8], unsafeAddr bitLen)
    # for i in countdown(7, 0):
    #     data &= byte(bitLen shr (i*8))
    assert data.len mod 64 == 0

# yields every 512-bit (64-byte) chunk of `data`
iterator chunks(data : openArray[byte]) : seq[byte] =
    assert data.len mod 64 == 0
    for i in countup(0, data.high, 64):
        yield data[i..<i+64]

proc rightRotate(x : uint32, d: uint32) :uint32 =
    var first = x shr d
    var second = x shl (32 - d)
    return first or second

proc createMessageSchedule(data : openArray[byte]) : seq[uint32] =
    assert data.len == 64
    # Copy the input data from step 1 into a new array
    # where each entry is a 32-bit word
    # (It also says to add 48 words initialized to 0, but they will be overwritten anyway)
    result = newSeqUninitialized[uint32](64)
    var j : int
    for i in 0..<16:
        bigEndian32(addr result[i], unsafeAddr data[j])
        j += 4
    #[
        Modify the zero-ed indexes at the end of the array using the following algorithm:
        For i from w[16…63]:
            s0 = (w[i-15] rightrotate 7) xor (w[i-15] rightrotate 18) xor (w[i-15] rightshift 3)
            s1 = (w[i- 2] rightrotate 17) xor (w[i- 2] rightrotate 19) xor (w[i- 2] rightshift 10)
            w[i] = w[i-16] + s0 + w[i-7] + s1
    ]#
    for i in 16..63:
        let
            s0 = rightRotate(result[i-15], 7) xor rightRotate(result[i-15], 18) xor result[i-15] shr 3
            s1 = rightRotate(result[i-2], 17) xor rightRotate(result[i-2], 19) xor result[i-2] shr 10
        result[i] = result[i-16] + s0 + result[i-7] + s1

proc addCompressed(hash : var Hash; w : openArray[uint32]) =
    # Step 6 - Compression (& 7)
    # Initialize variables a, b, c, d, e, f, g, h and set them equal to the current hash values respectively.
    # here we're just using an array as a-h
    var hashVars = hash
    # Run the compression loop. The compression loop will mutate the values of a…h. The compression loop is as follows:
    for i in 0..63:
        let
            S1 = rightRotate(hashVars[4], 6) xor rightRotate(hashVars[4], 11) xor rightRotate(hashVars[4], 25)
            ch = (hashVars[4] and hashVars[5]) xor ((not hashVars[4]) and hashVars[6])
            temp1 = hashVars[7] + S1 + ch + roundConstants[i] + w[i]
            S0 = rightRotate(hashVars[0], 2) xor rightRotate(hashVars[0], 13) xor rightRotate(hashVars[0], 22)
            maj = (hashVars[0] and hashVars[1]) xor (hashVars[0] and hashVars[2]) xor (hashVars[1] and hashVars[2])
            temp2 = S0 + maj
        hashVars[7] = hashVars[6]
        hashVars[6] = hashVars[5]
        hashVars[5] = hashVars[4]
        hashVars[4] = hashVars[3] + temp1
        hashVars[3] = hashVars[2]
        hashVars[2] = hashVars[1]
        hashVars[1] = hashVars[0]
        hashVars[0] = temp1 + temp2
    
    # Step 7
    # After the compression loop, but still, within the chunk loop,
    # we modify the hash values by adding their respective variables to them, a-h.
    # As usual, all addition is modulo 2^32. (In Nim, just add, it will modulo by itself)
    for i, v in hash.mpairs:
        v += hashVars[i]

proc sha256(data : seq[byte]) : Hash =
    dump data
    # Step 1: Preprocess
    let padded = data.dup(preprocess)
    dump padded
    dump padded.len
    # Step 2: Initialize hash values
    result = [
        0x6a09e667'u32,
        0xbb67ae85'u32,
        0x3c6ef372'u32,
        0xa54ff53a'u32,
        0x510e527f'u32,
        0x9b05688c'u32,
        0x1f83d9ab'u32,
        0x5be0cd19'u32
    ]
    # Step 4: Chunk loop
    
    for chunk in padded.chunks:
        dump chunk
        var messageSchedule = createMessageSchedule(chunk)
        dump messageSchedule
        result.addCompressed(messageSchedule)
    

proc sha256(str : string) : Hash =
    var data : seq[byte]
    for c in str:
        data &= byte c
    result = sha256(data)


when isMainModule:
    var # read from first argument, or stdin if none given
        inputStr = if paramCount() >= 1: readFile(paramStr(1)) else: stdin.readAll
    
    dump sha256(inputStr)
    
