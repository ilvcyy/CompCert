@ *****************************************************************
@
@               The Compcert verified compiler
@
@           Xavier Leroy, INRIA Paris-Rocquencourt
@
@ Copyright (c) 2013 Institut National de Recherche en Informatique et
@  en Automatique.
@
@ Redistribution and use in source and binary forms, with or without
@ modification, are permitted provided that the following conditions are met:
@     * Redistributions of source code must retain the above copyright
@       notice, this list of conditions and the following disclaimer.
@     * Redistributions in binary form must reproduce the above copyright
@       notice, this list of conditions and the following disclaimer in the
@       documentation and/or other materials provided with the distribution.
@     * Neither the name of the <organization> nor the
@       names of its contributors may be used to endorse or promote products
@       derived from this software without specific prior written permission.
@ 
@ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
@ "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
@ LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
@ A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT
@ HOLDER> BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
@ EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
@ PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
@ PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
@ LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
@ NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
@
@ *********************************************************************

@ Helper functions for 64-bit integer arithmetic.  ARM version.

        .text

@@@ Shift left	

@ Note on ARM shifts: the shift amount is taken modulo 256.
@ If shift amount mod 256 >= 32, the shift produces 0.

@ Algorithm:
@    RH = (XH << N) | (XL >> (32-N) | (XL << (N-32))
@    RL = XL << N        
@ If N = 0:
@    RH = XH | 0 | 0
@    RL = XL
@ If 1 <= N <= 31:  1 <= 32-N <= 31  and  255 <= N-32 mod 256 <= 255
@    RH = (XH << N) | (XL >> (32-N) | 0
@    RL = XL << N        
@ If N = 32:
@    RH = 0 | XL | 0
@    RL = 0
@ If 33 <= N <= 63: 255 <= 32-N mod 256 <= 255 and 1 <= N-32 <= 31
@    RH = 0 | 0 | (XL << (N-32))
@    RL = 0
	
	.global __i64_shl
__i64_shl:
        and r2, r2, #63         @ normalize amount to 0...63
        rsb r3, r2, #32         @ r3 = 32 - amount
        mov r1, r1, lsl r2
        orr r1, r1, r0, lsr r3
	sub r3, r2, #32         @ r3 = amount - 32
	orr r1, r1, r0, lsl r3
        mov r0, r0, lsl r2
        bx lr
	.type __i64_shl, %function
	.size __i64_shl, . - __i64_shl

