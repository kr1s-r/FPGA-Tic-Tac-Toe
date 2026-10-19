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
    input_handler INPUT_HANDLER (
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
    win_check WIN_CHECK (
        .board(board),
        .p1_win(p1_win),
        .p2_win(p2_win),
        .draw(draw)
    );
    
    assign cell_empty = (ram_rd == 2'b00); // check RAM to see if cell is free
    
    // Game FSM
    tic_tac_toe_fsm GAME_FSM (
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

