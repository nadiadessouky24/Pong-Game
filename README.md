# **Pong Game using Verilog and Basys 3 board**

This is a github repository for a 2 player pong game written in Verilog and uses a Basys 3 board. 
Two padels and a ball will appear on the screen and the players can control the padels using the buttons
on the Basys 3 Board. They users will be able to see the score on the seven-segment display.

## **Prerequisites to run the game**
* Having Vivado or any software for running verilog
* Basys 3 Board and VGA cable

## **Usage**
1. Clone the github repo
2. Create a new project and a adding all source files and the constraint file 
3. Generating bitstream
4. Open hardware manager and connect the Basys 3 board
5.  Program the device
6.  Use the push buttons to control the padels. 

## **Modules Used**

**Top.v:** This module instantiates all other modules and connects them together. 

**pixel_gen.v:** This modules controls everything that appears on the screen. In this module, the Padels are render and their movement, using the push buttons, is defined. Moreover, the ball movement and color is also defined.
In addition to that, the scoring logic is also defined here. If the ball hits the padel, the respective players score is incremented. 
             
**SSDisplay.v:** This module contains all thats necessary for displaying the score on the seven segment display. 

**Debounce.v:** This module create a delay necessary to synchronize the button click. 

**vga_controller.v:** This module sets up the environment necessary for using a VGA, which connects the Basys 3 board to the monitor. 

## **Demo of the  project** 



https://github.com/user-attachments/assets/b8f5c433-59c1-46cf-839a-5eb0c38c4cdc

## **Authors**

**Nadia Dessouky**

**Aisha Kandeel**
