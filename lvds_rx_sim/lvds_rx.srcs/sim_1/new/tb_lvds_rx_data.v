`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/19 17:49:40
// Design Name: 
// Module Name: tb_lvds_rx_data
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


module tb_lvds_rx_data;

    parameter SIZE = 640;
    parameter LIST = 2;
    parameter FRAME = 2;

    parameter HEAD_SYNC = 7'b1110100;
    parameter DATA_SYNC = 7'b1100100;
    parameter IDLE_SYNC = 7'b1100000;
    parameter HEAD_DATA = 14'h2AAA  ;


    reg reset;

    reg clkin;
    reg clkin_p;
    reg clkin_n;

    //sync channels
    reg LVDS_SYNC;        //测试
    //input sync_p,
    //input sync_n,

    /////data channels
    reg LVDS_DATA1;
    reg LVDS_DATA2;
    //input [1:0] dout_p,
    //input [1:0] dout_n,

    reg enable;

    wire pclk;
    wire [13:0] pdata;
    wire lvalid;  //数据有效
    wire sof;     //帧开始
    wire eof;     //帧结束
    wire sol;     //行开始   
    wire eol;     //行结束

    lvds_rx_data #(
    .HEAD_SYNC (7'b1100100  ),          // head state sycn value [7:0]
    .DATA_SYNC (7'b1100100  ),          // data state sycn value [7:0]    
    .IDLE_SYNC (7'b1100000  ),          // idle state sycn value [7:0]
    .FRAM_BETW (7'b0)                   // between frame and next frame value [7:0]
)

        DUT
(
    .reset(reset),
    .clkin(clkin),
    //.clkin_p(clkin_p),
    //.clkin_n(clkin_n),

    //sync channels
    .LVDS_SYNC(LVDS_SYNC),        //测试
    //input sync_p,
    //input sync_n,

    /////data channels
    .LVDS_DATA1(LVDS_DATA1),
    .LVDS_DATA2(LVDS_DATA2),
    //input [1:0] dout_p,
    //input [1:0] dout_n,

    .enable(enable),

    .pclk(pclk),
    .pdata(pdata),
    .lvalid(lvalid),  //数据有效
    .sof(sof),     //帧开始
    .eof(eof),     //帧结束
    .sol(sol),     //行开始   
    .eol(eol)      //行结束
);

    integer p,i,j,q;
    reg [13:0] data = 14'h1;

    always #2.6455025 clkin <= ~clkin;

    initial begin
        clkin <= 1;
        reset <= 1;
        LVDS_DATA1 <= 0;
        LVDS_DATA2 <= 0;
        LVDS_SYNC <= 0;
        enable <= 0;

        #200
        reset <= 0;
        #300

        @ (posedge clkin)
        @ (posedge clkin)

        enable <= 1;
        @ (posedge clkin)
        @ (posedge clkin)

        for (p=0;p<FRAME;p=p+1) begin              //FRAME帧数据
            
            //Frame Head  {14'h2AAA 14'b10_1010_1010_1010}
            for (i=0;i<7;i=i+1)
            begin
                LVDS_SYNC   <= HEAD_SYNC[6-i];
                LVDS_DATA1  <= HEAD_DATA[6-i];
                LVDS_DATA2  <= HEAD_DATA[13-i];
                @(posedge clkin);
            end

            for (j=0;j<635-1;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end

            //IDLE * 3
            for (j=0;j<30;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= IDLE_SYNC[6-i];
                    @(posedge clkin);
                end
            end

            //478行
            for (q=0;q<LIST-2;q=q+1) begin 
                //Frame data
                for (j=0;j<SIZE;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end
                //IDLE 
                for (j=0;j<3;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= IDLE_SYNC[6-i];
                        @(posedge clkin);
                    end
                end
            end 

            //last line 
            for (j=0;j<SIZE;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= DATA_SYNC[6-i];
                    LVDS_DATA1  <= data[6-i];
                    LVDS_DATA2  <= data[13-i];
                    @(posedge clkin);
                end
                data = data + 1;
            end
            LVDS_SYNC <= 0;
            #2000
            @(posedge clkin);
        end


        


        //这一帧测试把enable拉低情况
        //Frame Head  {14'h2AAA 14'b10_1010_1010_1010}
            for (i=0;i<7;i=i+1)
            begin
                LVDS_SYNC   <= HEAD_SYNC[6-i];
                LVDS_DATA1  <= HEAD_DATA[6-i];
                LVDS_DATA2  <= HEAD_DATA[13-i];
                @(posedge clkin);
            end

            for (j=0;j<SIZE-1;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end

            //IDLE * 3
            for (j=0;j<3;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= IDLE_SYNC[6-i];
                    @(posedge clkin);
                end
            end

            enable <= 0;

            //478行
            for (q=0;q<LIST-2;q=q+1) begin 
                //Frame data
                for (j=0;j<SIZE;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end
                //IDLE 
                for (j=0;j<3;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= IDLE_SYNC[6-i];
                        @(posedge clkin);
                    end
                end
            end 

            //last line 
            for (j=0;j<SIZE;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= DATA_SYNC[6-i];
                    LVDS_DATA1  <= data[6-i];
                    LVDS_DATA2  <= data[13-i];
                    @(posedge clkin);
                end
                data = data + 1;
            end
            LVDS_SYNC <= 0;
            #2000
            @(posedge clkin);


            //这一帧测试把enable又重新拉高
            //Frame Head  {14'h2AAA 14'b10_1010_1010_1010}
            for (i=0;i<7;i=i+1)
            begin
                LVDS_SYNC   <= HEAD_SYNC[6-i];
                LVDS_DATA1  <= HEAD_DATA[6-i];
                LVDS_DATA2  <= HEAD_DATA[13-i];
                @(posedge clkin);
            end

            for (j=0;j<SIZE-1;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end

            //IDLE * 3
            for (j=0;j<3;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= IDLE_SYNC[6-i];
                    @(posedge clkin);
                end
            end

            enable <= 1;

            //478行
            for (q=0;q<LIST-2;q=q+1) begin 
                //Frame data
                for (j=0;j<SIZE;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end
                //IDLE 
                for (j=0;j<3;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= IDLE_SYNC[6-i];
                        @(posedge clkin);
                    end
                end
            end 

            //last line 
            for (j=0;j<SIZE;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= DATA_SYNC[6-i];
                    LVDS_DATA1  <= data[6-i];
                    LVDS_DATA2  <= data[13-i];
                    @(posedge clkin);
                end
                data = data + 1;
            end
            LVDS_SYNC <= 0;
            #2000
            @(posedge clkin);


            //enable重新拉高后的第一个有效帧
            //Frame Head  {14'h2AAA 14'b10_1010_1010_1010}
            for (i=0;i<7;i=i+1)
            begin
                LVDS_SYNC   <= HEAD_SYNC[6-i];
                LVDS_DATA1  <= HEAD_DATA[6-i];
                LVDS_DATA2  <= HEAD_DATA[13-i];
                @(posedge clkin);
            end

            for (j=0;j<SIZE-1;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end

            //IDLE * 3
            for (j=0;j<3;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= IDLE_SYNC[6-i];
                    @(posedge clkin);
                end
            end

            //478行
            for (q=0;q<LIST-2;q=q+1) begin 
                //Frame data
                for (j=0;j<SIZE;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= DATA_SYNC[6-i];
                        LVDS_DATA1  <= data[6-i];
                        LVDS_DATA2  <= data[13-i];
                        @(posedge clkin);
                    end
                    data = data + 1;
                end
                //IDLE 
                for (j=0;j<3;j=j+1)  begin
                    for (i=0;i<7;i=i+1) begin
                        LVDS_SYNC   <= IDLE_SYNC[6-i];
                        @(posedge clkin);
                    end
                end
            end 

            //last line 
            for (j=0;j<SIZE;j=j+1)  begin
                for (i=0;i<7;i=i+1) begin
                    LVDS_SYNC   <= DATA_SYNC[6-i];
                    LVDS_DATA1  <= data[6-i];
                    LVDS_DATA2  <= data[13-i];
                    @(posedge clkin);
                end
                data = data + 1;
            end
            LVDS_SYNC <= 0;
            #2000
            @(posedge clkin);


/*
            */ 


        #200
        $stop;


        

       
        

    end

endmodule
