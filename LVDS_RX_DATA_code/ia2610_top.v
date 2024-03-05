module top(
    // Camera
    output  cam_rstn,
    // SPI
    output  cam_sck,
    output  cam_ss_n,
    output  cam_mosi,
    input   cam_miso,
    // optional clock
    //output  cam_clkin_p,
    //output  cam_clkin_n,
    // LVDS input
    input   cam_sync_p,
    input   cam_sync_n,
    input   cam_clkout_p,
    input   cam_clkout_n,
    input   [7:0] cam_dout_p,
    input   [7:0] cam_dout_n,
    // Timing control
    output  [2:0] cam_trigger,
    input   [1:0] cam_monitor,
    // Stepper for focusing
    output  drv_ain1,
    output  drv_ain2,
    output  drv_bin1,
    output  drv_bin2,
    // Local clock
    input   pl_clk
);

parameter DEBUG = "TRUE";

////////////////////////////////////////////////////////////////////////////////
// Globals
wire aclk;          //100MHz
wire aresetn;
wire areset;

////////////////////////////////////////////////////////////////////////////////
// CPU subsystem
wire clk200m;
wire clk125m;
wire clk100m;
wire clk25m;
wire rstn_out;

wire [15:0] IRQ;

wire [63:0] GPIO_i;
wire [63:0] GPIO_o;
wire [63:0] GPIO_t;

//wire GP0_axi_aclk;
wire [31:0]GP0_axi_araddr;
wire [2:0]GP0_axi_arprot;
wire GP0_axi_arready;
wire GP0_axi_arvalid;
wire [31:0]GP0_axi_awaddr;
wire [2:0]GP0_axi_awprot;
wire GP0_axi_awready;
wire GP0_axi_awvalid;
wire GP0_axi_bready;
wire [1:0]GP0_axi_bresp;
wire GP0_axi_bvalid;
wire [31:0]GP0_axi_rdata;
wire GP0_axi_rready;
wire [1:0]GP0_axi_rresp;
wire GP0_axi_rvalid;
wire [31:0]GP0_axi_wdata;
wire GP0_axi_wready;
wire [3:0]GP0_axi_wstrb;
wire GP0_axi_wvalid;

//wire HP0_axi_aclk;
wire [48:0]HP0_axi_araddr;
wire [1:0]HP0_axi_arburst;
wire [3:0]HP0_axi_arcache;
wire [7:0]HP0_axi_arlen;
wire [0:0]HP0_axi_arlock;
wire [2:0]HP0_axi_arprot;
wire [3:0]HP0_axi_arqos;
wire HP0_axi_arready;
wire [2:0]HP0_axi_arsize;
wire HP0_axi_arvalid;
wire [48:0]HP0_axi_awaddr;
wire [1:0]HP0_axi_awburst;
wire [3:0]HP0_axi_awcache;
wire [7:0]HP0_axi_awlen;
wire [0:0]HP0_axi_awlock;
wire [2:0]HP0_axi_awprot;
wire [3:0]HP0_axi_awqos;
wire HP0_axi_awready;
wire [2:0]HP0_axi_awsize;
wire HP0_axi_awvalid;
wire HP0_axi_bready;
wire [1:0]HP0_axi_bresp;
wire HP0_axi_bvalid;
wire [63:0]HP0_axi_rdata;
wire HP0_axi_rlast;
wire HP0_axi_rready;
wire [1:0]HP0_axi_rresp;
wire HP0_axi_rvalid;
wire [63:0]HP0_axi_wdata;
wire HP0_axi_wlast;
wire HP0_axi_wready;
wire [7:0]HP0_axi_wstrb;
wire HP0_axi_wvalid;

soc soc_i (
    //.ADC_v_n(),
    //.ADC_v_p(),

    .CLK_200m_out(clk200m),
    .CLK_125m_out(clk125m),
    .CLK_100m_out(clk100m),
    .CLK_25m_out(clk25m),
    .CLK_rstn_out(rstn_out),

    .IRQ(IRQ),

    .M0_aclk(aclk),
    .M0_araddr(GP0_axi_araddr),
    .M0_arprot(GP0_axi_arprot),
    .M0_arready(GP0_axi_arready),
    .M0_arvalid(GP0_axi_arvalid),
    .M0_awaddr(GP0_axi_awaddr),
    .M0_awprot(GP0_axi_awprot),
    .M0_awready(GP0_axi_awready),
    .M0_awvalid(GP0_axi_awvalid),
    .M0_bready(GP0_axi_bready),
    .M0_bresp(GP0_axi_bresp),
    .M0_bvalid(GP0_axi_bvalid),
    .M0_rdata(GP0_axi_rdata),
    .M0_rready(GP0_axi_rready),
    .M0_rresp(GP0_axi_rresp),
    .M0_rvalid(GP0_axi_rvalid),
    .M0_wdata(GP0_axi_wdata),
    .M0_wready(GP0_axi_wready),
    .M0_wstrb(GP0_axi_wstrb),
    .M0_wvalid(GP0_axi_wvalid),

    .S0_aclk(aclk),
    .S0_araddr(HP0_axi_araddr),
    .S0_arburst(HP0_axi_arburst),
    .S0_arcache(HP0_axi_arcache),
    .S0_arid(HP0_axi_arid),
    .S0_arlen(HP0_axi_arlen),
    .S0_arlock(HP0_axi_arlock),
    .S0_arprot(HP0_axi_arprot),
    .S0_arqos(HP0_axi_arqos),
    .S0_arready(HP0_axi_arready),
    .S0_arsize(HP0_axi_arsize),
    .S0_aruser(HP0_axi_aruser),
    .S0_arvalid(HP0_axi_arvalid),
    .S0_awaddr(HP0_axi_awaddr),
    .S0_awburst(HP0_axi_awburst),
    .S0_awcache(HP0_axi_awcache),
    .S0_awid(HP0_axi_awid),
    .S0_awlen(HP0_axi_awlen),
    .S0_awlock(HP0_axi_awlock),
    .S0_awprot(HP0_axi_awprot),
    .S0_awqos(HP0_axi_awqos),
    .S0_awready(HP0_axi_awready),
    .S0_awsize(HP0_axi_awsize),
    .S0_awuser(HP0_axi_awuser),
    .S0_awvalid(HP0_axi_awvalid),
    .S0_bid(HP0_axi_bid),
    .S0_bready(HP0_axi_bready),
    .S0_bresp(HP0_axi_bresp),
    .S0_bvalid(HP0_axi_bvalid),
    .S0_rdata(HP0_axi_rdata),
    .S0_rid(HP0_axi_rid),
    .S0_rlast(HP0_axi_rlast),
    .S0_rready(HP0_axi_rready),
    .S0_rresp(HP0_axi_rresp),
    .S0_rvalid(HP0_axi_rvalid),
    .S0_wdata(HP0_axi_wdata),
    .S0_wlast(HP0_axi_wlast),
    .S0_wready(HP0_axi_wready),
    .S0_wstrb(HP0_axi_wstrb),
    .S0_wvalid(HP0_axi_wvalid)
);

assign aclk = clk100m;
assign aresetn = rstn_out;
assign areset = !rstn_out;

////////////////////////////////////////////////////////////////////////////////
// Register file
wire soft_reset;
wire spi_start;
wire [8:0] spi_addr;
wire spi_rdwr;
wire [15:0] spi_wdata;
wire [15:0] spi_rdata;
wire spi_ready;

wire [31:0] FRAME_PERIOD;
wire [31:0] EXPOSURE_0;
wire [31:0] EXPOSURE_1;
wire [31:0] EXPOSURE_2;
wire [31:0] STROBE_PERIOD;
wire [31:0] STROBE_WIDTH;
wire exposure_enable;
wire trigger_enable;

wire serdes_enable;
wire serdes_locked;
wire subsample;

wire [31:0] IMG_DMA_ADDR0;
wire [31:0] IMG_DMA_ADDR1;
wire vcap_enable;
wire vcap_current;
wire vcap_in_done;
wire vcap_out_done;
wire [15:0] vcap_width;
wire [15:0] vcap_height;

wire [31:0] TAG_DMA_ADDR0;
wire [31:0] TAG_DMA_ADDR1;
wire tag_enable;
wire tag_current;
wire tag_in_done;

wire [15:0] SC0_PACKET_DELAY;
wire [47:0] SC0_DST_MAC, SC0_SRC_MAC;
wire [31:0] SC0_DST_IP, SC0_SRC_IP;
wire [15:0] SC0_DST_PORT, SC0_SRC_PORT;
wire [15:0] SC1_PACKET_DELAY;
wire [47:0] SC1_DST_MAC, SC1_SRC_MAC;
wire [31:0] SC1_DST_IP, SC1_SRC_IP;
wire [15:0] SC1_DST_PORT, SC1_SRC_PORT;

wire [31:0] PIXEL_TYPE;

wire [31:0] clc_addr;
wire [31:0] clc_wdata;
wire clc_wen;
wire [31:0] clc_rdata;

wire irq_request;

wire [31:0] time_strobe_sec;
wire [31:0] time_strobe_ns;
wire time_strobe;
wire [31:0] time_sec;
wire [31:0] time_ns;

wire stepper_enable;
wire stepper_direction;
wire stepper_step;
wire [15:0] stepper_pwm_cycle;
wire [15:0] stepper_pwm_duty;

regfile regfile_0(
    .aclk(aclk),
    .aresetn(aresetn),

    .s_axi_awaddr(GP0_axi_awaddr),
    .s_axi_awvalid(GP0_axi_awvalid),
    .s_axi_awready(GP0_axi_awready),
    .s_axi_wdata(GP0_axi_wdata),
    .s_axi_wstrb(GP0_axi_wstrb),
    .s_axi_wvalid(GP0_axi_wvalid),
    .s_axi_wready(GP0_axi_wready),
    .s_axi_bresp(GP0_axi_bresp),
    .s_axi_bvalid(GP0_axi_bvalid),
    .s_axi_bready(GP0_axi_bready),
    .s_axi_araddr(GP0_axi_araddr),
    .s_axi_arvalid(GP0_axi_arvalid),
    .s_axi_arready(GP0_axi_arready),
    .s_axi_rdata(GP0_axi_rdata),
    .s_axi_rresp(GP0_axi_rresp),
    .s_axi_rvalid(GP0_axi_rvalid),
    .s_axi_rready(GP0_axi_rready),

    .soft_reset(soft_reset),

    .spi_start(spi_start),
    .spi_addr(spi_addr),
    .spi_rdwr(spi_rdwr),
    .spi_wdata(spi_wdata),
    .spi_rdata(spi_rdata),
    .spi_ready(spi_ready),

    .FRAME_PERIOD(FRAME_PERIOD),
    .EXPOSURE_0(EXPOSURE_0),
    .EXPOSURE_1(EXPOSURE_1),
    .EXPOSURE_2(EXPOSURE_2),
    .STROBE_PERIOD(STROBE_PERIOD),
    .STROBE_WIDTH(STROBE_WIDTH),
    .exposure_enable(exposure_enable),
    .trigger_enable(trigger_enable),

    .serdes_enable(serdes_enable),
    .serdes_locked(serdes_locked),
    .subsample(subsample),

    .IMG_DMA_ADDR0(IMG_DMA_ADDR0),
    .IMG_DMA_ADDR1(IMG_DMA_ADDR1),
    .vcap_enable(vcap_enable),
    .vcap_current(vcap_current),
    .vcap_in_done(vcap_in_done),
    .vcap_out_done(vcap_out_done),
    .vcap_width(vcap_width),
    .vcap_height(vcap_height),

    .TAG_DMA_ADDR0(TAG_DMA_ADDR0),
    .TAG_DMA_ADDR1(TAG_DMA_ADDR1),
    .tag_enable(tag_enable),
    .tag_current(tag_current),
    .tag_in_done(tag_in_done),

    .SC0_PACKET_DELAY(SC0_PACKET_DELAY),
    .SC0_DST_MAC(SC0_DST_MAC),
    .SC0_SRC_MAC(SC0_SRC_MAC),
    .SC0_DST_IP(SC0_DST_IP),
    .SC0_SRC_IP(SC0_SRC_IP),
    .SC0_DST_PORT(SC0_DST_PORT),
    .SC0_SRC_PORT(SC0_SRC_PORT),

    .SC1_PACKET_DELAY(SC1_PACKET_DELAY),
    .SC1_DST_MAC(SC1_DST_MAC),
    .SC1_SRC_MAC(SC1_SRC_MAC),
    .SC1_DST_IP(SC1_DST_IP),
    .SC1_SRC_IP(SC1_SRC_IP),
    .SC1_DST_PORT(SC1_DST_PORT),
    .SC1_SRC_PORT(SC1_SRC_PORT),

    .PIXEL_TYPE(PIXEL_TYPE),

    .clc_addr(clc_addr),
    .clc_wdata(clc_wdata),
    .clc_wen(clc_wen),
    .clc_rdata(clc_rdata),

    .irq_request(irq_request),

    .stepper_enable(stepper_enable),
    .stepper_direction(stepper_direction),
    .stepper_step(stepper_step),
    .stepper_pwm_cycle(stepper_pwm_cycle),
    .stepper_pwm_duty(stepper_pwm_duty),

    .time_strobe_sec(time_strobe_sec),
    .time_strobe_ns(time_strobe_ns),
    .time_strobe(time_strobe),
    .time_sec(time_sec),
    .time_ns(time_ns)
);

assign IRQ = {15'b0, irq_request};

////////////////////////////////////////////////////////////////////////////////
// SPI controller
wire [25:0] spi_din;
wire [25:0] spi_dout;
spi_ctl #(
    .DATA_BITS(26),
    .CLK_DIV(256),
    .CS_SETUP(1),
    .CS_HOLD(1),
    .SPARE(3)
)spi_ctl_0(
    .mclk(aclk),
    .reset(!aresetn),
    .ac(spi_start),
    .din(spi_din),
    .rdata(spi_dout),
    .vld(),
    .rdy(spi_ready),
    .ss_n(cam_ss_n),
    .sck(cam_sck),
    .mosi(cam_mosi),
    .miso(cam_miso)
);

assign spi_din = {spi_addr,spi_rdwr,spi_wdata};
assign spi_rdata = spi_dout[15:0];

////////////////////////////////////////////////////////////////////////////////
// precise timing
wire tick_sec;
wire tick_ms;
wire tick_us;
precise_timing #(.CLK_PERIOD_NS(10)) timing_0(
    .aclk(aclk),
    .aresetn(aresetn),
    .time_strobe_sec(time_strobe_sec),
    .time_strobe_ns(time_strobe_ns),
    .time_strobe(time_strobe),
    .time_sec(time_sec),
    .time_ns(time_ns),
    .tick_sec(tick_sec),
    .tick_ms(tick_ms),
    .tick_us(tick_us)
);

////////////////////////////////////////////////////////////////////////////////
// Timing Controller for exposure, strobe and vcap.
wire strobe_enable;
wire external_trigger;
timing_controller timing_controller_0(
    .aclk(aclk),
    .aresetn(aresetn),

    .FRAME_PERIOD(FRAME_PERIOD),
    .EXPOSURE_0(EXPOSURE_0),
    .EXPOSURE_1(EXPOSURE_1),
    .EXPOSURE_2(EXPOSURE_2),
    .STROBE_PERIOD(STROBE_PERIOD),
    .STROBE_WIDTH(STROBE_WIDTH),
    .exposure_enable(exposure_enable),
    .trigger_enable(trigger_enable),

    .strobe_enable(strobe_enable),
    .sensor_trigger(cam_trigger),
    .sensor_monitor(cam_monitor),
    .external_trigger(external_trigger),

    .tick_us(tick_us),
    .tick_sec(tick_sec)
);

////////////////////////////////////////////////////////////////////////////////
// Image Stream DMA system
wire vcap_clk;
wire [63:0] vcap_data;
wire vcap_valid;
wire vcap_eof;
wire vcap_eol;
wire [15:0] vcap_hsize;
wire [15:0] vcap_vsize;

wire [7:0] gvsp_img_tdata;
wire gvsp_img_tvalid;
wire gvsp_img_tlast;
wire gvsp_img_tready;

wire overflow;

image_stream #(
    .ADDR_BITS(32),
    .DATA_BITS(64),
    .WRITE_BURST_LENGTH(16),
    .READ_BURST_LENGTH(16),
    .OUTPUT_PACKET_SIZE((1472-8)/8), // optimal UDP payload size
    .WRITE_LIMIT(2592*2048)
) image_stream_0 (
    .aclk(aclk),
    .aresetn(aresetn),

    .m_axi_awaddr(HP0_axi_awaddr),
    .m_axi_awburst(HP0_axi_awburst),
    .m_axi_awcache(HP0_axi_awcache),
    .m_axi_awlen(HP0_axi_awlen),
    .m_axi_awlock(HP0_axi_awlock),
    .m_axi_awprot(HP0_axi_awprot),
    .m_axi_awqos(HP0_axi_awqos),
    .m_axi_awready(HP0_axi_awready),
    .m_axi_awsize(HP0_axi_awsize),
    .m_axi_awvalid(HP0_axi_awvalid),
    .m_axi_wdata(HP0_axi_wdata),
    .m_axi_wlast(HP0_axi_wlast),
    .m_axi_wready(HP0_axi_wready),
    .m_axi_wstrb(HP0_axi_wstrb),
    .m_axi_wvalid(HP0_axi_wvalid),
    .m_axi_bready(HP0_axi_bready),
    .m_axi_bresp(HP0_axi_bresp),
    .m_axi_bvalid(HP0_axi_bvalid),

    .m_axi_araddr(HP0_axi_araddr),
    .m_axi_arburst(HP0_axi_arburst),
    .m_axi_arcache(HP0_axi_arcache),
    .m_axi_arlen(HP0_axi_arlen),
    .m_axi_arlock(HP0_axi_arlock),
    .m_axi_arprot(HP0_axi_arprot),
    .m_axi_arqos(HP0_axi_arqos),
    .m_axi_arready(HP0_axi_arready),
    .m_axi_arsize(HP0_axi_arsize),
    .m_axi_arvalid(HP0_axi_arvalid),
    .m_axi_rdata(HP0_axi_rdata),
    .m_axi_rlast(HP0_axi_rlast),
    .m_axi_rready(HP0_axi_rready),
    .m_axi_rresp(HP0_axi_rresp),
    .m_axi_rvalid(HP0_axi_rvalid),


    .IMG_DMA_ADDR0(IMG_DMA_ADDR0),
    .IMG_DMA_ADDR1(IMG_DMA_ADDR1),
    .IMG_PACKET_DELAY(SC0_PACKET_DELAY),
    .PIXEL_TYPE(PIXEL_TYPE),

    .vcap_enable(exposure_enable),
    .vcap_current(vcap_current),
    .vcap_in_done(vcap_in_done),
    .vcap_out_done(vcap_out_done),
    .vcap_trigger(1'b1),
    .vcap_width(vcap_width),
    .vcap_height(vcap_height),

    .gvsp_img_enable(vcap_enable&&SC0_DST_PORT!=0),

    .cam_pclk(vcap_clk),
    .cam_pdata(vcap_data),
    .cam_pvalid(vcap_valid),
    .cam_eof(vcap_eof),
    .cam_eol(vcap_eol),
    .cam_hsize(vcap_hsize),
    .cam_vsize(vcap_vsize),

    .gvsp_img_tdata(gvsp_img_tdata),
    .gvsp_img_tvalid(gvsp_img_tvalid),
    .gvsp_img_tlast(gvsp_img_tlast),
    .gvsp_img_tready(gvsp_img_tready),

    .overflow(overflow),

    .time_sec(time_sec),
    .time_ns(time_ns),
    .tick_us(tick_us)
);

////////////////////////////////////////////////////////////////////////////////
// sensor image input interface
// Serdes clocks
wire idlyctrl_clk;  // 300MHz
wire serdes_clk;    // 300MHz
wire serdes_clkdiv; // 75MHz
wire serdes_clk_locked;
wire serdes_rst;
clock_generation clk_gen_0(
    .reset(areset),
    .refclk(clk100m),
    .serdes_clk(serdes_clk),
    .serdes_clkdiv(serdes_clkdiv),
    .idlyctrl_clk(idlyctrl_clk),
    .locked(serdes_clk_locked)
);
assign serdes_rst = !serdes_clk_locked;

wire serdes_ready;
wire cam_pclk;
wire [79:0] cam_pdata;
wire cam_fvalid;
wire cam_lvalid;
wire cam_black;
wire cam_sof;
wire cam_eof;
wire cam_sol;
wire cam_eol;
wire [15:0] cam_hsize;
wire [15:0] cam_vsize;


//*********** WYC ADD begin ******************// 

    wire lvds_clk189;
    wire data1, data2, sync_lvds;

lvds_rx_data#(
    .HEAD_SYNC (7'b1110100  ),          // head state sycn value [7:0]
    .DATA_SYNC (7'b1100100  ),          // data state sycn value [7:0]    
    .IDLE_SYNC (7'b1100000  ),          // idle state sycn value [7:0]
    .FRAM_BETW (7'b0)                   // between frame and next frame value [7:0]
) LVDS_RD
(
    .reset      (areset),               // inner reset active high 
    .clkin_p    (cam_dout_p[4]),        // input clk 189M  
    .clkin_n    (cam_dout_n[4]),
    
    //sync channels
    .sync_p     (cam_dout_p[5]),        // input lvds sync [0:0]
    .sync_n     (cam_dout_n[5]),

    //data channels
    .dout_p     (cam_dout_p[7:6]),      // input lvds data [1:0]
    .dout_n     (cam_dout_n[7:6]),
    .enable     (serdes_enable),        // input enable
   
    //output signal board ver
    .data1      (data1),                // LVDS_DATA1
    .data2      (data2),                // LVDS_DATA2
    .sync_lvds  (sync_lvds),            // LVDS_SYNC

    .lvds_clk189(lvds_clk189),          // output lvds clk
    .pclk       (cam_pclk),             // output data clk  
    .reset_out  (reset_out),            // output reset active high 
    .pdata      (cam_pdata[13:0]),      // output data [13:0]
    .lvalid     (cam_lvalid),           // data valid 
    .sof        (cam_sof),              // frame start    
    .eof        (cam_eof),              // frame end
    .sol        (cam_sol),              // line start
    .eol        (cam_eol),              // line end
    .hsize      (cam_hsize),            // horizontal size [15:0]
    .vsize      (cam_vsize)             // vertical size [15:0]
); 

    reg [15:0] frame_cnt;
    reg [15:0] line_cnt;

    always @(posedge cam_pclk) begin
        if (serdes_rst)
            begin
                frame_cnt <= 0;
            end
        else if (cam_eof)
            frame_cnt <= 0;
        else if (cam_sol)
            frame_cnt <= frame_cnt + 1;
    end

    always @(posedge cam_pclk) begin
        if (serdes_rst)
            begin
                line_cnt <= 1;
            end
        else if (cam_eol)
            line_cnt <= 1;
        else if (cam_lvalid)
            line_cnt <= line_cnt + 1;
    end

    ila_0 LVDS_RX_DATA (
	.clk(lvds_clk189), // input wire clk
	.probe0({   cam_pclk, cam_pdata[13:0], cam_lvalid, cam_sof,
                cam_eof, cam_sol, cam_eol, cam_hsize, cam_vsize, 
                data1, data2, sync_lvds, frame_cnt, line_cnt}) // input wire [63:0] probe0
    );   

//*********** WYC ADD end ******************// 


/*
python_if #(
    .PIXEL_BITS(10),
    .CH(8),
    .WIDTH_BITS(12),
    .HEIGHT_BITS(12),
    .USE_CLKOUT("FALSE"), // use internal clock
    //.CLK_DEVICE("PLL"), // use PLL
    .USE_IDELAY("TRUE"), // use idelay
    .IDLY_REFCLK_FREQ(300.0),
    .MIN_PHASE_WINDOW(200), // about 500ps
    .AUTO_RETRAIN("TRUE"), // re-train once every frame
    .DEBUG(DEBUG)
) python_if_0 (
    .reset(serdes_rst),
    .idlyctrl_clk(idlyctrl_clk),
    .clk_serdes(serdes_clk),
    .clk_div(serdes_clkdiv),
    .clkin_p(cam_clkin_p),
    .clkin_n(cam_clkin_n),
    .clkout_p(cam_clkout_p),
    .clkout_n(cam_clkout_n),
    .sync_p(cam_sync_p),
    .sync_n(cam_sync_n),
    .dout_p(cam_dout_p),
    .dout_n(cam_dout_n),

    .enable(serdes_enable),
    .subsample(subsample),
    .serdes_ready(serdes_ready),
    .training_done(serdes_locked),
    .pclk(cam_pclk),
    .pdata(cam_pdata),
    .fvalid(cam_fvalid),
    .lvalid(cam_lvalid),
    .black(cam_black),
    .sof(cam_sof),
    .eof(cam_eof),
    .sol(cam_sol),
    .eol(cam_eol),
    .hsize(cam_hsize),
    .vsize(cam_vsize)
);

*/

// shift to aclk domain
wire [79:0] img_data;
wire img_valid;
wire img_eol;
wire img_eof;
wire [81:0] cam_fifo_din = {cam_eof, cam_eol, cam_pdata};
wire [81:0] cam_fifo_dout;
wire cam_fifo_empty;
fifo_async #(.DSIZE(82),.ASIZE(4),.MODE("FWFT")) cam_fifo_0(
    .wr_rst(serdes_rst),
    .wr_clk(cam_pclk),
    .din(cam_fifo_din),
    .wr_en(cam_lvalid),
    .full(),
    .wr_count(),
    .rd_rst(!aresetn),
    .rd_clk(aclk),
    .dout(cam_fifo_dout),
    .rd_en(1'b1),
    .empty(cam_fifo_empty),
    .rd_count()
);
assign {img_eof, img_eol, img_data} = cam_fifo_dout;
assign img_valid = !cam_fifo_empty;

assign cam_rstn = !(soft_reset || serdes_rst);
//TODO: dynamic sensor clock frequency

////////////////////////////////////////////////////////////////////////////////
// image processor
wire [63:0] post_data; // translated to 8bit component
wire post_valid;
wire post_eof;
wire post_eol;

wire [31:0] tag_tdata;
wire tag_tvalid;
wire tag_tlast;
image_processor #(
    .DATA_BITS(80),
    .WIDTH_BITS(12),
    .PIXEL_BITS(10),
    .CLC_GAIN_BITS(16),
    .CLC_GAIN_FRAC_BITS(8),
    .CLC_OFFSET_BITS(16)
) processor_0 (
    .aclk(aclk),
    .aresetn(aresetn),

    .img_data(img_data),
    .img_valid(img_valid),
    .img_eof(img_eof),
    .img_eol(img_eol),
    .img_hsize(cam_hsize),
    .img_vsize(cam_vsize),

    .clc_waddr(clc_addr),
    .clc_wdata(clc_wdata),
    .clc_wen(clc_wen),
    .clc_rdata(clc_rdata),

    .post_data(post_data),
    .post_valid(post_valid),
    .post_eof(post_eof),
    .post_eol(post_eol),

    .time_abs(time_ns),

    .tag_tdata(tag_tdata),
    .tag_tvalid(tag_tvalid),
    .tag_tlast(tag_tlast),
    .tag_tready(1'b1)
);
assign vcap_clk = aclk;
// vcap needs little-endian
assign vcap_data = post_data;
assign vcap_valid = post_valid;
assign vcap_eol = post_eol;
assign vcap_eof = post_eof;
assign vcap_hsize = cam_hsize;
assign vcap_vsize = cam_vsize;
assign tag_aclk = aclk;

////////////////////////////////////////////////////////////////////////////////
// Stepper driver
drv8835_if drv8835_if_i(
    .clk(aclk),
    .rst(areset),
    .en(stepper_enable),
    .dir(stepper_direction),
    .step(stepper_step),
    .CYCLE_COUNT(stepper_pwm_cycle),
    .DUTY_COUNT(stepper_pwm_duty),
    .drv_a1(drv_ain1),
    .drv_a2(drv_ain2),
    .drv_b1(drv_bin1),
    .drv_b2(drv_bin2)
);

////////////////////////////////////////////////////////////////////////////////
// MISC. devices

////////////////////////////////////////////////////////////////////////////////
// Debug
/*
generate
if (DEBUG == "TRUE") begin:DBG
    reg [31:0] readout_interval;
    reg [31:0] readout_length;
    reg [31:0] interval_timer;
    reg [31:0] delay_timer;
    reg [31:0] readout_delay;
    (* ASYNC_REG = "TRUE" *)
    reg [2:0] trigger_sync;
    always @(posedge cam_pclk)
    begin
        trigger_sync <= {trigger_sync, cam_trigger[0]};
    end
    always @(posedge cam_pclk)
    begin
        if(cam_sof) 
            interval_timer <= 0;
        else
            interval_timer <= interval_timer+125;
        if(cam_eof)
            readout_length <= interval_timer;
        if(cam_sof)
            readout_interval <= interval_timer;

        if(trigger_sync[2] && !trigger_sync[1])
            delay_timer <= 0;
        else
            delay_timer <= delay_timer+125;
        if(cam_sof)
            readout_delay <= delay_timer;
    end
    reg [11:0] hcounter;
    always @(posedge cam_pclk)
    begin
        if(cam_sol)
            hcounter <= 1;
        else if(cam_lvalid)
            hcounter <= hcounter+1;
    end
    reg [11:0] vcounter;
    always @(posedge cam_pclk)
    begin
        if(cam_sof)
            vcounter <= 0;
        else if(cam_eol)
            vcounter <= vcounter+1;
    end

    vio_0 vio_0(
        .clk(cam_pclk),
        .probe_in0(cam_hsize),
        .probe_in1(cam_vsize),
        .probe_in2(readout_interval),
        .probe_in3(readout_length),
        .probe_in4(readout_delay),
        .probe_in5(32'b0),
        .probe_in6(32'b0),
        .probe_in7(32'b0)
    );

    ila_144 ila_0(
        .clk(aclk),
        .probe0({

            HP0_axi_araddr[31:0],
            HP0_axi_arvalid,
            HP0_axi_arlen,

            HP0_axi_rdata[7:0],
            HP0_axi_rvalid,
            HP0_axi_rlast,
            HP0_axi_rready,

            HP0_axi_awaddr[31:0],
            HP0_axi_awvalid,
            HP0_axi_awlen,

            HP0_axi_wdata[7:0],
            HP0_axi_wvalid,
            HP0_axi_wlast,
            HP0_axi_wready,

            overflow,
            img_data[9:0],
            img_eol,
            img_eof,
            img_valid
        })
    );

end
endgenerate

*/

////////////////////////////////////////////////////////////////////////////////
// End of Module
endmodule
