//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2026 02:36:55 PM
// Design Name: 
// Module Name: uart_tx
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
module uart_tx #(parameter CLKS_PER_BIT = 868) (
    input logic clk,
    input logic reset,
    input logic tx_data_valid,
    input logic [7:0] tx_byte,
    output logic tx_active,
    output logic tx_serial,
    output logic tx_done
);
    // Internal Signals
    logic [$clog2(CLKS_PER_BIT)-1:0] clk_count;
    logic [2:0] bit_index;
    logic [7:0] tx_data;
    
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        TX_START_BIT = 2'b01,
        TX_DATA_BITS = 2'b10,
        TX_STOP_BIT = 2'b11
    } statetype;
    
    /* TX state machine */
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
                if (tx_data_valid == 1'b1) next_state = TX_START_BIT;
                else next_state = IDLE;
            end
            
            // generate start bit (start bit  = 0)
            // wait CLKS_PER_BIT - 1 for start bit to finish
            TX_START_BIT: begin
                if (clk_count < CLKS_PER_BIT - 1) next_state = TX_START_BIT;
                else next_state = TX_DATA_BITS;
            end
            
            // wait CLKS_PER_BIT -1 clk cycles for data bit to finish
            TX_DATA_BITS: begin
                if (clk_count == CLKS_PER_BIT && bit_index == 7) next_state = TX_STOP_BIT;
                else next_state = TX_DATA_BITS;
            end
            
            // stop bit = 1
            // wait CLKS_PER_BIT clk cycles for stop bit to finish
            TX_STOP_BIT:
                if (clk_count < CLKS_PER_BIT - 1) next_state = TX_STOP_BIT;
                else next_state = IDLE;
                
            default: next_state = IDLE;
        endcase
    end
    
    // Output Logic
    always_ff @(posedge clk) begin
        case (current_state)
            IDLE: begin
                tx_serial <= 1;
                clk_count <= 0;
                bit_index <= 0;
                tx_done <= 0;
                
                if (tx_data_valid == 1'b1) begin
                    tx_active <= 1; // transmitter is active
                    tx_data <= tx_byte; // good practice to add another register in case tx_byte changes
                end
            end
            
            TX_START_BIT: begin
                tx_serial <= 1'b0; // send out start bit, start bit = 0
                
                if (clk_count < CLKS_PER_BIT - 1)
                    clk_count <= clk_count + 1;
                else
                    clk_count <= 0;
            end
            
            // sending out data bits
            TX_DATA_BITS: begin
                tx_serial <= tx_data[bit_index];
                
                // wait CLKS_PER_BIT
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    
                    if (bit_index < 7)
                        bit_index <= bit_index + 1;
                    else
                        bit_index <= 0;
                end
                    
                else clk_count <= clk_count + 1;
            end
            
            TX_STOP_BIT: begin
                tx_serial <= 1'b1; // stop bit = 1
                
                // wait CLKS_PER_BIT -1 clk cycles for stop bit to finish
                if (clk_count == CLKS_PER_BIT - 1) begin
                    clk_count <= 0;
                    tx_done <= 1'b1;
                    tx_active <= 1'b0;
                end
                
                else clk_count <= clk_count + 1;
            end
        endcase
    end
    
endmodule
