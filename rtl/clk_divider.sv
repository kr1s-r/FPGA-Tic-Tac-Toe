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

// This module is an enabled counter that pulses the clk signal at certain times
// we are using the enabled counter as a clock divider
module clk_divider #(
    parameter N = 4
) (
    input logic clk,
    input logic reset,
    output logic clk_en
);

    logic [$clog2(N)-1:0] count; // count up to N
    
    always_ff @(posedge clk) begin
        if (reset) count <= 0;
        else if (count == N-1) count <= 0;   
        else count <= count + 1;
    end 
    
    assign clk_en = (count == N-1) ? 1 : 0;
endmodule
