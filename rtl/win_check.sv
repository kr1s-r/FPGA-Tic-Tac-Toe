//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2026 01:49:11 PM
// Design Name: 
// Module Name: win_check
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


module win_check(
    input logic [17:0] board,
    output logic p1_win,
    output logic p2_win,
    output logic draw
);

    localparam P1 = 2'b01;
    localparam P2 = 2'b10;
    
    // Board is shown in the following:
    // bit: 17 16 | 15 14 | 13 12 | 
    //      11 10 |  9 8  |  7 6  |
    //       5 4  |  3 2  |  1 0
    // cell:  c8  |   c7  |   c6  |   
    //        c5  |   c4  |   c3  |  
    //        c2  |   c1  |   c0
    // therefore, we have to check both bits (a cell) to find the value there
    logic [1:0] c0, c1, c2, c3, c4, c5, c6, c7, c8; 
    assign c0 = board [1:0], c1 = board [3:2], c2 = board [5:4];
    assign c3 = board [7:6], c4 = board [9:8], c5 = board [11:10];
    assign c6 = board [13:12], c7 = board [15:14], c8 = board [17:16];
    logic board_full;
    
    // Player 1 Win Scenario
    assign p1_win = (c8==P1 && c4==P1 && c0==P1) ||     // diag 1
                    (c2==P1 && c4==P1 && c6==P1) ||     // diag 2
                    (c8==P1 && c7==P1 && c6==P1) ||     // row 1
                    (c5==P1 && c4==P1 && c3==P1) ||     // row 2
                    (c2==P1 && c1==P1 && c0==P1) ||     // row 3
                    (c8==P1 && c5==P1 && c2==P1) ||     // col 1
                    (c7==P1 && c4==P1 && c1==P1) ||     // col 2
                    (c6==P1 && c3==P1 && c0==P1);       // col 3
                    
    
    // Player 2 Win Scenario
    assign p2_win = (c8==P2 && c4==P2 && c0==P2) ||     // diag 1
                    (c2==P2 && c4==P2 && c6==P2) ||     // diag 2
                    (c8==P2 && c7==P2 && c6==P2) ||     // row 1
                    (c5==P2 && c4==P2 && c3==P2) ||     // row 2
                    (c2==P2 && c1==P2 && c0==P2) ||     // row 3
                    (c8==P2 && c5==P2 && c2==P2) ||     // col 1
                    (c7==P2 && c4==P2 && c1==P2) ||     // col 2
                    (c6==P2 && c3==P2 && c0==P2);       // col 3
    
    // Draw Scenario
    // draw is when board is completely filled and player 1 or player 2 haven't won
    assign board_full = c8 != 2'b00 && c7 != 2'b00 && c6 != 2'b00 &&
                        c5 != 2'b00 && c4 != 2'b00 && c3 != 2'b00 &&
                        c2 != 2'b00 && c1 != 2'b00 && c0 != 2'b00;

    assign draw = board_full & ~p1_win & ~p2_win;
    
endmodule
