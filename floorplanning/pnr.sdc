# PnR timing constraints
create_clock -name clk -period 50.0 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.1 [get_clocks clk]

# Maximum transition
set_max_transition 1.5 [current_design]
