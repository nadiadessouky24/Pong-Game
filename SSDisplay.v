`timescale 1ns / 1ps


module SSDisplay(
    input clk,
    input [3:0] num1,          // Player 1 score (first two digits)
    input [3:0] num2,          // Player 2 score (second two digits)
    output reg [3:0] Anode,
    output reg [6:0] LED_out
);
    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter = 0; // 20-bit counter
    wire [1:0] LED_activating_counter;

    always @(posedge clk)
    begin
        refresh_counter <= refresh_counter + 1;
    end
    assign LED_activating_counter = refresh_counter[19:18];

    wire [3:0] ones1;
    wire [3:0] tens1;
    wire [3:0] ones2;
    wire [3:0] tens2;

    BCD bcd1 (.num(num1), .Tens(tens1), .Ones(ones1));  // Convert Player 1's score to BCD
    BCD bcd2 (.num(num2), .Tens(tens2), .Ones(ones2));  // Convert Player 2's score to BCD

    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode = 4'b0111;       // Activate first digit
            LED_BCD = tens1;       // Display the tens digit for Player 1
        end
        2'b01: begin
            Anode = 4'b1011;       // Activate second digit
            LED_BCD = ones1;       // Display the ones digit for Player 1
        end
        2'b10: begin
            Anode = 4'b1101;       // Activate third digit
            LED_BCD = tens2;       // Display the tens digit for Player 2
        end
        2'b11: begin
            Anode = 4'b1110;       // Activate fourth digit
            LED_BCD = ones2;       // Display the ones digit for Player 2
        end
        endcase
    end

    always @(*)
    begin
        case(LED_BCD)
            4'b0000: LED_out = 7'b0000001; // "0"
            4'b0001: LED_out = 7'b1001111; // "1"
            4'b0010: LED_out = 7'b0010010; // "2"
            4'b0011: LED_out = 7'b0000110; // "3"
            4'b0100: LED_out = 7'b1001100; // "4"
            4'b0101: LED_out = 7'b0100100; // "5"
            4'b0110: LED_out = 7'b0100000; // "6"
            4'b0111: LED_out = 7'b0001111; // "7"
            4'b1000: LED_out = 7'b0000000; // "8"
            4'b1001: LED_out = 7'b0000100; // "9"
            default: LED_out = 7'b0000001; // "0"
        endcase
    end
endmodule
