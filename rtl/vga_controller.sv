// vga_controller.sv
// Drives a 640x480 @ 60Hz VGA signal using a 25 MHz pixel clock.
// Timing follows the VESA 640x480 standard - see timing breakdown below.
//
// Full horizontal line = 800 pixel clocks:
//   [  0 - 639 ]  640px  Active video
//   [ 640 - 655 ]  16px  Horizontal front porch
//   [ 656 - 751 ]  96px  Horizontal sync pulse (active-low)
//   [ 752 - 799 ]  48px  Horizontal back porch
//
// Full vertical frame = 525 lines:
//   [   0 - 479 ]  480 lines  Active video
//   [ 480 - 489 ]   10 lines  Vertical front porch
//   [ 490 - 491 ]    2 lines  Vertical sync pulse (active-low)
//   [ 492 - 524 ]   33 lines  Vertical back porch

module vga_controller #(
    parameter TOTAL_COLS = 800,
    parameter TOTAL_ROWS = 525
)
(
    input  logic        clk,    // 25 MHz clock
    input  logic        reset,
    input  logic [3:0]  red_in,
    input  logic [3:0]  green_in,
    input  logic [3:0]  blue_in,
    output logic        hsync,
    output logic        vsync,
    output logic [3:0]  red_out,
    output logic [3:0]  green_out,
    output logic [3:0]  blue_out
);
    
    // Internal Signals
    localparam int ACTIVE_COLS = 640;
    localparam int ACTIVE_ROWS = 480;
    
    logic [$clog2(TOTAL_COLS)-1:0] h_count;
    logic [$clog2(TOTAL_ROWS)-1:0] v_count;
    logic visible;
    
    // on rising edge of the clk: count h_count and v_count
    always_ff @(posedge clk) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
        end
        
        else begin
            if (h_count == TOTAL_COLS - 1) begin
                h_count <= 0;
                
                if (v_count == TOTAL_ROWS - 1) v_count <= 0;
                else v_count <= v_count + 1;
            end 
            
            else begin
                h_count <= h_count + 1;
            end
        end
    end
    
    // sync pulses are active-low => timings showed above
    // horizontal sync pulse is 96px
    // vertical sync pulse is 2px
    assign hsync   = ~(h_count >= 656 && h_count < 752);
    assign vsync   = ~(v_count >= 490 && v_count < 492);
    
    // screen is visible only in active area (within 640x480)
    assign visible = (h_count < 640) && (v_count < 480);

    assign red_out   = visible ? red_in : 4'h0;
    assign green_out = visible ? green_in : 4'h0;
    assign blue_out  = visible ? blue_in : 4'h0;

endmodule