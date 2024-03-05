`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/22 17:13:19
// Design Name: 
// Module Name: expand_flag
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


module expand_flag(
    input clk,
    input q,
    output wire p
);

    reg r0_q, r1_q, r2_q, r3_q, r4_q, r5_q;

    always @(posedge clk) begin
        r0_q <= q;
        r1_q <= r0_q;
        r2_q <= r1_q;
        r3_q <= r2_q;
        r4_q <= r3_q;
        r5_q <= r4_q;
    end

    assign p = q + r0_q + r1_q + r2_q + r3_q + r4_q + r5_q;
endmodule
