`default_nettype none
`include "multi_project_harness/includes.v"
`ifdef COCOTB_SIM
    `define MPRJ_IO_PADS 38
`endif
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oen,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7.
    inout [`MPRJ_IO_PADS-8:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2
);

    /*--------------------------------------*/
    /* User project is instantiated  here   */
    /*--------------------------------------*/
    parameter num_projects = 8;
    multi_project_harness #(
    .address_active ( 32'h0310_0000),
    .address_oeb0   ( 32'h0310_0004),
    .address_oeb1   ( 32'h0310_0008),
    // each project gets 0x100 bytes memory space
    .address_ws2812 ( 32'h0310_0100),
    .address_7seg   ( 32'h0310_0200),
    // h30000300 reserved for proj_3: spinet
    .address_freq   ( 32'h0310_0400),
    .address_watch  ( 32'h0310_0500),
    .num_projects   ( 8)) mph (

	// MGMT core clock and reset

    	.wb_clk_i(wb_clk_i),
    	.wb_rst_i(wb_rst_i),

	// MGMT SoC Wishbone Slave

	.wbs_cyc_i(wbs_cyc_i),
	.wbs_stb_i(wbs_stb_i),
	.wbs_we_i(wbs_we_i),
	.wbs_sel_i(wbs_sel_i),
	.wbs_adr_i(wbs_adr_i),
	.wbs_dat_i(wbs_dat_i),
	.wbs_ack_o(wbs_ack_o),
	.wbs_dat_o(wbs_dat_o),

	// Logic Analyzer

	.la_data_in(la_data_in),
	.la_data_out(la_data_out),
	.la_oen (la_oen),

	// IO Pads

	.io_in (io_in),
    .io_out(io_out),
    .io_oeb(io_oeb),

    .proj0_wb_update    (proj0_wb_update),
    .proj0_clk          (proj0_clk),
    .proj0_reset        (proj0_reset),
    .proj0_io_in        (proj0_io_in),
    .proj0_io_out       (proj0_io_out),

    .proj1_wb_update    (proj1_wb_update),
    .proj1_clk          (proj1_clk),
    .proj1_reset        (proj1_reset),
    .proj1_io_in        (proj1_io_in),
    .proj1_io_out       (proj1_io_out),

    .proj2_clk          (proj2_clk),
    .proj2_reset        (proj2_reset),
    .proj2_io_in        (proj2_io_in),
    .proj2_io_out       (proj2_io_out),

    .proj3_clk          (proj3_clk),
    .proj3_reset        (proj3_reset),
    .proj3_io_in        (proj3_io_in),
    .proj3_io_out       (proj3_io_out),

    .proj4_clk          (proj4_clk),
    .proj4_reset        (proj4_reset),
    .proj4_io_in        (proj4_io_in),
    .proj4_io_out       (proj4_io_out),
    .proj4_cnt          (proj4_cnt),
    .proj4_cnt_cont     (proj4_cnt_cont),
    .proj4_wb_update    (proj4_wb_update),

    .proj5_wb_update    (proj5_wb_update),
    .proj5_clk          (proj5_clk),
    .proj5_reset        (proj5_reset),
    .proj5_io_in        (proj5_io_in),
    .proj5_io_out       (proj5_io_out),

    .proj6_clk          (proj6_clk),
    .proj6_io_in        (proj6_io_in),
    .proj6_io_out       (proj6_io_out),

    .proj7_reset        (proj7_reset),
    .proj7_io_in        (proj7_io_in),
    .proj7_io_out       (proj7_io_out)

    );

    `ifdef COCOTB_SIM
        initial begin
            $dumpfile ("user_project_wrapper.vcd");
            $dumpvars (0, user_project_wrapper);
            #1;
        end
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj0_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj0_io_out;
    wire proj0_wb_update;
    wire proj0_clk;
    wire proj0_reset;

    `ifndef NO_PROJ0
    seven_segment_seconds proj_0 (.clk(proj0_clk), .reset(proj0_reset), .led_out(proj0_io_out[14:8]), .compare_in(wbs_dat_i[23:0]), .update_compare(proj0_wb_update));
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj1_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj1_io_out;
    wire proj1_wb_update;
    wire proj1_clk;
    wire proj1_reset;

    `ifndef NO_PROJ1
    ws2812                proj_1 (.clk(proj1_clk), .reset(proj1_reset), .led_num(wbs_dat_i[31:24]), .rgb_data(wbs_dat_i[23:0]), .write(proj1_wb_update), .data(proj1_io_out[8]));
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj2_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj2_io_out;
    wire proj2_clk;
    wire proj2_reset;

    `ifndef NO_PROJ2
    vga_clock             proj_2 (.clk(proj2_clk), .reset_n(proj2_reset), .adj_hrs(proj2_io_in[8]), .adj_min(proj2_io_in[9]), .adj_sec(proj2_io_in[10]), .hsync(proj2_io_out[11]), .vsync(proj2_io_out[12]), .rrggbb(proj2_io_out[18:13]));
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj3_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj3_io_out;
    wire proj3_clk;
    wire proj3_reset;

    `ifndef NO_PROJ3
	spinet5 proj_3 ( .clk(proj3_clk), .rst(proj3_reset), .io_in(proj3_io_in), .io_out(proj3_io_out));
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj4_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj4_io_out;
    wire proj4_clk;
    wire proj4_reset;
    wire [31:0] proj4_cnt;
    wire [31:0] proj4_cnt_cont;
    wire proj4_wb_update;

    `ifndef NO_PROJ4
    asic_freq proj_4(
        .clk(proj4_clk),
        .rst(proj4_reset),

        // register write interface (ignores < 32 bit writes):
        // 30000400:
        //   write UART clock divider (min. value = 4),
        // 30000404:
        //   write frequency counter update period [sys_clks]
        // 30000408
        //   set 7-segment display mode,
        //   0: show meas. freq., 1: show wishbone value
        // 3000040C
        //   set 7-segment display value:
        //   digit7 ... digit0  (4 bit each)
        // 30000410
        //   set 7-segment display value:
        //   digit8
        // 30000414
        //   set 7-segment decimal points:
        //   dec_point8 ... dec_point0  (1 bit each)
        // 30000418
        //   read periodically reset freq. counter value
        // 3000041C
        //   read continuous freq. counter value
        .addr(wbs_adr_i[5:2]),
        .value(wbs_dat_i),
        .strobe(proj4_wb_update),

        // signal under test input
        .samplee(proj4_io_in[25]),

        // periodic counter output to wishbone
        .o(proj4_cnt),

        // continuous counter output to wishbone
        .oc(proj4_cnt_cont),

        // UART output to FTDI input
        .tx(proj4_io_out[6]),

        // 7 segment display outputs
        .col_drvs(proj4_io_out[16:8]),  // 9 x column drivers
        .seg_drvs(proj4_io_out[24:17])  // 8 x segment drivers
    );
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj5_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj5_io_out;
    wire proj5_clk;
    wire proj5_reset;
    wire proj5_wb_update;

    `ifdef NO_PROJ5
    watch_hhmm proj_5 (
        .sysclk_i     (proj5_clk),
        .smode_i      (proj5_io_in[36]),
        .sclk_i       (proj5_io_in[37]),
        .dvalid_i     (proj5_wb_update),
        .cfg_i        (wbs_dat_i[11:0]),
        .rstn_i       (proj5_reset),
        .segment_hxxx (proj5_io_out[14:8]),
        .segment_xhxx (proj5_io_out[21:15]),
        .segment_xxmx (proj5_io_out[28:22]),
        .segment_xxxm (proj5_io_out[35:29])
    );
    `endif

    wire [`MPRJ_IO_PADS-1:0] proj6_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj6_io_out;
    wire proj6_clk;
    `ifndef NO_PROJ6
    challenge proj_6 (.uart(proj6_io_in[8]), .clk_10(proj6_clk), .led_green(proj6_io_out[9]), .led_red(proj6_io_out[10]));
    `endif


    wire [`MPRJ_IO_PADS-1:0] proj7_io_in;
    wire [`MPRJ_IO_PADS-1:0] proj7_io_out;
    wire proj7_reset;

    `ifndef NO_PROJ7
    MM2hdmi proj_7 (
    .clock(proj7_io_in[35]),
    .reset(proj7_reset),
    .io_data(proj7_io_in[23:8]),
    .io_newData(proj7_io_in[24]),
    .io_red(proj7_io_out[32:25]),
    .io_hSync(proj7_io_out[33]),
    .io_vSync(proj7_io_out[34])
    );
    `endif
endmodule	// user_project_wrapper
`default_nettype wire
