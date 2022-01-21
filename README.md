# SimpleCPU
The aim was to design a Simple CPU which can do basic operations such as adding shifting
vs. Here all list of operations below. According to instructions, first 3 bit opcode which determines the
operation , next one bit is i which determines if that operation is immidiate if it's one and not if it's zero.Lastly
there is two 14 bit numbers which are A (14bits), and B (14bits) which is the values we take for these
operations and calculate.

Instructions:
0: NAND 69 69 // 1's complement of 1
1: ADDi 69 1 // 2's complement of 1 [69: -1] RecursiveFactorial
2: CPIi 70 100 // loc 1000 -> n
3: ADD 100 69 // n - 1
4: CP 71 100 // 71 -> n - 1
5: LTi 71 1 // n - 1 < 1
6: ADDi 70 1 // loc 1000 ++
7: BZJ 72 71 // if n-1 > 1 go to loc 2 (72:2) else go to loc 8
8: ADD 70 69 // (1000 + n) - 1
9: CPI 74 70 // 74 -> # go to loc (1000 + n) - 1
10: CP 75 70 // 75:loc (1000 + n) - 1
11: ADD 75 69 // [(1000 + n) - 1] --
12: CPI 76 75 // 76: # at loc [(1000 + n) - 1] -13:
MUL 76 74 // 1.2 --> 2.3 --> 6.4 --> (n-1)!.n
14: CP 74 76 // save result
15: CP 77 75 // 77: loc loc (1000 + n) - 1
16: LTi 77 1001 // check that all n numbers multiplied
17: BZJ 73 77 // if 1000 loc stop else continue
18: CP 101 76 // copy result to loc 101
19: BZJi 20 19 // infinite loop END
20: 0
69: 1 // [-1]
70: 1000 // Stack start #
72: 2 // first loop location
73: 11 // second loop location
100: 6 // INPUT n
101: 0 // RESULT 999: 1
