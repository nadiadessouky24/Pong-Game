`timescale 1ns / 1ps

module pixel_gen(
    input clk,  
    input reset,    
    input up1,      
    input down1,  
    input up2,     
    input down2,    
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output reg [11:0] rgb,
    output reg [3:0] player1_score,
    output reg [3:0] player2_score 
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    // PADDLE
    // Player 1 Paddle (left)
    parameter X_PAD_L1 = 32;    
    parameter X_PAD_R1 = 39; 
    
    // Player 2 Paddle (right)
    parameter X_PAD_L2 = 600;  
    parameter X_PAD_R2 = 603;    // 4 pixels wide 
    
    // paddle vertical boundary signals
    wire [9:0] y_pad_t1, y_pad_b1, y_pad_t2, y_pad_b2;
    parameter PAD_HEIGHT = 72;  // 72 pixels high
    // register to track top boundary and buffer
    reg [9:0] y_pad_reg1, y_pad_reg2, y_pad_next1, y_pad_next2;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
    
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball velocity
    parameter BALL_VELOCITY_POS = 2;
    parameter BALL_VELOCITY_NEG = -2;
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    //flags for scoring logic 
    reg scored1, scored2;

    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            y_pad_reg1 <= 0;
            y_pad_reg2 <= 0;
            x_ball_reg <= 0;
            y_ball_reg <= 0;
            x_delta_reg <= 10'h002;
            y_delta_reg <= 10'h002;
        end
        else begin
            y_pad_reg1 <= y_pad_next1;
            y_pad_reg2 <= y_pad_next2;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    // ball rom
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; 
            3'b010 :    rom_data = 8'b11111111; 
            3'b011 :    rom_data = 8'b11111111;
            3'b100 :    rom_data = 8'b11111111; 
            3'b101 :    rom_data = 8'b11111111;
            3'b110 :    rom_data = 8'b01111110; 
            3'b111 :    rom_data = 8'b00111100; 
        endcase
    
    // OBJECT STATUS SIGNALS
    wire pad_on1, pad_on2, sq_ball_on, ball_on;
    wire [11:0] pad_rgb, ball_rgb, bg_rgb;
    
    // assign object colors
    assign pad_rgb = 12'hAAA;      
    assign ball_rgb = 12'hFFF;      
    assign bg_rgb = 12'h111;      
    
    // paddle 1 (Player 1)
    assign y_pad_t1 = y_pad_reg1;                             // paddle top position
    assign y_pad_b1 = y_pad_t1 + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on1 = (X_PAD_L1 <= x) && (x <= X_PAD_R1) &&     // pixel within paddle boundaries
                    (y_pad_t1 <= y) && (y <= y_pad_b1);
                    
    // paddle 2 (Player 2)
    assign y_pad_t2 = y_pad_reg2;                             // paddle top position
    assign y_pad_b2 = y_pad_t2 + PAD_HEIGHT - 1;              // paddle bottom position
    assign pad_on2 = (X_PAD_L2 <= x) && (x <= X_PAD_R2) &&     // pixel within paddle boundaries
                    (y_pad_t2 <= y) && (y <= y_pad_b2);
                    
    // Paddle Control
    always @* begin
        y_pad_next1 = y_pad_reg1;     // no move
        if(refresh_tick)
            if(up1 & (y_pad_t1 > PAD_VELOCITY))
                y_pad_next1 = y_pad_reg1 - PAD_VELOCITY;  // move up for Player 1
            else if(down1 & (y_pad_b1 < (Y_MAX - PAD_VELOCITY)))
                y_pad_next1 = y_pad_reg1 + PAD_VELOCITY;  // move down for Player 1
    end
    
    always @* begin
        y_pad_next2 = y_pad_reg2;     // no move
        if(refresh_tick)
            if(up2 & (y_pad_t2 > PAD_VELOCITY))
                y_pad_next2 = y_pad_reg2 - PAD_VELOCITY;  // move up for Player 2
            else if(down2 & (y_pad_b2 < (Y_MAX - PAD_VELOCITY)))
                y_pad_next2 = y_pad_reg2 + PAD_VELOCITY;  // move down for Player 2
    end
    
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
    // new ball position
    assign x_ball_next = (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    // change ball direction after collision
    always @* begin
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        if(y_ball_t < 1)                                            // collide with top
            y_delta_next = BALL_VELOCITY_POS;                       // move down
        else if(y_ball_b > Y_MAX)                                   // collide with bottom
            y_delta_next = BALL_VELOCITY_NEG;                       // move up
        else if(x_ball_l <= X_PAD_R1)                               // collide with left paddle
            x_delta_next = BALL_VELOCITY_POS;                       // move right
        else if(x_ball_r >= X_PAD_L2)                               // collide with right paddle
            x_delta_next = BALL_VELOCITY_NEG;                       // move left
    end                    
    
     //rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // no value, blank
        else
            if(pad_on1)
                rgb = pad_rgb;      // Player 1 paddle color
            else if(pad_on2)
                rgb = pad_rgb;      // Player 2 paddle color
            else if(ball_on)
                rgb = ball_rgb;     // ball color
            else
                rgb = bg_rgb;       // background
      //detect if ball crosses the left or right boundary 
      
   //scoring    
    always @(posedge clk or posedge reset) begin
          if (reset) begin
              player1_score <= 4'd0;
              player2_score <= -4'd1;
              scored1 <= 1'b0;
              scored2 <= 1'b0;
          end else begin
              // Player 1 scoring logic
              if ((x_ball_r >= X_PAD_L2) && (y_ball_b >= y_pad_t2) && (y_ball_t <= y_pad_b2)) begin
                  if (!scored1) begin
                      player1_score <= player1_score + 1;
                     scored1 <= 1'b1; // Set scored1 to prevent repeated scoring
                  end
              end else begin
                  scored1 <= 1'b0; // Reset flag 
                  end
      
              // Player 2 scoring logic
              if ((x_ball_l <= X_PAD_R1) && (y_ball_b >= y_pad_t1) && (y_ball_t <= y_pad_b1)) begin
                  if (!scored2) begin
                      player2_score <= player2_score + 1;
                      scored2 <= 1'b1; // Set scored2 to prevent repeated scoring
                  end
              end else begin
                  scored2 <= 1'b0; // Reset flag 
              end
          end
      end


endmodule