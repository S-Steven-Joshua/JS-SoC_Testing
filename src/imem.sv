
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.05.2026 23:12:53
// Design Name: 
// Module Name: imem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imem(
    input  logic [31:0] a,
    output logic [31:0] out
);

    logic [31:0] ram [0:21];

initial begin
    ram[0]  = 32'h123450B7;
    ram[1]  = 32'h06408093;
    ram[2]  = 32'h01400113;
    ram[3]  = 32'h002081B3;
    ram[4]  = 32'h40218233;
    ram[5]  = 32'h00302023;
    ram[6]  = 32'h00002283;
    ram[7]  = 32'h00518463;
    ram[8]  = 32'h06F00313;
    ram[9]  = 32'h0080006F;
    ram[10] = 32'h0DE00393;
    ram[11] = 32'h00000063;
end

    assign out = ram[a[6:2]];
    always_comb begin
    if((|a[31:7]) & (|a[1:0]))begin
    end
    end
endmodule
