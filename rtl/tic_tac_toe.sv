// Tic Tac Toe Game File
module tic_tac_toe(
    input logic clk,
    input logic reset,
    input logic rx_data_valid,
    input logic [7:0] rx_byte,
    // include outputs
    output logic [17:0] board,          // 9 cells x 2 bits each (00=empty, 01=P1, 10=P2)
    output logic [1:0] game_state,      // default game state to play state
    output logic [3:0] cell_address,
    output logic player_turn
);
    
    // Internal Signals
    logic key_valid;
    logic [2:0] key_type;
    logic move_valid;
    logic cell_empty;
    logic p1_win, p2_win, draw;
    logic game_over;
    logic ram_we;
    logic [1:0] ram_wd;
    logic [1:0] ram_rd;            
    
    // Parse UART keystrokes
    input_handler INPUT_HANDLER(
        .clk(clk),
        .reset(reset),
        .rx_data_valid(rx_data_valid),
        .rx_byte(rx_byte),
        .key_valid(key_valid),
        .key_type(key_type)
    );
    
    // Track cursor position
    cursor_tracker CURSOR (
        .clk(clk),
        .reset(reset),
        .key_valid(key_valid),
        .key_type(key_type),
        .cell_address(cell_address),
        .move_valid(move_valid)
    );
    
    // Store board state
    ram RAM (
        .clk(clk),
        .reset(reset),
        .write_enable(ram_we),
        .addr(cell_address),
        .write_data(ram_wd),
        .read_data(ram_rd),
        .board(board)
    );
    
    // win detection - purely combinational
    win_check WIN_CHECK(
        .board(board),
        .p1_win(p1_win),
        .p2_win(p2_win),
        .draw(draw)
    );
    
    assign cell_empty = (ram_rd == 2'b00); // check RAM to see if cell is free
    
    // Game FSM
    tic_tac_toe_fsm GAME_FSM(
        .clk(clk),
        .reset(reset),
        .move_valid(move_valid),
        .cell_empty(cell_empty),
        .p1_win(p1_win),
        .p2_win(p2_win),
        .draw(draw),
        .player_turn(player_turn),
        .ram_we(ram_we),        // FSM controls when RAM is written
        .ram_din(ram_wd),       // FSM drives data to RAM
        .game_state(game_state),
        .game_over(game_over)
    );
    
endmodule

module display_controller #(
    parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525
)(
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
    
    localparam int X_DIVIDER = 213;
    localparam int Y_DIVIDER = 160;
    localparam int PIXEL_WIDTH = 2;
    
    localparam P1 = 2'b01;
    localparam P2 = 2'b10;
    
    // Internal signals
    logic hline, vline;
    logic on_board, draw_x, draw_o; // States for drawing
    logic [9:0] dot_x, dot_y;       // Use a dot to find the cell the cursor is currently on
    logic on_dot;
    
    logic [1:0] c0, c1, c2, c3, c4, c5, c6, c7, c8; 
    assign c0 = board [1:0], c1 = board [3:2], c2 = board [5:4];
    assign c3 = board [7:6], c4 = board [9:8], c5 = board [11:10];
    assign c6 = board [13:12], c7 = board [15:14], c8 = board [17:16];
    
    // Active VGA area: 640 cols x 480 rows
    // Divide screen into 3 col x 3 row for Tic Tac Toe
    // Column dimensions: 213 | 427
    // Row dimensions: 160 | 320
    // Dividers (around 4px) each
    assign hline = (h_count >= X_DIVIDER   && h_count <= X_DIVIDER + PIXEL_WIDTH) ||
                   (h_count >= X_DIVIDER*2 && h_count <= X_DIVIDER*2 + PIXEL_WIDTH);
    assign vline = (v_count >= Y_DIVIDER   && v_count <= Y_DIVIDER + PIXEL_WIDTH) ||
                   (v_count >= Y_DIVIDER*2 && v_count <= Y_DIVIDER*2 + PIXEL_WIDTH);
    
    // Dot Logic
    always_comb begin
        case (cell_address)
            4'd0: begin dot_x = 106; dot_y = 80;  end    // X_DIVIDER/2, Y_DIVIDER/2 (in the middle)
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
    
    assign on_dot = (h_count >= dot_x - 5 && h_count <= dot_x + 5) &&
                    (v_count >= dot_y - 5 && v_count <= dot_y + 5);
    
    // Color Mux
    always_comb begin
        // draw grid lines
        if (hline | vline) begin
            red_vga = 4'hF;
            green_vga = 4'hF;
            blue_vga = 4'hF;
        end
        
        // draw dot to find what cell the cursor is on
        else if (on_dot) begin
            red_vga = 4'hF;
            green_vga = 4'hF;
            blue_vga = 4'hF;
        end
        
        // cell 0
        else if (h_count < X_DIVIDER && v_count < Y_DIVIDER) begin
            red_vga = (c0 == P1) ? 4'hF : 4'h0;
            blue_vga = (c0 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 1
        else if (h_count < (X_DIVIDER*2) && v_count < Y_DIVIDER) begin
            red_vga = (c1 == P1) ? 4'hF : 4'h0;
            blue_vga = (c1 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 2
        else if (h_count < (X_DIVIDER*3) && v_count < Y_DIVIDER) begin
            red_vga = (c2 == P1) ? 4'hF : 4'h0;
            blue_vga = (c2 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 3
        else if (h_count < X_DIVIDER && v_count < (Y_DIVIDER*2)) begin
            red_vga = (c3 == P1) ? 4'hF : 4'h0;
            blue_vga = (c3 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 4
        else if (h_count < (X_DIVIDER*2) && v_count < (Y_DIVIDER*2)) begin
            red_vga = (c4 == P1) ? 4'hF : 4'h0;
            blue_vga = (c4 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 5
        else if (h_count < (X_DIVIDER*3) && v_count < (Y_DIVIDER*2)) begin
            red_vga = (c5 == P1) ? 4'hF : 4'h0;
            blue_vga = (c5 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 6
        else if (h_count < X_DIVIDER && v_count < (Y_DIVIDER*3)) begin
            red_vga = (c6 == P1) ? 4'hF : 4'h0;
            blue_vga = (c6 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 7
        else if (h_count < (X_DIVIDER*2) && v_count < (Y_DIVIDER*3)) begin
            red_vga = (c7 == P1) ? 4'hF : 4'h0;
            blue_vga = (c7 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // cell 8
        else if (h_count < (X_DIVIDER*3) && v_count < (Y_DIVIDER*3)) begin
            red_vga = (c8 == P1) ? 4'hF : 4'h0;
            blue_vga = (c8 == P2) ? 4'hF : 4'h0;
            green_vga = 4'h0;
        end
        
        // else make screen black
        else begin
            red_vga = 4'h0;
            green_vga = 4'h0;
            blue_vga = 4'h0;
        end
    end

endmodule
