! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser compiler.constants math ;
IN: bootstrap.x86

8 \ cell set

: shift-arg ( -- reg ) RCX ;
: div-arg ( -- reg ) RAX ;
: mod-arg ( -- reg ) RDX ;
: temp0 ( -- reg ) RDI ;
: temp1 ( -- reg ) RSI ;
: temp2 ( -- reg ) RDX ;
: temp3 ( -- reg ) RBX ;
: stack-reg ( -- reg ) RSP ;
: ds-reg ( -- reg ) R14 ;
: rs-reg ( -- reg ) R15 ;
: fixnum>slot@ ( -- ) ;
: rex-length ( -- n ) 1 ;

[
    temp0 0 MOV                                 ! load stack_chain
    temp0 temp0 [] MOV
    temp0 [] stack-reg MOV                      ! save stack pointer
] rc-absolute-cell rt-stack-chain 1 rex-length + jit-save-stack jit-define

[
    temp1 0 MOV                                 ! load XT
    temp1 JMP                                   ! go
] rc-absolute-cell rt-primitive 1 rex-length + jit-primitive jit-define

<< "vocab:cpu/x86/bootstrap.factor" parse-file parsed >>
call
