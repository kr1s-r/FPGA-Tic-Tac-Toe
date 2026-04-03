`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/03/2026 12:11:59 PM
// Design Name: 
// Module Name: vga
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


module vga #(
    parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525
)
(
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  pattern,
    output logic        hsync,
    output logic        vsync,
    output logic [3:0]  red_out,
    output logic [3:0]  green_out,
    output logic [3:0]  blue_out,
    output logic [$clog2(TOTAL_COLS)-1:0] h_count,
    output logic [$clog2(TOTAL_ROWS)-1:0] v_count
);

    // Internal Signals
    logic clk_en;
    logic [3:0] red_video_internal, green_video_internal, blue_video_internal;

    // Clock Divider
    // VGA uses 25 MHz,
    // Instead of dividing the CLK, we use an enabled counter that pulses
    clk_divider #(.N(4)) CLOCK_DIVIDER (
        .clk(clk),
        .reset(reset),
        .clk_en(clk_en)
    );
    
    // Drives Red/Green/Blue video (contains all the patterns and selects)
    vga_testpattern_gen #(
        .TOTAL_ROWS(TOTAL_ROWS),
        .TOTAL_COLS(TOTAL_COLS)    
    ) VGA_TESTPATTERN_GEN (
        .col_count(h_count),
        .row_count(v_count),
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
        .clk(clk),
        .clk_en(clk_en),
        .reset(reset),
        .red_in(red_video_internal),
        .green_in(green_video_internal),
        .blue_in(blue_video_internal),
        .hsync(hsync),
        .vsync(vsync),
        .red_out(red_out),
        .green_out(green_out),
        .blue_out(blue_out),
        .h_count(h_count),
        .v_count(v_count)
    );

endmodule
