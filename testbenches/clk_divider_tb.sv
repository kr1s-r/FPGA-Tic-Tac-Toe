`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2026 05:33:46 PM
// Design Name: 
// Module Name: clk_divider_tb
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


module clk_divider_tb();
    parameter CLK_PERIOD = 10;
    
    logic clk = 0;
    logic reset;
    logic clk_div4;
    
    clk_divide_by_4 UUT (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_div4)
    );
    
    // clock generation
    always begin
        clk=0;
        #(CLK_PERIOD/2);
        clk=1;
        #(CLK_PERIOD/2);
    end
    
    // Test stimulus
    initial begin
        $display("=== Clock Divider Testbench ===");
        reset = 1;
        repeat (2) @(posedge clk);
        @(negedge clk);
        reset = 0;
        
        repeat (20) @(posedge clk);
        $display("=== Simulation Done! ===");
        $finish();
    end
    
endmodule
