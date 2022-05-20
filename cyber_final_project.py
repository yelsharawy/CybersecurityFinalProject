w = "01101111001000000111011101101111"


def rotate(w, shift):
    first = w[0:len(w)-shift]
    second = w[len(w)-shift:]
    return second + first

def xor(w1, w2):
    ans = ""
    for i in range(len(w1)):
        if w1[i] == w2[i]:
            ans += "0"
        else:
            ans += "1";
    return ans
s0 = xor(xor(rotate(w, 7),rotate(w, 18)), rotate(w, 3))
s1 = xor(xor(rotate(w, 17),rotate(w, 19)), rotate(w, 10))
