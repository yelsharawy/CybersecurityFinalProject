#!/bin/env -S nim r
import std/[os, strutils, endians, tables, sugar, typetraits]

when not defined(debug):
    template dump(x : untyped) = discard

type
    # defines the HashConfig type as an object with these fields
    HashConfig* {.byref.} = object
        # support for SHA-512 or 384 has been scrapped for technical complications
        # chunkSize* : int # size of each chunk
        # numIterations* : int # number of iterations in compression
        initialHash* : Hash
        hashLength* : int # crops length of output to this many words
        roundConstants* : ptr UncheckedArray[uint32] # should have same length as `numIterations`
    # defines a Hash as a list of 32-bit unsigned integers
    Hash* = seq[uint32]
    # "Nim thing" -- just ignore this:
    Strict*[T] = concept type T2 of T
        T.name == T2.name

# for printing hash as hex
proc toString*(a : Strict[Hash]) : string =
    for x in a:
        result &= x.toHex 8
    result = result.toLowerAscii

# for viewing data in binary
proc toString*[T : SomeInteger](s : seq[T] and not Strict[Hash]) : string =
    const valsPerLine = 8 div sizeof(T)
    result &= '\n'
    for i in countup(0, s.high, valsPerLine):
        for j in i..<min(s.len, i+valsPerLine):
            result &= (int s[j]).toBin sizeof(T)*8
            result &= " "
        result[^1] = '\n' # replace last space with newline
    result.setLen result.len-1 # trim off last newline

# to override default `$` operator (Nim's "toString")
template `$`*[T : SomeInteger](s : seq[T]) : string = s.toString

# used by SHA-256 and SHA-224
const sha256roundConstants : array[64, uint32] = [
    0x428a2f98'u32, 0x71374491'u32, 0xb5c0fbcf'u32, 0xe9b5dba5'u32, 0x3956c25b'u32, 0x59f111f1'u32, 0x923f82a4'u32, 0xab1c5ed5'u32,
    0xd807aa98'u32, 0x12835b01'u32, 0x243185be'u32, 0x550c7dc3'u32, 0x72be5d74'u32, 0x80deb1fe'u32, 0x9bdc06a7'u32, 0xc19bf174'u32,
    0xe49b69c1'u32, 0xefbe4786'u32, 0x0fc19dc6'u32, 0x240ca1cc'u32, 0x2de92c6f'u32, 0x4a7484aa'u32, 0x5cb0a9dc'u32, 0x76f988da'u32,
    0x983e5152'u32, 0xa831c66d'u32, 0xb00327c8'u32, 0xbf597fc7'u32, 0xc6e00bf3'u32, 0xd5a79147'u32, 0x06ca6351'u32, 0x14292967'u32,
    0x27b70a85'u32, 0x2e1b2138'u32, 0x4d2c6dfc'u32, 0x53380d13'u32, 0x650a7354'u32, 0x766a0abb'u32, 0x81c2c92e'u32, 0x92722c85'u32,
    0xa2bfe8a1'u32, 0xa81a664b'u32, 0xc24b8b70'u32, 0xc76c51a3'u32, 0xd192e819'u32, 0xd6990624'u32, 0xf40e3585'u32, 0x106aa070'u32,
    0x19a4c116'u32, 0x1e376c08'u32, 0x2748774c'u32, 0x34b0bcb5'u32, 0x391c0cb3'u32, 0x4ed8aa4a'u32, 0x5b9cca4f'u32, 0x682e6ff3'u32,
    0x748f82ee'u32, 0x78a5636f'u32, 0x84c87814'u32, 0x8cc70208'u32, 0x90befffa'u32, 0xa4506ceb'u32, 0xbef9a3f7'u32, 0xc67178f2'u32
]

# const sha512roundConstants : array[80, uint64] = [
#     0x428a2f98d728ae22'u64, 0x7137449123ef65cd'u64, 0xb5c0fbcfec4d3b2f'u64, 0xe9b5dba58189dbbc'u64, 0x3956c25bf348b538'u64, 
#     0x59f111f1b605d019'u64, 0x923f82a4af194f9b'u64, 0xab1c5ed5da6d8118'u64, 0xd807aa98a3030242'u64, 0x12835b0145706fbe'u64, 
#     0x243185be4ee4b28c'u64, 0x550c7dc3d5ffb4e2'u64, 0x72be5d74f27b896f'u64, 0x80deb1fe3b1696b1'u64, 0x9bdc06a725c71235'u64, 
#     0xc19bf174cf692694'u64, 0xe49b69c19ef14ad2'u64, 0xefbe4786384f25e3'u64, 0x0fc19dc68b8cd5b5'u64, 0x240ca1cc77ac9c65'u64, 
#     0x2de92c6f592b0275'u64, 0x4a7484aa6ea6e483'u64, 0x5cb0a9dcbd41fbd4'u64, 0x76f988da831153b5'u64, 0x983e5152ee66dfab'u64, 
#     0xa831c66d2db43210'u64, 0xb00327c898fb213f'u64, 0xbf597fc7beef0ee4'u64, 0xc6e00bf33da88fc2'u64, 0xd5a79147930aa725'u64, 
#     0x06ca6351e003826f'u64, 0x142929670a0e6e70'u64, 0x27b70a8546d22ffc'u64, 0x2e1b21385c26c926'u64, 0x4d2c6dfc5ac42aed'u64, 
#     0x53380d139d95b3df'u64, 0x650a73548baf63de'u64, 0x766a0abb3c77b2a8'u64, 0x81c2c92e47edaee6'u64, 0x92722c851482353b'u64, 
#     0xa2bfe8a14cf10364'u64, 0xa81a664bbc423001'u64, 0xc24b8b70d0f89791'u64, 0xc76c51a30654be30'u64, 0xd192e819d6ef5218'u64, 
#     0xd69906245565a910'u64, 0xf40e35855771202a'u64, 0x106aa07032bbd1b8'u64, 0x19a4c116b8d2d0c8'u64, 0x1e376c085141ab53'u64, 
#     0x2748774cdf8eeb99'u64, 0x34b0bcb5e19b48a8'u64, 0x391c0cb3c5c95a63'u64, 0x4ed8aa4ae3418acb'u64, 0x5b9cca4f7763e373'u64, 
#     0x682e6ff3d6b2b8a3'u64, 0x748f82ee5defb2fc'u64, 0x78a5636f43172f60'u64, 0x84c87814a1f0ab72'u64, 0x8cc702081a6439ec'u64, 
#     0x90befffa23631e28'u64, 0xa4506cebde82bde9'u64, 0xbef9a3f7b2c67915'u64, 0xc67178f2e372532b'u64, 0xca273eceea26619c'u64, 
#     0xd186b8c721c0c207'u64, 0xeada7dd6cde0eb1e'u64, 0xf57d4f7fee6ed178'u64, 0x06f067aa72176fba'u64, 0x0a637dc5a2c898a6'u64, 
#     0x113f9804bef90dae'u64, 0x1b710b35131c471b'u64, 0x28db77f523047d84'u64, 0x32caab7b40c72493'u64, 0x3c9ebe0a15c9bebc'u64, 
#     0x431d67c49c100d4c'u64, 0x4cc5d4becb3e42b6'u64, 0x597f299cfc657e2a'u64, 0x5fcb6fab3ad6faec'u64, 0x6c44198c4a475817'u64
# ]

# "Nim thing" -- lets me get a pointer to an array
# not really important algorithm-wise
converter uncheck[N;T](arr : array[N,T]) : auto =
    result = cast[ptr UncheckedArray[T]](unsafeAddr arr[0])

# create mapping from names of algorithms to their configurations
let builtinConfigs* = toTable[string, HashConfig]({
    "sha256": HashConfig(
        # numIterations: 64,
        # chunkSize: 64,
        initialHash: @[
            0x6a09e667'u32, 0xbb67ae85'u32, 0x3c6ef372'u32, 0xa54ff53a'u32,
            0x510e527f'u32, 0x9b05688c'u32, 0x1f83d9ab'u32, 0x5be0cd19'u32
        ],
        hashLength: 8,
        roundConstants: uncheck sha256roundConstants,
    ),
    "sha224": HashConfig(
        # numIterations: 64,
        # chunkSize: 64,
        initialHash: @[
            0xc1059ed8'u32, 0x367cd507'u32, 0x3070dd17'u32, 0xf70e5939'u32,
            0xffc00b31'u32, 0x68581511'u32, 0x64f98fa7'u32, 0xbefa4fa4'u32
        ],
        hashLength: 7, # trim the last word off the end of the hash
        roundConstants: uncheck sha256roundConstants,
    )
})

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

# yields every chunk of `data` of size given
iterator chunks(data : openArray[byte], chunkSize : int) : seq[byte] =
    assert data.len mod chunkSize == 0
    for i in countup(0, data.high, chunkSize):
        yield data[i..<i+chunkSize]

proc rightRotate(x : uint32, d: uint32) : uint32 =
    var first = x shr d
    var second = x shl (32 - d)
    return first or second

# allows for `x >>> y` instead of `rightRotate(x, y)`
template `>>>`(x, y : uint32) : uint32 = rightRotate(x, y)

# TODO: correctly adapt this for variable message schedule size
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
            s0 = result[i-15] >>> 7 xor result[i-15] >>> 18 xor result[i-15] shr 3
            s1 = result[i-2] >>> 17 xor result[i-2] >>> 19 xor result[i-2] shr 10
        result[i] = result[i-16] + s0 + result[i-7] + s1

proc addCompressed(hash : var Hash; w : openArray[uint32], roundConstants : ptr UncheckedArray[uint32]) =
    # Step 6 - Compression (& 7)
    # Initialize variables a, b, c, d, e, f, g, h and set them equal to the current hash values respectively.
    # here we're just using an array as a-h
    var hashVars = hash
    dump hashVars
    # Run the compression loop. The compression loop will mutate the values of a…h. The compression loop is as follows:
    for i in 0..<64:
        let
            S1 = hashVars[4] >>> 6 xor hashVars[4] >>> 11 xor hashVars[4] >>> 25
            ch = (hashVars[4] and hashVars[5]) xor ((not hashVars[4]) and hashVars[6])
            temp1 = hashVars[7] + S1 + ch + roundConstants[i] + w[i]
            S0 = hashVars[0] >>> 2 xor hashVars[0] >>> 13 xor hashVars[0] >>> 22
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
    
    dump hashVars
    # Step 7
    # After the compression loop, but still, within the chunk loop,
    # we modify the hash values by adding their respective variables to them, a-h.
    # As usual, all addition is modulo 2^32. (In Nim, just add, it will modulo by itself)
    for i, v in hash.mpairs:
        v += hashVars[i]

proc sha*(cfg : HashConfig, data : seq[byte]) : Hash =
    dump data
    # Step 1: Preprocess
    let padded = data.dup(preprocess)
    dump padded
    dump padded.len
    # Step 2: Initialize hash values
    result = cfg.initialHash
    # Step 4: Chunk loop
    
    for chunk in padded.chunks(64):
        dump chunk
        var messageSchedule = createMessageSchedule(chunk)
        dump messageSchedule
        result.addCompressed(messageSchedule, cfg.roundConstants)
    
    result.setLen cfg.hashLength
    

proc sha*(cfg : HashConfig, str : string) : Hash =
    var data : seq[byte]
    for c in str:
        data &= byte c
    result = cfg.sha(data)


when isMainModule:
    var # read from first argument, or stdin if none given
        inputStr = if paramCount() >= 1: readFile(paramStr(1)) else: stdin.readAll
        config = builtinConfigs[if paramCount() >= 2: paramStr(2) else: "sha256"]
    
    echo config.sha(inputStr)
    # dump typeof(sha256(inputStr)).name
    
