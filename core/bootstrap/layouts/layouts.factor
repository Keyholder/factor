! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math words kernel alien byte-arrays
hashtables vectors strings sbufs arrays
quotations assocs layouts classes.tuple.private
kernel.private ;

BIN: 111 tag-mask set
8 num-tags set
3 tag-bits set

17 num-types set

H{
    { fixnum      BIN: 000 }
    { bignum      BIN: 001 }
    { tuple       BIN: 010 }
    { object      BIN: 011 }
    { hi-tag      BIN: 011 }
    { ratio       BIN: 100 }
    { float       BIN: 101 }
    { complex     BIN: 110 }
    { POSTPONE: f BIN: 111 }
} tag-numbers set

tag-numbers get H{
    { array 8 }
    { wrapper 9 }
    { byte-array 10 }
    { callstack 11 }
    { string 12 }
    { word 13 }
    { quotation 14 }
    { dll 15 }
    { alien 16 }
} assoc-union type-numbers set
