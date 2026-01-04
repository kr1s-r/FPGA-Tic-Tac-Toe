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
    input clk,
    input reset,
    input RsRx,
    input logic [15:0] switches_inputs,
    output logic CA, CB, CC, CD, CE, CF, CG, DP,    // segment outputs (active-low)
    output logic AN1, AN2, AN3, AN4,                // anode outputs for digit selection (active-low)
    output logic [15:0] led
);
    
    
    assign led = ~switches_inputs;

endmodule
