//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/11/2026 12:09:04 AM
// Design Name: 
// Module Name: vga_testpattern_gen
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

// This module shows all the testpatterns that we can display on VGA.
// All testpatterns are being generated at the same time, this makes use
// of the benefits of FPGAs, they are highly parallelizable.

module vga_testpattern_gen #(
    parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525
)
(
    input logic [$clog2(TOTAL_COLS)-1:0] col_count,
    input logic [$clog2(TOTAL_ROWS)-1:0] row_count,
    input logic [3:0] pattern,  // can have up to 2^4 = 16 patterns
    output logic [3:0] red_video,
    output logic [3:0] green_video,
    output logic [3:0] blue_video
);
    
    // Internal Signals   
    logic [3:0] pattern_red[16];    // an array of size 16, each element is 4-bits (packed + unpacked array)
    logic [3:0] pattern_green[16];
    logic [3:0] pattern_blue[16];
    
    // Pattern 0: Disables Test Pattern Generator
    assign pattern_red[0] = 4'h0;
    assign pattern_green[0] = 4'h0;
    assign pattern_blue[0] = 4'h0;
    
    // Pattern 1: All Red
    assign pattern_red[1] = 4'hF;
    assign pattern_green[1] = 4'h0;
    assign pattern_blue[1] = 4'h0;
    
    // Pattern 2: All Green
    assign pattern_red[2] = 4'h0;
    assign pattern_green[2] = 4'hF;
    assign pattern_blue[2] = 4'h0;
    
    // Pattern 3: All Blue
    assign pattern_red[3] = 4'h0;
    assign pattern_green[3] = 4'h0;
    assign pattern_blue[3] = 4'hF;
    
    // Pattern 4: Checker Board
    // create an alternate pattern with XOR gate
    // the 5th bit toggles every 32 pixels
    // when row_count[5] ^ col_count[5] == 1 -> white
    // when row_count[5] ^ col_count[5] == 0 -> black
    assign pattern_red[4] = row_count[5] ^ col_count[5] ? 4'hF : 4'h0;
    assign pattern_green[4] = pattern_red[4];
    assign pattern_blue[4] = pattern_red[4];
    
    // Pattern 5: Color Bars
    // Colors Each According to this Truth Table:
    // R G B      bar     Ouput Color
    // 0 0 0       0        Black
    // 0 0 1       1        Blue
    // 0 1 0       2        Green
    // 0 1 1       3        Turquoise
    // 1 0 0       4        Red
    // 1 0 1       5        Purple
    // 1 1 0       6        Yellow
    // 1 1 1       7        White
//    always_comb begin;
//        case (col_count[8:6])
//            3'b000: begin       // Black
//                pattern_red[5] = 4'h0;
//                pattern_green[5] = 4'h0;
//                pattern_blue[5] = 4'h0;
//            end
            
//            3'b001: begin       // Blue
//                pattern_red[5] = 4'h0;
//                pattern_green[5] = 4'h0;
//                pattern_blue[5] = 4'hF;
//            end
            
//            3'b010: begin       // Green
//                pattern_red[5] = 4'h0;
//                pattern_green[5] = 4'hF;
//                pattern_blue[5] = 4'h0;
//            end
            
//            3'b011: begin       // Turquoise
//                pattern_red[5] = 4'h0;
//                pattern_green[5] = 4'hF;
//                pattern_blue[5] = 4'hF;
//            end
            
//            3'b100: begin       // Red
//                pattern_red[5] = 4'hF;
//                pattern_green[5] = 4'h0;
//                pattern_blue[5] = 4'h0;
//            end
            
//            3'b101: begin       // Purple
//                pattern_red[5] = 4'hF;
//                pattern_green[5] = 4'h0;
//                pattern_blue[5] = 4'hF;
//            end
            
//            3'b110: begin       // Yellow
//                pattern_red[5] = 4'hF;
//                pattern_green[5] = 4'hF;
//                pattern_blue[5] = 4'h0;
//            end
            
//            3'b111: begin       // White
//                pattern_red[5] = 4'hF;
//                pattern_green[5] = 4'hF;
//                pattern_blue[5] = 4'hF;
//            end
//        endcase
//    end
    assign pattern_red[5]   = col_count[8] ? 4'hF : 4'h0;
    assign pattern_green[5] = col_count[7] ? 4'hF : 4'h0;
    assign pattern_blue[5]  = col_count[6] ? 4'hF : 4'h0;
    
    always_comb begin
        case (pattern)
            4'b0000: begin
                red_video = pattern_red[0];
                green_video = pattern_green[0];
                blue_video = pattern_blue[0];
            end
            
            4'b0001: begin
                red_video = pattern_red[1];
                green_video = pattern_green[1];
                blue_video = pattern_blue[1];
            end
            
            4'b0010: begin
                red_video = pattern_red[2];
                green_video = pattern_green[2];
                blue_video = pattern_blue[2];
            end
            
            4'b0011: begin
                red_video = pattern_red[3];
                green_video = pattern_green[3];
                blue_video = pattern_blue[3];
            end
            
            4'b0100: begin
                red_video = pattern_red[4];
                green_video = pattern_green[4];
                blue_video = pattern_blue[4];
            end
            
            4'b0101: begin
                red_video = pattern_red[5];
                green_video = pattern_green[5];
                blue_video = pattern_blue[5];
            end
            
            // default case
            default: begin
                red_video = pattern_red[0];
                green_video = pattern_green[0];
                blue_video = pattern_blue[0];
            end
        endcase
    end
    
endmodule
