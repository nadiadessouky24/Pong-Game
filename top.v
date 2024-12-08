//pixel gen
module top(
    input clk_100MHz,       
    input reset,           
    input up1,           
    input down1,        
    input up2,              
    input down2,           
    output hsync,           // Horizontal sync signal for VGA
    output vsync,           // Vertical sync signal for VGA
    output [11:0] rgb,       // RGB output for VGA display
    output [3:0] Anode,
    output [6:0] Led_out
    );
    wire [3:0] player1_score;
    wire [3:0] player2_score;
    wire x;
    wire w_reset, w_up1, w_down1, w_up2, w_down2, w_vid_on, w_p_tick;
    wire [9:0] w_x, w_y;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next1, rgb_next2;
    wire [11:0] rgb_combined;
    
    // VGA controller instance for managing VGA timing and pixel coordinates
    vga_controller vga(
        .clk_100MHz(clk_100MHz), 
        .reset(w_reset), 
        .video_on(w_vid_on),
        .hsync(hsync), 
        .vsync(vsync), 
        .p_tick(w_p_tick), 
        .x(w_x), 
        .y(w_y)
    );
    
    pixel_gen pg(
    .clk(clk_100MHz), 
    .reset(w_reset), 
    .up1(w_up1),      
    .down1(w_down1),   
    .up2(w_up2), 
    .down2(w_down2),
    .video_on(w_vid_on), 
    .x(w_x), 
    .y(w_y), 
    .rgb(rgb_next2),
    .player1_score(player1_score),
    .player2_score(player2_score)
);


    SSDisplay ss_display_inst(
        .clk(clk_100MHz),        
        .num1(player1_score),      
        .num2(player2_score),   
        .Anode(Anode),            
        .LED_out(Led_out)           
    );
    // Debounce logic for reset button
    debounce dbR(
        .clk(clk_100MHz), 
        .btn_in(reset), 
        .btn_out(w_reset)
    );
    
    // Debounce logic for Player 1 paddle controls
    debounce dbU1(
        .clk(clk_100MHz), 
        .btn_in(up1), 
        .btn_out(w_up1)
    );

    debounce dbD1(
        .clk(clk_100MHz), 
        .btn_in(down1), 
        .btn_out(w_down1)
    );

    // Debounce logic for Player 2 paddle controls
    debounce dbU2(
        .clk(clk_100MHz), 
        .btn_in(up2), 
        .btn_out(w_up2)
    );

    debounce dbD2(
        .clk(clk_100MHz), 
        .btn_in(down2), 
        .btn_out(w_down2)
    );

    // Combine RGB values for Player 1 and Player 2 paddles
    assign rgb_combined = rgb_next1 | rgb_next2;

    // RGB output register to hold the final RGB value
    always @(posedge clk_100MHz)
        if(w_p_tick)
            rgb_reg <= rgb_combined;

    // Assign RGB value to output
    assign rgb = rgb_reg;
    
endmodule 