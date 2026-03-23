`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2026 03:45:33 PM
// Design Name: 
// Module Name: vga_testpatterns_tb
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


module vga_testpatterns_tb();
    parameter CLK_PERIOD = 10;  // 10ns => 100 MHz
    // simplified parameters for VGA
    parameter TOTAL_COLS = 10;
    parameter TOTAL_ROWS = 6;
    parameter ACTIVE_COLS = 8;
    parameter ACTIVE_ROWS = 4;
    
    // Internal Signals
    logic clk = 0;
    logic reset;
    logic [3:0] pattern;
    logic [3:0] red_video_tp, green_video_tp, blue_video_tp;
    
    logic [$clog2(TOTAL_COLS)-1:0] col_count;
    logic [$clog2(TOTAL_ROWS)-1:0] row_count;
    logic HSync, VSync;
    logic [3:0] red_out, green_out, blue_out;
    
    // Instantiate TESTPATTERN_GENERATOR
    vga_testpattern_gen #(
        .TOTAL_COLS(TOTAL_COLS),
        .TOTAL_ROWS(TOTAL_ROWS)
    ) UUT_TESTPATTERN_GEN ( // drives red/green/blue video
        .col_count(col_count),
        .row_count(row_count),
        .pattern(pattern),
        .red_video(red_video_tp),
        .green_video(green_video_tp),
        .blue_video(blue_video_tp)  
    );
    
    //    // Instantiate VGA_SYNC_PULSE_GENERATOR
    vga_controller #(
        .TOTAL_COLS(TOTAL_COLS),
        .TOTAL_ROWS(TOTAL_ROWS)
    ) UUT_VGA_CONTROLLER ( // generates sync pulses to run VGA
        .clk(clk),
        .reset(reset),
        .red_in(red_video_tp),
        .blue_in(blue_video_tp),
        .green_in(green_video_tp),
        .hsync(HSync),
        .vsync(VSync),
        .red_out(red_out),
        .green_out(green_out),
        .blue_out(blue_out),
        .h_count(col_count),
        .v_count(row_count)
    );
     
    // Clock Generation
    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end
    
    // Test stimulus
    initial begin
        $display("=== VGA Testbench ===");
        // Initialize inputs
        reset = 0;
        pattern = 4'b0000;
        
        // include small offset so simulation is easier to interpret
        #(CLK_PERIOD/4); 
        
        // apply reset
        reset = 1; #(5*CLK_PERIOD);
        reset = 0; #(5*CLK_PERIOD);
        
        // Test case 1:
        pattern = 4'b0001;
        $display("Test Pattern 1 (All Red)");
        #2000;
        
        // Test case 2:
        pattern = 4'b0010;
        $display("Test Pattern 2 (All Green)");
        #2000;
        
        // Test case 3:
        pattern = 4'b0011;
        $display("Test Pattern 3 (All Blue)");
        #2000;
        
        $display("=== All tests completed ===");
        $finish();
    end

endmodule
