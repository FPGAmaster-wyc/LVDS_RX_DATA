`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 15:38:27
// Design Name: 
// Module Name: tb_seq_check
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


module tb_seq_check;


    reg i_clk,i_reset,i_sync;

    wire o_flag;


    seq_check DUT(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_sync(i_sync),
    .o_flag(o_flag)
);

    initial begin
        i_clk <= 1;
        i_reset <= 1;

        #200
        i_reset <= 0;
        #20

        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 1;
        @ (posedge i_clk)
        i_sync <= 1;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 1;
        @ (posedge i_clk)
        i_sync <= 1;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;
        @ (posedge i_clk)
        i_sync <= 0;


        #600
        $stop;

    end

    always #5 i_clk <= ~i_clk;



endmodule
