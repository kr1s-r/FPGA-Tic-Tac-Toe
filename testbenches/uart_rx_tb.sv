`timescale 1ns / 1ps // unit = ns, precision = ps (i.e. #100 = 100ns)
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2026 01:31:33 AM
// Design Name: 
// Module Name: uart_tb
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


module uart_rx_tb();
    // Parameters
    parameter CLK_PERIOD = 10; // 10ns for 100 MHz clock
    parameter CLOCKS_PER_BIT = 868;
    parameter BIT_PERIOD = CLK_PERIOD * CLOCKS_PER_BIT; // 10 * 868 = 8680
    
    // Internal signals
    logic clk = 0;
    logic reset = 1;
    logic rx_serial = 1;
    logic [7:0] rx_byte;
    
    // task: like a function but no return value and can contain delays
    // (1 start bit + 8 data bits + 1 stop bit) * 8680ns/bit = 86.8us for UART to process data
    task UART_WRITE_BYTE (input [7:0] data);
        
        begin
            // send start bit
            rx_serial <= 1'b0;
            #BIT_PERIOD;
            #1000;
            
            // send data byte
            for (int i = 0; i < 8; i=i+1) begin
                rx_serial <= data[i];
                $display("Sending bit: %b", data[i]);
                #BIT_PERIOD;
            end
            
            // send stop bit
            rx_serial <= 1'b1;
            #BIT_PERIOD;
        end
    endtask

    task PRESS_RESET();
        begin
            @(posedge clk);
            reset <= 1'b1;
            repeat(1000) @(posedge clk);
            reset <= 1'b0;
            @(posedge clk);
        end
    endtask
    
    // UUT
    uart_rx uut (
        .clk(clk),
        .reset(reset),
        .rx_serial(rx_serial),
        .rx_data_valid(),
        .rx_byte(rx_byte)
    );
    
    // Clock generation
    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end
    
    // Test stimulus
    initial begin
        // @(posedge clk); // wait until the rising edge of the clk to call task
        PRESS_RESET();
        UART_WRITE_BYTE(8'h37);
        @(posedge clk); // wait one more cycle after transmission completes to give time to finish processing
        
        if (rx_byte == 8'h37) $display("Test passed - Correct Byte Received");
        else $display("Test Failed - Incorrect Byte Received");

        PRESS_RESET();
        if (rx_byte == 8'h00) $display("Test passed - reset cleared rx_byte");
        else $display("Test Failed - reset did not clear rx_byte (%h)", rx_byte);

        UART_WRITE_BYTE(8'h5A);
        @(posedge clk);
        if (rx_byte == 8'h5A) $display("Test passed - Correct Byte Received");
        else $display("Test Failed - Incorrect Byte Received");

        $finish(); // end simulation
    end
    
endmodule
