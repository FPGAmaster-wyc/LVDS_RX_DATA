module get_clk #(
    parameter CLK_DEVICE = "MMCM"
) (
    input reset,  // clock reset
    input clk_in, // input clock from lvds
    output pclk, // output clock data clk
    output lvds_clk, // lvds clock
    //output clk_div2, // parallel clock
    output locked
);

wire clkfb;
wire clkout0;
wire clkout1;
wire clkout2;
wire clkout3;
wire clkout4;
wire clkout5;
wire clkout6;

BUFG clkout0_bufg_i (.I(clkout0),    .O(lvds_clk));    
BUFG clkout1_bufg_i (.I(clkout1),    .O(pclk));
//BUFG clkout2_bufg_i (.I(clkout2),    .O(clk_div2));

generate

if (CLK_DEVICE == "MMCM") begin
MMCME2_ADV #(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (6.000),      // VCO= 189M * 6 = 1134MHz 
    .CLKFBOUT_PHASE       (45.0),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (6),        // 1134/6=189MHz     
    .CLKOUT1_DIVIDE       (42),          // 1134/42=27Mhz
    //.CLKOUT2_DIVIDE       (20),          // 1200/20=60Mhz
    .CLKIN1_PERIOD        (5.291005)       // 189MHz   
)
mmcm_i
(
    .CLKFBOUT            (clkfb),
    .CLKOUT0             (clkout0),
    .CLKOUT1             (clkout1),
    .CLKOUT2             (clkout2),
    .CLKOUT3             (clkout3),
    .CLKOUT4             (clkout4),
    .CLKOUT5             (clkout5),
    .CLKOUT6             (clkout6),
     // Input clock control
    .CLKFBIN             (clkfb),
    .CLKIN1              (clk_in),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (),
    .DRDY                (),
    .DWE                 (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (),
    // Other control and status signals
    .LOCKED              (locked),
    .CLKINSTOPPED        (),
    .CLKFBSTOPPED        (),
    .PWRDWN              (1'b0),
    .RST                 (reset)
);
end
else if (CLK_DEVICE == "PLL") begin
PLLE2_ADV #(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (6),      // VCO= 189M * 6 = 1134MHz
    .CLKFBOUT_PHASE       (45.0),
    .CLKOUT0_DIVIDE       (6),         // 1134/6=189MHz
    .CLKOUT1_DIVIDE       (42),          // 1134/42=27Mhz
    //.CLKOUT2_DIVIDE       (20),          // 1200/20=60Mhz
    .CLKIN1_PERIOD        (5.291005)       // 300MHz
)
pll_i
(
    .CLKFBOUT            (clkfb),
    .CLKOUT0             (clkout0),
    .CLKOUT1             (clkout1),
    .CLKOUT2             (clkout2),
    .CLKOUT3             (clkout3),
    .CLKOUT4             (clkout4),
    .CLKOUT5             (clkout5),
     // Input clock control
    .CLKFBIN             (clkfb),
    .CLKIN1              (clk_in),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (),
    .DRDY                (),
    .DWE                 (1'b0),
    // Other control and status signals
    .LOCKED              (locked),
    .PWRDWN              (1'b0),
    .RST                 (reset)
);
end

endgenerate

endmodule
