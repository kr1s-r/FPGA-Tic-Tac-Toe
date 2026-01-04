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
    
    // Internal signal declarations
    logic rx_data_valid;
    logic [7:0] rx_byte;
    logic [7:0] rx_byte_out;
    
    // Synchronizer
    logic first_stage;
    always_ff @(posedge clk) begin
        if (reset) begin
            first_stage <= 0;
            rx_byte_out <= 0;
        end
        
        else begin
            first_stage <= rx_byte;
            rx_byte_out <= first_stage;
        end
    end
    
    // UART is 8 data bits
    uart_rx #(.CLKS_PER_BIT(868)) UART_RX (
        .clk(clk),
        .reset(reset),
        .rx_serial(RsRx),
        .rx_data_valid(rx_data_valid),
        .rx_byte(rx_byte)
    );
    
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY(
        .clk(clk),
        .reset(reset),
        .sec_dig1(rx_byte_out[3:0]),
        .sec_dig2(rx_byte_out[7:4]),
        .min_dig1(4'b0000),
        .min_dig2(4'b0000),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD),
        .CE(CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
    assign led[0] = rx_data_valid;
    assign led[8:1] = rx_byte_out[7:0];
    assign led[15:9] = 7'b000_0000;

endmodule
