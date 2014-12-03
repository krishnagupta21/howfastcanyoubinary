
The code is written by Sagnik Roy and Krishna Gupta for the final project of the course ECE241 at University of Toronto.

This code describes the hardware implementation of the game ‘How fast can you binary?’. The coding is done using Verilog HDL and the FPGA synthesis is done using the Altera DE2 board. The goal of the game is to improve players’ integer to binary conversion skills. 

To play the game the player has to enter the binary equivalent (using the DE2 board) of the integer on the screen within a given time. If the player fails to do so, the number will settle at the bottom of the screen in a bucket. If the player inputs the correct answer, the box with the integer will disappear. The game is over once 5 boxes are in the bucket. The difficulty increases automatically with the players score or the player can change the difficulty manually at any time during the game. This implementation of the game describes four difficulty levels. The levels are as follows-

- Beginner - Only 4 bit numbers
- Intermediate- Only 4 bit numbers at a faster speed
- Advanced - Both 4 bit and 5 bit numbers
- Super-  Both 4 bit and 5 bit numbers at a faster speed

This is an original game and no implementation of a similar game can be found on the internet. The motivation behind the game was to improve this very essential skill in students studying Digital Electronics or a related course. This game also improves focus and concentration. The most important part of the project is that it makes learning fun for every player. Also, students of any level can play the game. 

Here are a few screenshots-
![alt tag](http://postimg.org/image/sr5pkv4mt/)
![alt tag](http://postimg.org/image/sjxlo3rv5/)
![alt tag](http://postimg.org/image/jt833mssv/)

