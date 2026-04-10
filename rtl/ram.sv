//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 11:43:56 PM
// Design Name: 
// Module Name: ram
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


module ram(
    input logic clk,
    input logic reset,
    input logic write_enable,
    input logic [3:0] addr,
    input logic [1:0] write_data,
    output logic [1:0] read_data,
    output logic [17:0] board        // board stores 9 cells x 2 bits
);
    
    // storing 2-bits of data: 01 or 10 (cols)
    // we have 9 possible places to put in our board (rows)
    logic [1:0] RAM [8:0];
    
    always_ff @(posedge clk) begin
        if (reset) begin
            RAM[0] <= 2'b0;
            RAM[1] <= 2'b0;
            RAM[2] <= 2'b0;
            RAM[3] <= 2'b0;
            RAM[4] <= 2'b0;
            RAM[5] <= 2'b0;
            RAM[6] <= 2'b0;
            RAM[7] <= 2'b0;
            RAM[8] <= 2'b0;
        end
        
        else if (write_enable) RAM[addr] <= write_data;
//        read_data <= RAM[addr];
    end
    
    assign read_data = RAM[addr];
    
    assign board = {
        RAM[8], RAM[7], RAM[6],
        RAM[5], RAM[4], RAM[3],
        RAM[2], RAM[1], RAM[0]
    };

endmodule
