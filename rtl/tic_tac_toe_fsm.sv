//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 01:15:20 PM
// Design Name: 
// Module Name: tic_tac_toe_fsm
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


module tic_tac_toe_fsm (
    input logic clk,
    input logic reset,
    input logic move_valid,
    input logic cell_empty,
    input logic p1_win, p2_win, draw,
    output logic player_turn,       // 1'b0 = PLAYER1, 1'b1 = PLAYER2
    output logic ram_we,
    output logic [1:0] ram_din,
    output logic [1:0] game_state,
    output logic game_over
//    output player1_score,
//    output player2_score
);
        
    localparam P1 = 2'b01, P2 = 2'b10;
    localparam PLAY_STATE = 2'b00, P1_WINS = 2'b01, P2_WINS = 2'b10, DRAW = 2'b11;
    
    assign game_over = p1_win | p2_win | draw;
    
    // state machine - define new type
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        PLAYER1_TURN = 3'b001,
        PLAYER2_TURN = 3'b010,
        WRITE_BOARD = 3'b011,
        CHECK_WIN = 3'b100,
        GAME_OVER = 3'b101
    } statetype;
    
    statetype current_state, next_state;
    
    // state register
    always_ff @(posedge clk) begin
        if (reset) current_state <= IDLE;
        else current_state <= next_state;
    end
    
    // next state logic
    always_comb begin
        case (current_state)
            IDLE: begin
                next_state = PLAYER1_TURN;
            end
            
            PLAYER1_TURN: begin
                if (move_valid && cell_empty) next_state = WRITE_BOARD;
                else next_state = PLAYER1_TURN;
            end
            
            PLAYER2_TURN: begin
                if (move_valid && cell_empty) next_state = WRITE_BOARD;
                else next_state = PLAYER2_TURN;
            end
            
            WRITE_BOARD: begin
                next_state = CHECK_WIN;
            end
            
            // game is over when a win or draw is detected
            CHECK_WIN: begin
                if (game_over) next_state = GAME_OVER;
                else if (player_turn == 1'b1) next_state = PLAYER1_TURN;
                else if (player_turn == 1'b0) next_state = PLAYER2_TURN;
                else next_state = IDLE;
            end
            
            // reset game
            GAME_OVER: next_state = IDLE;
            
            default: next_state = IDLE;
        endcase  
    end
    
    // output logic
    assign ram_we  = (next_state == WRITE_BOARD) ? 1'b1 : 1'b0;
    assign ram_din = (player_turn == 1'b0) ? P1 : P2;
    
    always_ff @(posedge clk) begin
//        ram_we <= 1'b0;       
        
        case (current_state)
            IDLE: begin
                player_turn <= 1'b0;
                game_state <= PLAY_STATE;    // play state
//                ram_we <= 1'b0;
//                ram_din <= 2'b00;
            end
            
//            WRITE_BOARD: begin 
//                ram_we <= 1'b1;
//                ram_din <= (player_turn == 1'b1) ? P2 : P1;
//            end
            
            CHECK_WIN: begin
                player_turn <= ~player_turn;              // opposite players turn
                if (p1_win) game_state <= P1_WINS;        // player 1 wins state
                else if (p2_win) game_state <= P2_WINS;   // player 2 wins state
                else if (draw) game_state <= DRAW;        // draw state
                else game_state <= PLAY_STATE;            // continue in play state
            end
            
            GAME_OVER: begin
                player_turn <= 1'b0; // reset players turn
            end
            
            default: begin
//                player_turn <= 1'b0;
                game_state <= PLAY_STATE;
//                ram_we <= 1'b0;
//                ram_din <= 2'b00;
            end
        endcase
    end

endmodule
