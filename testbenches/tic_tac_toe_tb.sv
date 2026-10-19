`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/09/2026 02:37:57 PM
// Design Name: 
// Module Name: tic_tac_toe_tb
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


module tic_tac_toe_tb();
    parameter CLK_PERIOD = 10;
    
    logic clk = 0;
    logic reset;
    logic rx_data_valid;
    logic [7:0] rx_byte;
    logic [17:0] board;
    logic [3:0] cell_address;
    
    tic_tac_toe UUT (
        .clk(clk),
        .reset(reset),
        .rx_data_valid(rx_data_valid),
        .rx_byte(rx_byte),
        .board(board),
        .cell_address(cell_address),
        .player_turn(),
        .game_state()
    );
    
    // Clock Generation
    always #(CLK_PERIOD / 2) clk = ~clk;
    
    // Test stimulus
    initial begin
        $display("=== Tic Tac Toe Testbench ===");
        reset = 1;
        repeat (2) @(posedge clk);
        reset = 0;
        
        rx_data_valid = 1;
        rx_byte = 8'h41;
        @(posedge clk);
        rx_byte = 8'h42;
        @(posedge clk);
        rx_byte = 8'h0d;
        @(posedge clk);
        rx_byte = 8'h43;
        @(posedge clk);
        rx_byte = 8'h35;
        @(posedge clk);
        rx_byte = 8'h0d;
        @(posedge clk);
        rx_byte = 8'h44;
        @(posedge clk);
        rx_data_valid = 0;
        @(posedge clk);
        $display("=== Simulation Done! ===");
        $finish();
    end
endmodule
