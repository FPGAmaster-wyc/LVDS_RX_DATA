`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 15:01:47
// Design Name: 
// Module Name: seq_check
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


module seq_check(
    input i_clk,
    input i_reset,

    input i_sync,

    output reg o_flag
);

    reg [7:0] state;
    parameter   S0 = 0,
                S1 = 1,
                S2 = 2,
                S3 = 3,
                S4 = 4,
                S5 = 5,
                S6 = 6,
                S7 = 7,
                IDLE = 8;

    always @(posedge i_clk) begin
        if (i_reset)
            begin
                state   <= IDLE ;
                o_flag  <= 0    ;                
            end
        else
            case (state)
                IDLE :  begin
                            begin
                                o_flag  <= 0    ; 
                                state   <=  S0;   
                            end
                                  
                end 

                S0  :   begin
                            if (i_sync == 1)
                                state <= S1;
                            else
                                state <= S0;
                end

                S1  :   begin
                            if (i_sync == 1)
                                state <= S2;
                            else
                                state <= S1;
                end

                S2  :   begin
                            if (i_sync == 0)
                                state <= S3;
                            else
                                state <= S2;
                end

                S3  :   begin
                            if (i_sync == 0)
                                state <= S4;
                            else
                                state <= S1;
                end

                S4  :   begin
                            if (i_sync == 0)
                                state <= S5;
                            else
                                state <= S1;
                end

                S5  :   begin
                            if (i_sync == 0)
                                state <= S6;
                            else
                                state <= S1;
                end

                S6  :   begin
                            if (i_sync == 0)
                                begin
                                    state <= S7;
                                    o_flag <= 1;
                                end
                            else
                                state <= S1;
                end

                S7  :   o_flag <= 0;
            endcase
    end

endmodule
