# Signoff timing constraints

create_clock -name clk -period 50.0 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.5 [get_clocks clk]

# Maximum transition
set_max_transition 0.4 [current_design]

# Maximum fanout
set_max_fanout 4 [current_design]

# Maximum capacitance
set_max_capacitance 0.8 [current_design]
