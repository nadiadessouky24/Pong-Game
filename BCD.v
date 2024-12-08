`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 04:08:39 PM
// Design Name: 
// Module Name: BCD
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


module BCD(input [3:0] num,    // 4-bit input representing the score (0 to 15)
           output reg [3:0] Tens, // Tens place of the score (0 or 1)
           output reg [3:0] Ones  // Ones place of the score (0 to 9)
);
    always @(num) begin
        // Initialize Tens and Ones to 0
        Tens = 4'd0;
        Ones = num;  // Set Ones to the input number

        // If the number is 10 or greater, extract the Tens and Ones
        if (num >= 10) begin
            Tens = 4'd1;    // Tens place is 1 for values >= 10
            Ones = num - 10; // Subtract 10 from the input to get the Ones place
        end
    end
endmodule