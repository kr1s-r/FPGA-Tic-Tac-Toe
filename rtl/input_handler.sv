//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 01:29:02 PM
// Design Name: 
// Module Name: input_handler
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


module input_handler(
    input logic clk,
    input logic reset,
    input logic rx_data_valid,
    input logic [7:0] rx_byte,
    output logic key_valid,
    output logic [2:0] key_type
);
    
    // UART is 8-bits
    localparam logic [7:0] BYTE_UP = 8'h41;
    localparam logic [7:0] BYTE_DOWN = 8'h42;
    localparam logic [7:0] BYTE_RIGHT = 8'h43;
    localparam logic [7:0] BYTE_LEFT = 8'h44;
    localparam logic [7:0] BYTE_ENTER = 8'h0d;
    
    // Key encoding
    typedef enum logic [2:0] {
        KEY_NULL = 3'b000,
        KEY_UP = 3'b001,
        KEY_DOWN = 3'b010,
        KEY_RIGHT = 3'b011,
        KEY_LEFT = 3'b100,
        KEY_ENTER = 3'b101
    } key_t;
    
//    localparam logic [2:0] KEY_NULL = 3'b000;
//    localparam logic [2:0] KEY_UP = 3'b001;
//    localparam logic [2:0] KEY_DOWN = 3'b010;
//    localparam logic [2:0] KEY_RIGHT = 3'b011;
//    localparam logic [2:0] KEY_LEFT = 3'b100;
//    localparam logic [2:0] KEY_ENTER = 3'b101;
    
    key_t key_internal;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            key_valid <= 1'b0;
            key_internal <= KEY_NULL;
        end
        
        else if (rx_data_valid) begin
            case (rx_byte)
                BYTE_UP: begin
                    key_valid <= 1'b1;
                    key_internal <= KEY_UP;
                end
                
                BYTE_DOWN: begin
                    key_valid <= 1'b1;
                    key_internal <= KEY_DOWN;
                end
                
                BYTE_RIGHT: begin
                    key_valid <= 1'b1;
                    key_internal <= KEY_RIGHT;
                end
                
                BYTE_LEFT: begin
                    key_valid <= 1'b1;
                    key_internal <= KEY_LEFT;
                end
                
                BYTE_ENTER, 8'h0A: begin
                    key_valid <= 1'b1;
                    key_internal <= KEY_ENTER;
                end
                
                default: begin
                    key_valid <= 1'b0;
                    key_internal <= KEY_NULL;
                end
            endcase
        end
        
        else begin
            key_valid <= 1'b0;
            key_internal <= KEY_NULL;
        end
    end
    
    assign key_type = key_internal;
    
endmodule

// Tracks cursor position
module cursor_tracker(
    input logic clk,
    input logic reset,
    input logic key_valid,            // gives signal that key was pressed
    input logic [2:0] key_type,
    output logic [3:0] cell_address,  // 0-8 current cursor position
    output logic move_valid           // 1-cycle pulse on pressing ENTER
);
    
    localparam KEY_NULL = 3'd0, 
               KEY_UP = 3'd1,
               KEY_DOWN = 3'd2,
               KEY_RIGHT = 3'd3,
               KEY_LEFT = 3'd4,
               KEY_ENTER = 3'd5;
    
    // Internal Signals
    logic [1:0] cursor_row, cursor_col; // finds what row and column the cursor on grid is on
    
    // Cell Address is the following on the board:
    // cell-address:  0  |   1  |   2  |   
    //                3  |   4  |   5  |  
    //                6  |   7  |   8
    assign cell_address = (cursor_row * 3) + cursor_col; // row*3 + col
    assign move_valid = key_valid && (key_type == KEY_ENTER);
    
    // Check cursor position based on arrow keys
    always_ff @(posedge clk) begin
        if (reset) begin
            cursor_col <= 2'b00;
            cursor_row <= 2'b00;
        end
        
        // makes sure row and cols don't go out of bounds
        else if (key_valid) begin
            case(key_type)
                KEY_UP: begin
                    if (cursor_row > 0) cursor_row <= cursor_row - 1;
                end
                
                KEY_DOWN: begin
                    if (cursor_row < 2) cursor_row <= cursor_row + 1;
                end
                
                KEY_LEFT: begin
                    if (cursor_col > 0) cursor_col <= cursor_col - 1;
                end
                
                KEY_RIGHT: begin
                    if (cursor_col < 2) cursor_col <= cursor_col + 1;
                end
                
                default: ;
            endcase
        end
    end

endmodule
