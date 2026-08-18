//Generate the RTLIL
yosys -p '
read_verilog -sv \
  top.sv \
  core.sv \
  controller.sv \
  main_decoder.sv \
  alu_decoder.sv \
  datapath.sv \
  d_ff.sv \
  adder.sv \
  register_file.sv \
  extender.sv \
  mux_2.sv \
  mux_3.sv \
  alu.sv \
  imem.sv \
  dmem.sv \
  bridge.sv \
  fifo_master.sv \
  fifo.sv \
  master.sv \
  apb_master.sv \
  apb_slave_uart.sv \
  apb_slave_pwm.sv \
  apb_slave_timer.sv \
  uart_soc.sv \
  uart_tx.sv \
  uart_rx.sv \
  serializer.sv \
  deserializer.sv \
  baud_rate.sv \
  pwm.sv \
  timer.sv \
  control_logic.sv \
  decoder_logic.sv \
  normal.sv \
  square.sv;

prep -top top;
write_ilang rtl.il;
'

//Generate the generic gate-level netlist with Yosys
yosys -p '
read_verilog -sv \
  top.sv \
  core.sv \
  controller.sv \
  main_decoder.sv \
  alu_decoder.sv \
  datapath.sv \
  d_ff.sv \
  adder.sv \
  register_file.sv \
  extender.sv \
  mux_2.sv \
  mux_3.sv \
  alu.sv \
  imem.sv \
  dmem.sv \
  bridge.sv \
  fifo_master.sv \
  fifo.sv \
  master.sv \
  apb_master.sv \
  apb_slave_uart.sv \
  apb_slave_pwm.sv \
  apb_slave_timer.sv \
  uart_soc.sv \
  uart_tx.sv \
  uart_rx.sv \
  serializer.sv \
  deserializer.sv \
  baud_rate.sv \
  pwm.sv \
  timer.sv \
  control_logic.sv \
  decoder_logic.sv \
  normal.sv \
  square.sv;

hierarchy -top top;
proc;
opt;
memory;
opt;
techmap;
opt;
abc;
opt;
clean;
write_verilog -noattr generic.nl.v;
'
//Convert the generic gate-level Verilog to RTLIL
yosys -p '
read_verilog generic.nl.v;
prep -top top;
write_ilang generic.il;
'
//Map memories in the RTL representation
yosys -p '
read_ilang rtl.il;
memory_map;
opt;
write_ilang rtl_mapped.il;
'
//Map memories in the generic gate-level representation
yosys -p '
read_ilang generic.il;
memory_map;
opt;
write_ilang generic_mapped.il;
'
