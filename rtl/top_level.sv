//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2025 08:42:42 PM
// Design Name: 
// Module Name: top_level
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

module top_level(
    input logic clk,
    input logic reset,
    input logic [15:0] switches_inputs,
    input logic RsRx,
    output logic RsTx,
    output logic Hsync,
    output logic Vsync,
    output logic [3:0] vgaRed, vgaGreen, vgaBlue,
    output logic CA, CB, CC, CD, CE, CF, CG, DP,    // segment outputs (active-low)
    output logic AN1, AN2, AN3, AN4,                // anode outputs for digit selection (active-low)
    output logic [15:0] led
);
    
    // Constants
    localparam int TOTAL_COLS = 800;
    localparam int TOTAL_ROWS = 525;
    
    // Internal signal declarations
    logic rx_data_valid;
    logic [7:0] rx_byte; // UART is 8 data bits
    
    logic tx_active;
    logic tx_serial;
    logic tx_done;
    
    logic clk_25;
    logic [3:0] pattern;
    logic [3:0] red_video_internal, green_video_internal, blue_video_internal;
    logic [$clog2(TOTAL_COLS)-1:0] col_count;
    logic [$clog2(TOTAL_ROWS)-1:0] row_count;
    
    // Synchronizer
    logic rx_sync_1, rx_sync_2;
    always_ff @(posedge clk) begin
        if (reset) begin
            rx_sync_1 <= 0;
            rx_sync_2 <= 0;
        end
        
        else begin
            rx_sync_1 <= RsRx;
            rx_sync_2 <= rx_sync_1;
        end
    end
    
    // UART Receiver (RX)
    uart_rx #(.CLKS_PER_BIT(868)) UART_RX (
        .clk(clk),
        .reset(reset),
        .rx_serial(rx_sync_2),
        .rx_data_valid(rx_data_valid),
        .rx_byte(rx_byte)
    );
    
    // UART Transceiver (TX)
    uart_tx #(.CLKS_PER_BIT(868)) UART_TX (
        .clk(clk),
        .reset(reset),
        .tx_data_valid(rx_data_valid),  // pass RX to TX module for loopback
        .tx_byte(rx_byte),              // pass RX to TX module for loopback
        .tx_active(tx_active),
        .tx_serial(tx_serial),
        .tx_done(tx_done)
    );
    
    // drive UART line high when transmitter is not active
    assign RsTx = tx_active ? tx_serial : 1'b1;
    
    // Seven-Segment Display
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY(
        .clk(clk),
        .reset(reset),
        .sec_dig1(rx_byte[3:0]),
        .sec_dig2(rx_byte[7:4]),
        .min_dig1(4'b0000),
        .min_dig2(4'b0000),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD),
        .CE(CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
    // -------- VGA ------------
    // Clock Divider
    // VGA uses 25 MHz,
    // so we need to divide our 100 MHz Basys3 clock by 4
    clk_divide_by_4 CLOCK_DIVIDER_BY_4 (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_25)
    );
    
    // Register test pattern from UART when done transmitting
    // Only least significant 4-bits are needed from the whole byte
    always_ff @(posedge clk) begin
        if (reset) pattern <= 4'b0000;
        else pattern <= rx_byte[3:0];
    end
    
    // Drives Red/Green/Blue video (contains all the patterns and selects)
    vga_testpattern_gen #(
        .TOTAL_ROWS(TOTAL_ROWS),
        .TOTAL_COLS(TOTAL_COLS)    
    ) VGA_TESTPATTERN_GEN (
        .col_count(col_count),
        .row_count(row_count),
        .pattern(pattern),
        .red_video(red_video_internal),
        .green_video(green_video_internal),
        .blue_video(blue_video_internal)
    );
    
    // controls VGA HSync and VSync pulses
    vga_controller #(
        .TOTAL_ROWS(TOTAL_ROWS),
        .TOTAL_COLS(TOTAL_COLS)
    ) VGA_CONTROLLER (
        .clk(clk_25),
        .reset(reset),
        .red_in(red_video_internal),
        .green_in(green_video_internal),
        .blue_in(blue_video_internal),
        .hsync(Hsync),
        .vsync(Vsync),
        .red_out(vgaRed),
        .green_out(vgaGreen),
        .blue_out(vgaBlue),
        .h_count(col_count),
        .v_count(row_count)
    );
    
    assign led = switches_inputs;

endmodule
