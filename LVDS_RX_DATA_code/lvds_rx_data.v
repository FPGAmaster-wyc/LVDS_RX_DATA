// image size         640*480
/*
例化模板：
lvds_rx_data#(
    .HEAD_SYNC (7'b1100100  ),          // head state sycn value [7:0]
    .DATA_SYNC (7'b1100100  ),          // data state sycn value
    .IDLE_SYNC (7'b1100000  )           // idle state sycn value
) LVDS_RD
(
    .reset      (serdes_rst),           // inner reset active high 
    .clkin_p    (cam_dout_p[4]),        // input clk 189M  
    .clkin_n    (cam_dout_n[4]),
    
    //sync channels
    .sync_p     (cam_dout_p[5]),        //input lvds sync [0:0]
    .sync_n     (cam_dout_n[5]),

    //data channels
    .dout_p     (cam_dout_p[7:6]),      // input lvds data [1:0]
    .dout_n     (cam_dout_n[7:6]),
    .enable     (serdes_enable),        // input enable

    //output signal
    .pclk       (cam_pclk),             // output data clk  
    .pdata      (cam_pdata),            // output data [13:0]
    .lvalid     (cam_lvalid),           // data valid 
    .sof        (cam_sof),              // frame start    
    .eof        (cam_eof),              // frame end
    .sol        (cam_sol),              // line start
    .eol        (cam_eol),              // line end
    .hsize      (cam_hsize),            // horizontal size [15:0]
    .vsize      (cam_vsize)             // vertical size [15:0]
);
*/
// 
//////////////////////////////////////////////////////////////////////////////////
module lvds_rx_data#(
    parameter HEAD_SYNC = 7'b1110100,
    parameter DATA_SYNC = 7'b1100100,
    parameter IDLE_SYNC = 7'b1100000,
    parameter FRAM_BETW = 7'd0
)
(
    input reset,
    input clkin_p,
    input clkin_n,

    //sync channels
    input sync_p,
    input sync_n,

    //data channels
    input [1:0] dout_p,
    input [1:0] dout_n,

    input   enable,

    //test signal
    output  lvds_clk189,   //189M
    output  data1,
    output  data2,
    output  sync_lvds,

    output  pclk,
    output  reset_out,
    output  [13:0] pdata,
    output  reg lvalid, 
    output  sof,    
    output  eof,    
    output  sol,     
    output  reg eol,    
    output  [15:0] hsize,
    output  [15:0] vsize
);

    reg [13:0] data;        
    reg [13:0] data_temp;   
    reg r0_lvalid;

    reg [6:0]  sync;        
    reg [6:0]  sync_temp;   
    reg [13:0] sync_group;  
    reg [7:0]  sync_cnt;    

    reg [7:0] c_state, n_state;
    parameter   IDLE        = 0,    // IDLE 等待触发enable上升沿  
                FRAME_HEAD  = 1,    // 检测帧头
                RUN         = 2,    // RUN 循环接收数据
                LAST_FRAME  = 3;    // enable 拉低的时候的最后一帧数据

////////////////////////////////////////////////////////////////////////////////  
    //deal with LVDS signal 
    wire LVDS_CLK;    
    wire LVDS_DATA1, LVDS_DATA2;
    wire LVDS_SYNC;
    wire clkin;    

    IBUFDS lvdsclk(.I(clkin_p),.IB(clkin_n),.O(clkin));
    IBUFDS lvdsdata_1(.I(dout_p[0]),.IB(dout_n[0]),.O(LVDS_DATA1));
    IBUFDS lvdsdata_2(.I(dout_p[1]),.IB(dout_n[1]),.O(LVDS_DATA2));
    IBUFDS lvdssync(.I(sync_p),.IB(sync_n),.O(LVDS_SYNC));

////////////////////////////////////////////////////////////////////////////////  
    //get data clk and reset
    wire locked;
    
    get_clk #(
    .CLK_DEVICE("MMCM")
	) GET_CLK(
    .reset(reset),  // clock reset
    .clk_in(clkin), // input clock from lvds
    .pclk(pclk), // output clock data clk
    .lvds_clk(LVDS_CLK), // lvds clock
    .locked(locked)
); 
    //data reset
    assign reset_out = !locked;

////////////////////////////////////////////////////////////////////////////////                       
    //edge of enable
    reg     r0_enable;
    wire    up_edge, down_edge;

    always @(posedge LVDS_CLK) r0_enable <= enable;
    assign up_edge   = ~r0_enable && enable;
    assign down_edge = r0_enable && ~enable;

////////////////////////////////////////////////////////////////////////////////
    //FSM
    always @ (posedge LVDS_CLK, posedge reset_out) begin  :   W_FMS1
        if (reset_out)
            c_state <= IDLE;
        else
            c_state <= n_state;
    end

    always @(*) begin   :   W_FMS2
        case (c_state)
            IDLE    :   begin
                            if (1)
                                n_state = FRAME_HEAD;
                            else
                                n_state = IDLE;
            end 

            FRAME_HEAD  :   begin
                                if (sync_temp == HEAD_SYNC)
                                    n_state = RUN;
                                else
                                    n_state = FRAME_HEAD;
            end

            RUN :   begin
                        if (down_edge)
                            n_state = LAST_FRAME;
                        else if (eof)
                            n_state = FRAME_HEAD;
                        else
                            n_state = RUN;
            end

            LAST_FRAME  :   begin
                                if (eof) 
                                    n_state = IDLE;
                                else
                                    n_state = LAST_FRAME;
            end

            default :   n_state = 'bx;
        endcase 
    end

    always @ (posedge LVDS_CLK, posedge reset_out) begin  :   W_FMS3
        if (reset_out)
            begin 
                sync_temp <= 0;
                data_temp <= 0;
                sync_cnt <= 0;
            end 
        else
            case (n_state)
                FRAME_HEAD   :    begin
                                    sync_cnt  <= 0;
                                    sync_temp <= {sync_temp[5:0], LVDS_SYNC};
                                    data_temp <= {({data_temp[12:7], LVDS_DATA2}),
                                                  ({data_temp[5:0 ], LVDS_DATA1})};
                end

                RUN, LAST_FRAME :   begin
                                        sync_temp[6 -  sync_cnt]  <= LVDS_SYNC ;
                                        data_temp[13 - sync_cnt]  <= LVDS_DATA2;
                                        data_temp[6 -  sync_cnt]  <= LVDS_DATA1;
                                        if (sync_cnt >= 6)
                                            sync_cnt <= 0;
                                        else
                                            sync_cnt <= sync_cnt + 1;
                end
            endcase
    end

///////////////////////////////////////////////////////////////////////////////
    //deal with data and sync
    always @ (posedge LVDS_CLK, posedge reset_out) begin
        if (reset_out)
            begin
                data <= 0;
                sync <= 0;
            end
        else if ((n_state == RUN || n_state == LAST_FRAME) && sync_cnt == 0)
            begin
                sync <= sync_temp;
                if (sync_temp == HEAD_SYNC || sync_temp == DATA_SYNC)
                    begin
                        data <= data_temp;
                    end
            end
    end

    //output flag signal
    reg [6:0] r0_sync;
    reg r0_sof, r0_eof, r0_sol, r0_eol;
    reg r1_sof, r1_eof, r1_sol, r1_eol;

    always @(posedge pclk) begin
        r0_sync <= sync;
        sync_group <= {r0_sync, sync};
    end

    always @ (posedge pclk, posedge reset_out) begin
        if (reset_out)
            begin
                r0_sof <= 0; r0_eof <= 0;
            end
        else if (r0_sof) r0_sof <= 0;
        else if (r0_eof) r0_eof <= 0;
        else if (sync_group == {FRAM_BETW, HEAD_SYNC})     // frame head 
            begin r0_sof <= 1; end
        else if (sync_group == {DATA_SYNC, FRAM_BETW})     //frame end            
            begin r0_eof <= 1; end         
    end

    always @(posedge pclk, posedge reset_out) begin
        if (reset_out)
            begin
                r0_sol <= 0; r0_eol <= 0;
            end
        else if (r0_sol) r0_sol <= 0;
        else if (sync_group == {FRAM_BETW, HEAD_SYNC})      // frame head 
            r0_sol <= 1;
        else if (sync_group == {IDLE_SYNC ,DATA_SYNC})     //line head
            r0_sol <= 1;
    end

    //output lvalid and eol
    reg [15:0] line_num;
    reg line_flag;
    always @(posedge pclk, posedge reset_out) begin
        if (reset_out)
            begin
                 
                line_flag <= 0; 
            end
        else if (eol)
            begin 
                line_flag <= 0;
            end 
        else if (r0_sol)
            line_flag <= 1;
    end

    always @(posedge pclk) begin
        if (line_flag)
            line_num <= line_num + 1;
        else
            line_num <= 0;
    end

    always @(posedge pclk, posedge reset_out) begin
        if (reset_out)
            begin
                eol <= 0;  
                lvalid <= 0;
            end
        else if (eol) begin 
            eol <= 0;
            lvalid <= 0;
        end 
        else if (line_num <= 639 && line_num != 0)
            lvalid <= 1;
        else if (line_num == 640)
            eol <= 1;
    end
    
    //sync output signal
    reg [13:0] r0_pdata,r1_pdata,r2_pdata, r3_pdata, r4_pdata;
    reg r1_lvalid, r2_lvalid, r3_lvalid, r2_eof, r2_sof, r3_sof, r2_sol, r3_sol;
    always @(posedge pclk) begin
        r0_pdata    <= data;
        r1_pdata    <= r0_pdata;
        r2_pdata    <= r1_pdata;
        r3_pdata    <= r2_pdata;
        r4_pdata    <= r3_pdata;
        r1_lvalid   <= r0_lvalid;
        r2_lvalid   <= r1_lvalid;
        r3_lvalid   <= r2_lvalid;
        r1_sof      <= r0_sof;
        r2_sof      <= r1_sof;
        r3_sof      <= r2_sof;
        r1_sol      <= r0_sol;
        r2_sol      <= r1_sol;
        r3_sol      <= r2_sol;
        r1_eof      <= r0_eof;
        r2_eof      <= r1_eof;
    end

    assign pdata = r4_pdata;
    assign sof = r3_sof;
    assign sol = r3_sol;
    assign eof = r2_eof;   
    assign hsize = 16'd640;
    assign vsize = 16'd512;

    assign lvds_clk189 = LVDS_CLK;
    assign data1 = LVDS_DATA1;
    assign data2 = LVDS_DATA2;
    assign sync_lvds = LVDS_SYNC;

endmodule
