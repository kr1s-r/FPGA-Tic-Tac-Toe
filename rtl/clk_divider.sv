//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2026 10:19:49 PM
// Design Name: 
// Module Name: clk_divider
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

// This module divides the clock by 4
// (can make a better clk divider that works with any even number or any number)
module clk_divide_by_4 (
    input logic clk,
    input logic reset,
    output logic clk_out
);

    logic [1:0] count; // count up to N
    
    always_ff @(posedge clk) begin
        if (reset) count <= 2'b00;       
        else count <= count + 1;
    end 
    
    assign clk_out = count[1];
endmodule
