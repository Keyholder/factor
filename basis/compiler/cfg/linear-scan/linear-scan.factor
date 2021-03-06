! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors namespaces make
cpu.architecture
compiler.cfg
compiler.cfg.instructions
compiler.cfg.linear-scan.live-intervals
compiler.cfg.linear-scan.allocation
compiler.cfg.linear-scan.assignment ;
IN: compiler.cfg.linear-scan

! References:

! Linear Scan Register Allocation
! by Massimiliano Poletto and Vivek Sarkar
! http://www.cs.ucla.edu/~palsberg/course/cs132/linearscan.pdf

! Linear Scan Register Allocation for the Java HotSpot Client Compiler
! by Christian Wimmer
! and http://www.ssw.uni-linz.ac.at/Research/Papers/Wimmer04Master/

! Quality and Speed in Linear-scan Register Allocation
! by Omri Traub, Glenn Holloway, Michael D. Smith
! http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.34.8435

: (linear-scan) ( insns -- insns' )
    dup compute-live-intervals
    machine-registers allocate-registers assign-registers ;

: linear-scan ( mr -- mr' )
    [
        [
            [
                (linear-scan) %
                spill-counts get _spill-counts
            ] { } make
        ] change-instructions
    ] with-scope ;
