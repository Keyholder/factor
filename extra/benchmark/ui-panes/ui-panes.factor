USING: ui.gadgets.panes prettyprint io sequences ;
IN: benchmark.ui-panes

: ui-pane-benchmark ( -- )
    <pane> <pane-stream> [ 10000 [ . ] each ] with-output-stream* ;

MAIN: ui-pane-benchmark
