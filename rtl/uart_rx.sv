//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/16/2025 09:02:41 PM
// Design Name: 
// Module Name: uart_rx
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

// clks per bit = 100 MHz / 115200 baud rate = 868
module uart_rx #(parameter CLKS_PER_BIT = 868) (
    input logic clk,
    input logic reset,
    input logic rx_serial,
    output logic rx_data_valid,
    output logic [7:0] rx_byte
);
    
    // Internal signals
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] rx_data = 8'b0000_0000; // Initialize to 0 (not in undefined state)

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        RX_START_BIT = 3'b001,
        RX_DATA_BITS = 3'b010,
        RX_STOP_BIT = 3'b011,
        CLEANUP = 3'b100
    } statetype;
    
    /* RX state machine */
    statetype current_state, next_state;
    
    // State Register
    always_ff @(posedge clk) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end
    
    // Next State Logic
    always_comb begin
        case (current_state)
            IDLE: begin               
                // if start bit is detected, move the next state
                if (rx_serial == 1'b0) next_state = RX_START_BIT;
                else next_state = IDLE;
            end
            
            RX_START_BIT: begin
                // check middle of the start bit to make sure it's still low
                if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                    // if input serial stream is low, start receiving data bits
                    if (rx_serial == 1'b0) next_state = RX_DATA_BITS;
                    else next_state = IDLE;
                end
                
                else next_state = RX_START_BIT;
            end
            
            RX_DATA_BITS: begin
                // wait CLKS_PER_BIT - 1 (868-1) clk cycles to sample serial data
                // once done sampling and all bits have been received, move to next state
                if (clk_count == CLKS_PER_BIT - 1 && bit_index == 7) next_state = RX_STOP_BIT;
                else next_state = RX_DATA_BITS;
            end
            
            RX_STOP_BIT: begin
                // stop bit = 1 (always)
                // wait CLKS_PER_BIT - 1 (868-1) clk cycles for stop bit to finish
                if (clk_count == CLKS_PER_BIT - 1) next_state = CLEANUP;
                else next_state = RX_STOP_BIT;
            end
            
            CLEANUP:
                next_state = IDLE;
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output Logic
    always_ff @(posedge clk) begin
        case (current_state)
            IDLE: begin
                // reset everything to 0
                rx_data_valid <= 0;
                clk_count <= 0;
                bit_index <= 0;
//                rx_data <= 0; // don't set bit to 0 here or it will clear every time
//                rx_byte <= 0;
            end
            
            RX_START_BIT: begin
                // check middle of the start bit to make sure it's still low
                if (clk_count == (CLKS_PER_BIT - 1) / 2)
                    clk_count <= 0; // if in the middle, reset clk counter
                else
                    clk_count <= clk_count + 1; // else increment counter
            end
            
            RX_DATA_BITS: begin
                // wait CLKS_PER_BIT - 1 (868-1) clk cycles to sample serial data
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0; // reset clk counter
                    rx_data[bit_index] <= rx_serial;
                    
                    // if we received all the bits
                    if (bit_index == 7)
                        bit_index <= 0; // reset bit_index
                    else
                        bit_index <= bit_index + 1; // else increment bit index
                end
                
                else
                    clk_count <= clk_count + 1; // else increment clk counter
            end
            
            RX_STOP_BIT: begin
                // wait CLKS_PER_BIT - 1 (868-1) clk cycles for stop bit to finish
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0; // reset clk counter
                    rx_data_valid <= 1'b1;  // data valid = 1
                end
                
                else
                    clk_count <= clk_count + 1; // else increment clk counter
            end
            
            CLEANUP:
                rx_data_valid <= 1'b0; // reset valid bit to 0
        endcase
    end
    
    assign rx_byte = rx_data;

endmodule
