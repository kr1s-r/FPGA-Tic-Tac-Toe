`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2026 05:37:13 PM
// Design Name: 
// Module Name: tic_tac_toe_display_controller
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


module tic_tac_toe_display_controller #(
    parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525
)
(
    input logic [$clog2(TOTAL_COLS)-1:0] h_count,
    input logic [$clog2(TOTAL_ROWS)-1:0] v_count,
    input logic [17:0] board,
    input logic [3:0] cell_address,
    input logic [1:0] game_state,
    input logic player_turn,
    output logic [3:0] red_vga,
    output logic [3:0] green_vga,
    output logic [3:0] blue_vga
);
    // Constants
    localparam int CELL_WIDTH = 213;
    localparam int CELL_HEIGHT = 160;
    
    localparam int GRID_LINE_THICKNESS = 2;
    localparam int DOT_LENGTH = 5, DOT_WIDTH = 5;
    localparam int X_LENGTH = 50, X_WIDTH = 4;
    localparam int O_LENGTH = 50, O_WIDTH = 50;
    
    localparam P1 = 2'b01;
    localparam P2 = 2'b10;
    
    // Internal signals
    logic hline, vline;
    logic [9:0] cell_x, cell_y;     

    logic [9:0] dot_x, dot_y;       // Use a dot to find the cell the cursor is currently on
    logic draw_dot;

    logic x_diag1, x_diag2, x_bound, draw_x;
    logic draw_o;
    
    // Cell Address is the following on the board:
    // cell-address:  0  |   1  |   2  |   
    //                3  |   4  |   5  |  
    //                6  |   7  |   8
    logic [1:0] c0, c1, c2, c3, c4, c5, c6, c7, c8; 
    assign c0 = board [1:0], c1 = board [3:2], c2 = board [5:4];
    assign c3 = board [7:6], c4 = board [9:8], c5 = board [11:10];
    assign c6 = board [13:12], c7 = board [15:14], c8 = board [17:16];
    
    // Active VGA area: 640 cols x 480 rows
    // Divide screen into 3 col x 3 row for Tic Tac Toe
    // Column dimensions: 213 | 427
    // Row dimensions: 160 | 320
    // Dividers (around 4px) each
    assign hline = (h_count >= CELL_WIDTH   && h_count <= CELL_WIDTH + GRID_LINE_THICKNESS) ||
                   (h_count >= CELL_WIDTH*2 && h_count <= CELL_WIDTH*2 + GRID_LINE_THICKNESS);
    assign vline = (v_count >= CELL_HEIGHT   && v_count <= CELL_HEIGHT + GRID_LINE_THICKNESS) ||
                   (v_count >= CELL_HEIGHT*2 && v_count <= CELL_HEIGHT*2 + GRID_LINE_THICKNESS);
    
    /* Cursor Dot Logic */
    always_comb begin
        case (cell_address) // dot position based on the cell it is in
            4'd0: begin dot_x = 106; dot_y = 80;  end    // CELL_WIDTH/2, CELL_HEIGHT/2 (in the middle)
            4'd1: begin dot_x = 319; dot_y = 80;  end
            4'd2: begin dot_x = 533; dot_y = 80;  end
            4'd3: begin dot_x = 106; dot_y = 240; end 
            4'd4: begin dot_x = 319; dot_y = 240; end
            4'd5: begin dot_x = 533; dot_y = 240; end
            4'd6: begin dot_x = 106; dot_y = 400; end
            4'd7: begin dot_x = 319; dot_y = 400; end
            4'd8: begin dot_x = 533; dot_y = 400; end
            default: begin dot_x = 0; dot_y = 0;  end
        endcase
    end
    
    assign draw_dot = (h_count >= dot_x - DOT_LENGTH && h_count <= dot_x + DOT_LENGTH) &&
                      (v_count >= dot_y - DOT_WIDTH  && v_count <= dot_y + DOT_WIDTH);

    /* X and O drawing logic */

    // cell_x and cell_y give us the center of the cell based on where the current pixel is
    always_comb begin
        if      (h_count < CELL_WIDTH)   cell_x = 106;   // left column
        else if (h_count < CELL_WIDTH*2) cell_x = 319;   // middle column
        else                             cell_x = 533;   // right column

        if      (v_count < CELL_HEIGHT)   cell_y = 80;   // top row
        else if (v_count < CELL_HEIGHT*2) cell_y = 240;  // middle row
        else                              cell_y = 400;  // bottom row
    end

    // "\": this diagonal occurs when h_count - v_count is the same everywhere on the line
    // occurs when h_count - v_count = cell_x - cell_y
    assign x_diag1 = (h_count + cell_y + X_WIDTH >= v_count + cell_x) &&
                     (h_count + cell_y <= v_count + cell_x + X_WIDTH);
    
    // "/": this diagonal occurs when h_count + v_count is the same everywhere on the line
    // occurs when h_count + v_count = cell_x + cell_y
    assign x_diag2 = (h_count + v_count >= cell_x + cell_y - X_WIDTH) &&
                     (h_count + v_count <= cell_x + cell_y + X_WIDTH);
    
    // creates the bound so that it won't be two infinte diagonal lines
    assign x_bound = (h_count >= cell_x - X_LENGTH && h_count <= cell_x + X_LENGTH) &
                     (v_count >= cell_y - X_LENGTH && v_count <= cell_y + X_LENGTH);
    
    assign draw_x = (x_diag1 | x_diag2) & x_bound;

    // logic [9:0] dx, dy;
    // logic [19:0] dist_sq;
    // assign dx = (h_count >= cell_x) ? (h_count - cell_x) : (cell_x - h_count);
    // assign dy = (v_count >= cell_y) ? (v_count - cell_y) : (cell_y - v_count);
    // assign dist_sq = dx*dx + dy*dy; // r^2 = dx^2 + dy^2 (formula of a circle)
    // assign draw_o = (dist_sq <= O_LENGTH*O_WIDTH);

    assign draw_o = (h_count >= cell_x - O_LENGTH && h_count <= cell_x + O_LENGTH) &&
                    (v_count >= cell_y - O_WIDTH  && v_count <= cell_y + O_WIDTH);
    
    /* Color Mux */
    always_comb begin
        // draw tic-tac-toe grid lines
        if (hline | vline) begin
            red_vga = 4'hF;
            green_vga = 4'hF;
            blue_vga = 4'hF;
        end
        
        // draw dot to find what cell the cursor is on
        else if (draw_dot) begin
            red_vga = 4'h0;
            green_vga = 4'hF;
            blue_vga = 4'hF;
        end
        
        // cell 0
        else if (h_count < CELL_WIDTH && v_count < CELL_HEIGHT) begin
            red_vga =   ((c0 == P1 && draw_x) || (c0 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c0 == P1 && draw_x) || (c0 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c0 == P1 && draw_x) || (c0 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 1
        else if (h_count < (CELL_WIDTH*2) && v_count < CELL_HEIGHT) begin
            red_vga =   ((c1 == P1 && draw_x) || (c1 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c1 == P1 && draw_x) || (c1 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c1 == P1 && draw_x) || (c1 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 2
        else if (h_count < (CELL_WIDTH*3) && v_count < CELL_HEIGHT) begin
            red_vga =   ((c2 == P1 && draw_x) || (c2 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c2 == P1 && draw_x) || (c2 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c2 == P1 && draw_x) || (c2 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 3
        else if (h_count < CELL_WIDTH && v_count < (CELL_HEIGHT*2)) begin
            red_vga =   ((c3 == P1 && draw_x) || (c3 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c3 == P1 && draw_x) || (c3 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c3 == P1 && draw_x) || (c3 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 4
        else if (h_count < (CELL_WIDTH*2) && v_count < (CELL_HEIGHT*2)) begin
            red_vga =   ((c4 == P1 && draw_x) || (c4 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c4 == P1 && draw_x) || (c4 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c4 == P1 && draw_x) || (c4 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 5
        else if (h_count < (CELL_WIDTH*3) && v_count < (CELL_HEIGHT*2)) begin
            red_vga =   ((c5 == P1 && draw_x) || (c5 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c5 == P1 && draw_x) || (c5 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c5 == P1 && draw_x) || (c5 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 6
        else if (h_count < CELL_WIDTH && v_count < (CELL_HEIGHT*3)) begin
            red_vga =   ((c6 == P1 && draw_x) || (c6 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c6 == P1 && draw_x) || (c6 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c6 == P1 && draw_x) || (c6 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 7
        else if (h_count < (CELL_WIDTH*2) && v_count < (CELL_HEIGHT*3)) begin
            red_vga =   ((c7 == P1 && draw_x) || (c7 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c7 == P1 && draw_x) || (c7 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c7 == P1 && draw_x) || (c7 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // cell 8
        else if (h_count < (CELL_WIDTH*3) && v_count < (CELL_HEIGHT*3)) begin
            red_vga =   ((c8 == P1 && draw_x) || (c8 == P2 && draw_o)) ? 4'hF : 4'h0;
            green_vga = ((c8 == P1 && draw_x) || (c8 == P2 && draw_o)) ? 4'hF : 4'h0;
            blue_vga =  ((c8 == P1 && draw_x) || (c8 == P2 && draw_o)) ? 4'hF : 4'h0;
        end
        
        // default: make screen black
        else begin
            red_vga = 4'h0;
            green_vga = 4'h0;
            blue_vga = 4'h0;
        end
    end

endmodule
