RTL in SystemVerilog: 

3-stage pipeline: IF / ID / EX

4 hardware threads, each with:  Independent PC, IR (instruction register)

Configurable number of ALUs (1–4)

Fine-grained multithreading

Dispatch Algorithm

Round-robin, sorted by weight each cycle

event-driven priority boosting: boost weight by +4 for Branch, MUL, DIV
