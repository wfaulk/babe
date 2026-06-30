function hex2dec(h) {
    h = tolower(h)
    n = 0
    for (i = 1; i <= length(h); i++) {
        c = index("0123456789abcdef", substr(h, i, 1)) - 1
        n = n * 16 + c
    }
    return n
}

NR == 1 || length($0) < 5 { next }

{
    f1 = hex2dec(substr($0, 3, 2))
    f2 = hex2dec(substr($0, 5, 4))
    f3 = hex2dec(substr($0, 9, 4))
    f4 = hex2dec(substr($0, 21, 4))
    printf "Sp0₂:%d%% Pulse:%dbpm Respiration:%dbpm PI:%0.1f%%\n", f1, f2, f3, (f4/10)
    fflush()
}
