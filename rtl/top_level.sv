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
    output logic CA, CB, CC, CD, CE, CF, CG, DP,    // segment outputs (active-low)
    output logic AN1, AN2, AN3, AN4,                // anode outputs for digit selection (active-low)
    output logic [15:0] led
);
    
    // Internal signal declarations
    logic rx_data_valid;
    logic [7:0] rx_byte;
    
    logic tx_active;
    logic tx_serial;
    logic tx_done;
    
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
    
    // UART is 8 data bits
    uart_rx #(.CLKS_PER_BIT(868)) UART_RX (
        .clk(clk),
        .reset(reset),
        .rx_serial(rx_sync_2),
        .rx_data_valid(rx_data_valid),
        .rx_byte(rx_byte)
    );
    
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
    
    assign led = switches_inputs;

endmodule
