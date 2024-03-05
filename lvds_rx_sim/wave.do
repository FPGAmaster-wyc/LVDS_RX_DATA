onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group other /tb_lvds_rx_data/DUT/HEAD_SYNC
add wave -noupdate -group other /tb_lvds_rx_data/DUT/DATA_SYNC
add wave -noupdate -group other /tb_lvds_rx_data/DUT/IDLE_SYNC
add wave -noupdate -group other /tb_lvds_rx_data/DUT/clkin
add wave -noupdate -group other /tb_lvds_rx_data/DUT/reset
add wave -noupdate -group other /tb_lvds_rx_data/DUT/LVDS_CLK
add wave -noupdate -group other /tb_lvds_rx_data/DUT/LVDS_SYNC
add wave -noupdate -group other /tb_lvds_rx_data/DUT/LVDS_DATA1
add wave -noupdate -group other /tb_lvds_rx_data/DUT/LVDS_DATA2
add wave -noupdate -group other -radix hexadecimal /tb_lvds_rx_data/DUT/data_temp
add wave -noupdate -group other -radix binary /tb_lvds_rx_data/DUT/sync_temp
add wave -noupdate -group other /tb_lvds_rx_data/DUT/sync_cnt
add wave -noupdate -group other /tb_lvds_rx_data/DUT/c_state
add wave -noupdate -group other /tb_lvds_rx_data/DUT/n_state
add wave -noupdate -group other -radix binary /tb_lvds_rx_data/DUT/sync_group
add wave -noupdate -group other /tb_lvds_rx_data/DUT/enable
add wave -noupdate -group other /tb_lvds_rx_data/DUT/up_edge
add wave -noupdate -group other /tb_lvds_rx_data/DUT/down_edge
add wave -noupdate -group other /tb_lvds_rx_data/DUT/r0_enable
add wave -noupdate -group other -radix unsigned /tb_lvds_rx_data/data
add wave -noupdate -group other -radix binary /tb_lvds_rx_data/DUT/sync
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/pclk
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/enable
add wave -noupdate -expand -group OUT -radix unsigned /tb_lvds_rx_data/DUT/pdata
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/lvalid
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/sof
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/eof
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/sol
add wave -noupdate -expand -group OUT /tb_lvds_rx_data/DUT/eol
add wave -noupdate -expand -group TEST -radix unsigned /tb_lvds_rx_data/DUT/frame_cnt
add wave -noupdate -expand -group TEST -radix unsigned /tb_lvds_rx_data/DUT/line_cnt
add wave -noupdate -expand -group TEST -radix unsigned /tb_lvds_rx_data/DUT/line_num
add wave -noupdate -expand -group TEST /tb_lvds_rx_data/DUT/line_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {start {570874 ps} 1} {end {8313070 ps} 1} {{Cursor 6} {719050 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {272333 ps} {1017591 ps}
