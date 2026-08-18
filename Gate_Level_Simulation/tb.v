`timescale 1ns/1ps

module cpu_tb;

reg clk;
reg rst;

wire [31:0] write_data;
wire [31:0] data_add;
wire mem_write;
wire [31:0] pr_data;
wire wave;
wire wave1;
wire wave2;

top top1(
    .clk(clk),
    .rst(rst),
    .write_data(write_data),
    .data_add(data_add),
    .mem_write(mem_write),
    .pr_data(pr_data),
    .wave(wave),
    .wave1(wave1),
    .wave2(wave2)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

initial begin
    rst = 1;
    #10;
    rst = 0;
    #500;
    $finish;
end

endmodule
