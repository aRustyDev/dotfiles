BEGIN {
    FS="="
    print "["
}

{
    data[NR, 1] = $1
    data[NR, 2] = $2
}

END {
    last = NR
    for (i = 1; i < NR; i++) {
        if (i < last - 1) {
            print "{\""data[i, 1]"\":\""data[i, 2]"\"},"
        } else {
            print "{\""data[i, 1]"\":\""data[i, 2]"\"}"
        }
    }
    print "]"
}
