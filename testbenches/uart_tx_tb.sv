`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/04/2026 03:22:04 PM
// Design Name: 
// Module Name: uart_tx_tb
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


module uart_tx_tb();
    parameter CLK_PERIOD = 10;
    parameter CLKS_PER_BIT = 868;
    parameter BIT_PERIOD = CLK_PERIOD * CLKS_PER_BIT; // BIT_PERIOD = 10 * 868 = 8680
    
    // Internal Signals
    logic clk = 0;              // System clock
    
    logic tx_data_valid = 0;    // Trigger signal to start transmission
    logic [7:0] tx_byte;        // byte we are transmitting
    logic tx_active;            // indicates we are currently transmitting
    logic tx_serial;            // serial output from TX
    logic tx_done;              // TX transmission complete
    
    logic rx_serial = 1;        // serial input to RX
    logic rx_data_valid;        // indicates RX has received a valid byte
    logic [7:0] rx_byte;        // byte received by RX
    
    logic uart_line;            // loopback wire connecting TX to RX
    
    // Instantiate UART RX UUT
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut_rx (
        .clk(clk),
        .reset(),
        .rx_serial(uart_line),
        .rx_data_valid(rx_data_valid),
        .rx_byte(rx_byte)
    );
    
    // Instantiate UART TX UUT
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) uut_tx (
        .clk(clk),
        .reset(),
        .tx_data_valid(tx_data_valid),
        .tx_byte(tx_byte),
        .tx_active(tx_active),
        .tx_serial(tx_serial),
        .tx_done(tx_done)
    );
    
    // Loopback connection: TX output → RX input
    // Keeps the UART Receiver input high (idle) when UART transmitter not active
    assign uart_line = tx_active ? tx_serial : 1'b1;
    
    // Clock Generation
    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end
    
        // Task to send a byte via TX and verify that RX receives it
    task UART_WRITE_BYTE (input [7:0] data);
        begin
            // Wait until rising edge of clk
            @(posedge clk);
            
            // Wait until tx_active is low
            @(posedge ~tx_active)
            tx_data_valid <= 1'b1;  // start transmission
            tx_byte <= data;
            @(posedge clk);         // hold for 1 clk cycle
            tx_data_valid <= 1'b0;  // finished transmission
            
//            // wait for TX to finish
//            @(posedge tx_done)
//            $display("TX transmission completed");
            
            // Wait for RX to receive the byte
            @(posedge rx_data_valid);
            
            if (rx_byte == data) $display("Test passed - Correct Byte Received");
            else $display("Test Failed = Incorrect Byte Received");
            
            // Wait some time before the next test
            repeat(10) @(posedge clk);
        end
    endtask
    
    // Test stimulus
    initial begin
        // reset values
//        tx_data_valid = 0;
//        tx_byte = 0;
            
        $display("=== UART TX/RX Testbench ===");
        UART_WRITE_BYTE(8'h3F);  // TX sends byte 0x3F
        UART_WRITE_BYTE(8'hFF);  // TX sends byte 0xFF
        UART_WRITE_BYTE(8'h42);  // TX sends byte 0x42
        UART_WRITE_BYTE(8'h6A);  // TX sends byte 0x6A
        $display("=== All tests completed ===");
        $finish();
    end
    
//    // Test Stimulus
//    initial begin
//        // Wait two clk cycles
//        @(posedge clk);
//        @(posedge clk);
        
//        // TX sends byte 0x3F
//        tx_data_valid <= 1'b1;  // start transmission
//        tx_byte <= 8'h3F;
//        @(posedge clk);         // hold for 1 clk cycle
//        tx_data_valid <= 1'b0;  // finished transmission
        
//        // Wait for RX to receive the byte
//        @(posedge rx_data_valid);
        
//        // Check that the correct command was received
//        if (rx_byte == 8'h3F) $display("Test passed - Correct Byte Received");
//        else $display("Test Failed = Incorrect Byte Received");
//        $finish();
//    end
    
    // Monitor for debugging, prints when any of the signals change
    initial $monitor("tx_byte: %b, tx_active: %b, tx_serial: %b, tx_done: %b, rx_byte: %b", 
        tx_byte,
        tx_active, 
        tx_serial,
        tx_done,
        rx_byte
    );
endmodule
