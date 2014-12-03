// Animation

module animation
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,
		HEX0,
		HEX1,
		//HEX2,
		//HEX3,
		HEX4,
		HEX5,
		LEDR,
		LEDG,
		KEY,							//	Push Button[3:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					//	Button[3:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	input [17:0] SW;
	output [6:0] HEX0, HEX1, HEX4, HEX5;
	output [0:0] LEDG;
	output [17:0] LEDR;
	
	wire clk;
	
	wire resetn;
	wire clear;
	reg draw;	//"handshake" variable between [the DRAW in the Master FSM] and [the Clear/Draw FSM]
	
	assign clear = KEY[0];
	assign StartDraw = KEY[1];
	assign resetn = KEY[2];
	assign clk = KEY[3];
	
	reg ledrwire;
	
	reg[6:0] compare_number = 7'd0;

	reg [2:0] num_of_boxes = 3'b000;
	reg[27:0] timedelay;
	reg [2:0] prev_num_of_boxes = 3'b000;
	reg [7:0] scoreCounter, score_with_BOOL;


	parameter Wait = 4'b0000, Xc = 4'b0001, Yc = 4'b0010, Xd = 4'b0011, Yd = 4'b0100, Done = 4'b0101, Count_1_sec = 4'b0110, Check = 4'b0111, Finish = 4'b1000, DELETE_ALLx = 4'b1001, DELETE_ALLy = 4'b1010;
	
	wire [2:0] color;
	wire [7:0] x;
	wire [6:0] y;
	reg [3:0] y_Q, y_D;
	reg [7:0] x_out;
	reg [6:0] y_out;
	reg [8:0] address;
	reg [2:0] color_out;
	wire [2:0] color_1,color_2,color_3,color_4,color_5,color_6,color_7,color_8,color_9,color_10,color_11,color_12,color_13,color_14,color_15,color_16,color_17,color_18,color_19,color_20,color_21,color_22,color_23,color_24,color_25,color_26,color_27,color_28,color_29,color_30,color_31,color_gameover;
	reg [2:0] color_final;
	reg [28:0] counter_1_sec;
	reg reached_bottom;	//"boolean" type that tells us if we've reached the bottom of the bucket
								//2nd "handshake" variable, that sends us back to the Master Animator FSM
	
	reg writeEn;
	reg [7:0] x_in = 8'b00110111;
	reg [6:0] y_in = 7'b0010000;

always@ (posedge reached_bottom /*, posedge ledrwire*/)		//changed the if statements from !StartDraw and posedge clk
	begin
		case(prev_num_of_boxes)
			3'b000:
				begin
				if(StartDraw) num_of_boxes <= 3'b001;
				else num_of_boxes <= 3'b000;
				end
			3'b001:
				begin
				if(StartDraw) num_of_boxes <= 3'b010;
				else num_of_boxes <= 3'b001;
				end
			3'b010:
				begin
				if(StartDraw) num_of_boxes <= 3'b011;
				else num_of_boxes <= 3'b010;
				end
			3'b011:
				begin
				if(StartDraw) num_of_boxes <= 3'b100;
				else num_of_boxes <= 3'b011;
				end
			3'b100:
				begin
				if(StartDraw) num_of_boxes <= 3'b101;
				else num_of_boxes <= 3'b100;
				end
			3'b101:
				begin				
				 num_of_boxes <= 3'b110;
				end
			3'b110:
				begin
					if(StartDraw) num_of_boxes <= 3'b000;
					else num_of_boxes <= 3'b110;
				end
					
			default: num_of_boxes <= 3'b000;
		endcase
	end
	
		always@ (*)
	begin
		case(prev_num_of_boxes)
			3'b000:
				begin
				compare_number = 7'd95;
				end
			3'b001:
				begin
				compare_number = 7'd85;
				end
			3'b010:
				begin
				compare_number = 7'd75;
				end
			3'b011:
				begin
				compare_number = 7'd65;
				end
			3'b100:
				begin
				compare_number = 7'd55;
				end
			3'b101:
				begin
				//compare_number = 7'd45;
				end
		endcase
	end
	
	always@(posedge CLOCK_50)
		prev_num_of_boxes <= num_of_boxes;

//************************** Beginning of Code for Drawing/Clearing ************************
	always@(*)
	begin
			case(y_Q)
				Wait:
				begin
						//if(reached_bottom == 1) y_D = Wait;
						if(num_of_boxes == 3'b110) y_D = Finish;
						else if(!StartDraw | reached_bottom) 
						begin
								y_D = Xd;
						end							
						else y_D = Wait;
				end
				
				Xc:
				begin
						if(x_out==(x_in + 8'b00110011))y_D = Yc; //51
						else y_D = Xc;
				end
				
				Yc:
				begin
						if(y_out==(y_in + 4'b1001))	//9
						begin 
								if(!StartDraw && checkBOOL==1) y_D = Wait;
								else 
								begin
									y_D = Check;
								end
						end
						else	y_D = Xc;							
				end
				Xd:
				begin
						if(x_out == (x_in + 8'b00110010)) //51
							y_D = Yd;

						else y_D = Xd;
				end
				Yd:
				begin
						if(y_out == (y_in + 4'b1001)) //9
							y_D = Count_1_sec;							
						else 
							y_D = Xd;
				end
					
				Count_1_sec:		//state that waits <timedelay> seconds before deleting the box
				begin
						if(y_in + 1 == compare_number) y_D = Wait;
						else if(counter_1_sec == timedelay) y_D = Xc;
						else y_D = Count_1_sec;
				end
					
				Check:
				begin
						if(y_in == compare_number) y_D = Wait;
						else y_D = Xd;
				end
				
				Finish:
				begin
					if(!StartDraw) y_D = DELETE_ALLx;
					else	y_D = Finish;
				end
				
				DELETE_ALLx:
				begin
						if(x_out==(x_in + 8'b00110011))y_D = DELETE_ALLy; //51
						else y_D = DELETE_ALLx;
				end
				
				DELETE_ALLy:
				begin
						if(y_out==(y_in + 7'b1010111))	//54
						begin 
									y_D = Wait;
						end
						else	y_D = DELETE_ALLx;							
				end
					
				default: y_D = Wait;

				endcase
		end
		
	always@(posedge CLOCK_50)		//register making y_Q = y_D
		y_Q <= y_D;
	
//******************** Actual stuff done by the States ***************************	
	always@(posedge CLOCK_50)
		begin		
			case(y_Q)
				Wait: 
					begin
						//if(reached_bottom == 1) reached_bottom <= 1;
						ledrwire <= 0;
						if(num_of_boxes == 3'b110) reached_bottom <= 0;
						else if(!StartDraw | reached_bottom)
						begin
							writeEn <= 0;
							//color_out <= color_final;
							address <= 0;
							if(score_with_BOOL>10'd90)
								timedelay = 28'd500000;
							else if(score_with_BOOL>10'd75)
								timedelay = 28'd1500000;
							else if(score_with_BOOL>10'd50)
								timedelay = 28'd2000000;
							else
							begin
								if(SW[16])
									timedelay = 28'd2500000;
								else 
									timedelay = 28'd5000000;
							end
							
							x_out <= x_in;
							y_out <= y_in;
							counter_1_sec <= 0;
							reached_bottom <= 0;							
						end
						else
						begin
							counter_1_sec <= 0;
							reached_bottom <= 0;
							score_with_BOOL <= 0;
						end
					end
						
				Xc:
					begin
						if(x_out==(x_in + 8'b00110011)) //51
							begin
								writeEn <= 0;
								//x_out <= x_in;
							end
						
						else
							begin
								writeEn <= 1;
								color_out <= 3'b0;								
								x_out <= x_out + 1'b1;
								
							end
					end
				Yc:
					begin
						if(y_out==(y_in + 4'b1001)) //9
							begin
							if(bitSWITCH)
							begin
								if(RANDOM_INTEGER5bit[0] == userinput1 && RANDOM_INTEGER5bit[1] == userinput2 && RANDOM_INTEGER5bit[2] == userinput3 && RANDOM_INTEGER5bit[3] == userinput4 && RANDOM_INTEGER5bit[4] == userinput5 )//&& RANDOM_INTEGER!=0)
								begin
									checkBOOL <= 1;
									greenlight <=1;
									redlight<=0;									
								end
								else
								begin
									checkBOOL <= 0;
									greenlight <= 0;
									redlight <= 1;
								end
							end
							else if(!bitSWITCH)
							begin
								if(RANDOM_INTEGER4bit[0] == userinput1 && RANDOM_INTEGER4bit[1] == userinput2 && RANDOM_INTEGER4bit[2] == userinput3 && RANDOM_INTEGER4bit[3] == userinput4 )//&& RANDOM_INTEGER!=0)
								begin
									checkBOOL <= 1;
									greenlight <=1;
									redlight<=0;									
								end
								else
								begin
									checkBOOL <= 0;
									greenlight <= 0;
									redlight <= 1;
								end
							end
								if(!StartDraw && checkBOOL==1)	//if the answer inputted is CORRECT and KEY is pressed
								begin
									x_in <= 8'b00110111;
									y_in <= 7'b0010000;
									y_out <= y_in;
									checkBOOL <= 0;
									if (score_with_BOOL == 8'd100 | num_of_boxes == 3'b101) score_with_BOOL<=0;
									else score_with_BOOL <= score_with_BOOL + 1;
								end
								else  y_in <= y_in + 1;
								//y_out <= y_in;
							end
						else
							begin
								writeEn <= 1;
								color_out <= 3'b0;
								y_out <= y_out + 1'b1;
								x_out <= x_in;								
							end							
					end
						
				Xd:
					begin
						if(x_out != (x_in + 8'b00110010)) //51
							begin
								color_out <= color_final;
								address <= address + 1;	
								writeEn <= 1;
								x_out <= x_out + 1'b1;
							end
					end
						
				Yd:
					begin
						if(y_out == (y_in + 4'b1001)) //9
						begin
								y_out<=y_in;
								writeEn <= 0;
						end
							
						else 
							begin
								color_out <= color_final;
								writeEn <= 0;
								address <= address + 1;
								y_out <= y_out + 1'b1;
								x_out <= x_in;
							end
				
					end
					
				Count_1_sec:
					begin
						if (y_in + 1 == compare_number)
						begin
									reached_bottom <= 1;
									x_in <= 8'b00110111;
									y_in <= 7'b0010000;
									y_out <= y_in;
						end
						else if(counter_1_sec == timedelay)
						begin
							x_out <= x_in;
							y_out <= y_in;
							counter_1_sec <= 0;
						end
						else counter_1_sec <= counter_1_sec + 1;
					end
					
				Check:		//checks to see if the box has reached the bottom of the bucket or not
						begin
							if(y_in == compare_number)
								begin
									reached_bottom <= 1;
									x_in <= 8'b00110111;
									y_in <= 7'b0010000;
								end
							else 
								begin
									reached_bottom <= 0;
									writeEn <= 0;
									color_out <= color_1;
									address <= 0;
									x_out <= x_in;
									y_out <= y_in;
									counter_1_sec <= 0;
								end
						end
					Finish:
						begin
							if(!StartDraw)
							begin
								score_with_BOOL <= 0;
								x_out <= x_in;
								y_out <= y_in;
							end
							reached_bottom <= 1;
							ledrwire <= 1;
						end
					
					DELETE_ALLx:
					begin
						ledrwire <= 0;
						if(x_out==(x_in + 8'b00110011)) //51
							begin
								writeEn <= 0;
								//x_out <= x_in;
							end
						
						else
							begin
								writeEn <= 1;
								color_out <= 3'b000;								
								x_out <= x_out + 1'b1;
								
							end
					end
					
					DELETE_ALLy:
					begin
						if(y_out!=(y_in + 7'b1010111)) //54
							begin
								writeEn <= 1;
								color_out <= 3'b000;
								y_out <= y_out + 1'b1;
								x_out <= x_in;								
							end
					end
			endcase
		end

	assign color = color_out;
	assign x = x_out;
	assign y = y_out;
	assign LEDR[0] = ledrwire;
	
	one _one(address,CLOCK_50,color_1);
	two _two(address,CLOCK_50,color_2);
	three _three(address,CLOCK_50,color_3);
	four _four(address,CLOCK_50,color_4);
	five _five(address,CLOCK_50,color_5);
	six _six(address,CLOCK_50,color_6);
	seven _seven(address,CLOCK_50,color_7);
	eight _eight(address,CLOCK_50,color_8);
	nine _nine(address,CLOCK_50,color_9);
	ten _ten(address,CLOCK_50,color_10);
	eleven _eleven(address,CLOCK_50,color_11);
	twelve _twelve(address,CLOCK_50,color_12);
	thirteen _thirteen(address,CLOCK_50,color_13);
	fourteen _fourteen(address,CLOCK_50,color_14);
	fifteen _fifteen(address,CLOCK_50,color_15);
	sixteen _sixteen(address, CLOCK_50, color_16);
	seventeen _seventeen(address, CLOCK_50, color_17);
	eighteen _eighteen(address, CLOCK_50, color_18);
	nineteen _nineteen(address, CLOCK_50, color_19);
	twenty _twenty(address, CLOCK_50, color_20);
	twentyone _twentyone(address, CLOCK_50, color_21);
	twentytwo _twentytwo(address, CLOCK_50, color_22);
	twentythree _twentythree(address, CLOCK_50, color_23);
	twentyfour _twentyfour(address, CLOCK_50, color_24);
	twentyfive _twentyfive(address, CLOCK_50, color_25);
	twentysix _twentysix(address, CLOCK_50, color_26);
	twentyseven _twentyseven(address, CLOCK_50, color_27);
	twentyeight _twentyeight(address, CLOCK_50, color_28);
	twentynine _twentynine(address, CLOCK_50, color_29);
	thirty _thirty(address, CLOCK_50, color_30);
	thirtyone _thirtyone(address, CLOCK_50, color_31);
	gameover _gameover(address,CLOCK_50,color_gameover);

//output_display_whole display_random(RANDOM_INTEGER, HEX0);	//outputs RANDOM_INTEGER
wire userinput1,userinput2,userinput3,userinput4,userinput5;

reg checkBOOL;
reg [4:0] RANDOM_INTEGER;
reg [4:0] RANDOM_INTEGER5bit;
reg [3:0] RANDOM_INTEGER4bit;
reg [5:0] counter;

reg greenlight,redlight;
//reg [3:0]score;

assign userinput1 = SW[0];
assign userinput2 = SW[1];
assign userinput3 = SW[2];
assign userinput4 = SW[3];
assign userinput5 = SW[4];

assign LEDG[0] = greenlight;
assign LEDR[17] = redlight;
reg [3:0]counter4bit;

always@(posedge CLOCK_50)
	begin
		
		if(counter == 5'd31) counter <=1;
		else counter <= counter +1;
			
		if(counter4bit == 4'd15) counter4bit <=1;
		else counter4bit <= counter4bit +1;
			
		if((!StartDraw && checkBOOL == 1) | (reached_bottom == 1))	//if the correct answer is entered OR
		begin																			//the box reaches the bottom of the bucket
			RANDOM_INTEGER5bit <=counter;										//a new number is generated
			RANDOM_INTEGER4bit <=counter4bit;
		end		
	end
reg bitSWITCH;
	
always@(posedge reached_bottom)		//everytime KEY[1]/StartDraw is pressed, or the current box reaches the bottom
begin																						//the value of bitSWITCH changes to SWITCH[17]
	if(checkBOOL) bitSWITCH <= SW[17];
	else bitSWITCH <= SW[17];
end
	
	
always@(*)
	begin	
	if(bitSWITCH)
		RANDOM_INTEGER = RANDOM_INTEGER5bit;
	else
		RANDOM_INTEGER = RANDOM_INTEGER4bit;
	
	if(RANDOM_INTEGER == 0) RANDOM_INTEGER = 1;
 
//******************* Outputting the correct boxes depending on the value of RANDOM_INTEGER******************
		if(num_of_boxes == 3'b101)
		begin
			RANDOM_INTEGER = 0;
			color_final = color_gameover;
		end
		else
		begin
	//if(SW[17])
		//begin
		if(RANDOM_INTEGER == 5'b00001)
			color_final = color_1;
		else if(RANDOM_INTEGER == 5'b00010)
			color_final = color_2;
		else if(RANDOM_INTEGER == 5'b00011)
			color_final = color_3;
		else if(RANDOM_INTEGER == 5'b00100)
			color_final = color_4;
		else if(RANDOM_INTEGER == 5'b00101)
			color_final = color_5;
		else if(RANDOM_INTEGER == 5'b00110)
			color_final = color_6;
		else if(RANDOM_INTEGER == 5'b00111)
			color_final = color_7;
		else if(RANDOM_INTEGER == 5'b01000)
			color_final = color_8;
		else if(RANDOM_INTEGER == 5'b01001)
			color_final = color_9;
		else if(RANDOM_INTEGER == 5'b01010)
			color_final = color_10;
		else if(RANDOM_INTEGER == 5'b01011)
			color_final = color_11;
		else if(RANDOM_INTEGER == 5'b01100)
			color_final = color_12;
		else if(RANDOM_INTEGER == 5'b01101)
			color_final = color_13;
		else if(RANDOM_INTEGER == 5'b01110)
			color_final = color_14;
		else if(RANDOM_INTEGER == 5'b01111)
			color_final = color_15;
		else if(RANDOM_INTEGER == 5'b10000)
			color_final = color_16;
		else if(RANDOM_INTEGER == 5'b10001)
			color_final = color_17;
		else if(RANDOM_INTEGER == 5'b10010)
			color_final = color_18;
		else if(RANDOM_INTEGER == 5'b10011)
			color_final = color_19;
		else if(RANDOM_INTEGER == 5'b10100)
			color_final = color_20;
		else if(RANDOM_INTEGER == 5'b10101)
			color_final = color_21;
		else if(RANDOM_INTEGER == 5'b10110)
			color_final = color_22;
		else if(RANDOM_INTEGER == 5'b10111)
			color_final = color_23;
		else if(RANDOM_INTEGER == 5'b11000)
			color_final = color_24;
		else if(RANDOM_INTEGER == 5'b11001)
			color_final = color_25;
		else if(RANDOM_INTEGER == 5'b11010)
			color_final = color_26;
		else if(RANDOM_INTEGER == 5'b11011)
			color_final = color_27;
		else if(RANDOM_INTEGER == 5'b11100)
			color_final = color_28;
		else if(RANDOM_INTEGER == 5'b11101)
			color_final = color_29;
		else if(RANDOM_INTEGER == 5'b11110)
			color_final = color_30;
		else if(RANDOM_INTEGER == 5'b11111)
			color_final = color_31;
	//end
	/*else if(!SW[17])
	begin
		if(RANDOM_INTEGER4bit == 4'b0001)
			color_final = color_1;
		else if(RANDOM_INTEGER4bit == 5'b00010)
			color_final = color_2;
		else if(RANDOM_INTEGER4bit == 5'b00011)
			color_final = color_3;
		else if(RANDOM_INTEGER4bit == 5'b00100)
			color_final = color_4;
		else if(RANDOM_INTEGER4bit == 5'b00101)
			color_final = color_5;
		else if(RANDOM_INTEGER4bit == 5'b00110)
			color_final = color_6;
		else if(RANDOM_INTEGER4bit == 5'b00111)
			color_final = color_7;
		else if(RANDOM_INTEGER4bit == 5'b01000)
			color_final = color_8;
		else if(RANDOM_INTEGER4bit == 5'b01001)
			color_final = color_9;
		else if(RANDOM_INTEGER4bit == 5'b01010)
			color_final = color_10;
		else if(RANDOM_INTEGER4bit == 5'b01011)
			color_final = color_11;
		else if(RANDOM_INTEGER4bit == 5'b01100)
			color_final = color_12;
		else if(RANDOM_INTEGER4bit == 5'b01101)
			color_final = color_13;
		else if(RANDOM_INTEGER4bit == 5'b01110)
			color_final = color_14;
		else if(RANDOM_INTEGER4bit == 5'b01111)
			color_final = color_15;
	end*/
		end
	end
	
	//******************Code for SCORE and HEX displays******************
	//output [6:0]HEX2, HEX3;
	/*
	always@(posedge checkBOOL,posedge ledrwire)
	begin
		if (score_with_BOOL == 8'd100 | num_of_boxes == 3'b101) score_with_BOOL<=0; //score_with_BOOL == 8'd100 | num_of_boxes == 3'b101
		else score_with_BOOL <= score_with_BOOL + 1;
	end
	
	
	always@(*)
	begin
		if (!KEY[1])scoreCounter <= score_with_BOOL;
	end
	*/

	display_on_HEX SCORE(score_with_BOOL, CLOCK_50, HEX4, HEX5);
	display_on_HEX random_integer(RANDOM_INTEGER, CLOCK_50, HEX0, HEX1);
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "bg.mif";
endmodule

module display_on_HEX(score, clock, HEX2, HEX3);

	input [13:0]score;
	input clock;
	output [6:0]HEX2, HEX3;
	
	reg [13:0]digit2, digit3;
	
	always@(posedge clock)
	begin 
		if(score == 8'd100)
		begin
			digit2 <= 13'b0;
			digit3 <= 13'b0;
		end
		else
		begin
			digit2  <= score / 4'b 1010;//10
			digit3  <= score % 4'b 1010;
		end
	end
	displayScoreOnHEX h2(digit2, HEX3, clock);
	displayScoreOnHEX h3(digit3, HEX2, clock);
	endmodule
	
module displayScoreOnHEX(digit, h, clock);
	
	input [13:0] digit;
	input clock;
	output reg [6:0] h;
	
	wire [6:0] zero, one, two, three, four, five, six, seven, eight, nine;
	assign zero = 7'b 0111111;
	assign one = 7'b 0000110;
	assign two = 7'b 1011011;
	assign three = 7'b 1001111;
	assign four = 7'b 1100110;
	assign five = 7'b 1101101;
	assign six = 7'b 1111101;
	assign seven = 7'b 0000111;
	assign eight = 7'b 1111111;
	assign nine = 7'b 1100111;
	
	
	
	always@(posedge clock)
	begin
		if(digit == 13'b 0000)
		begin
			h <= ~zero;
		end
		
		else if(digit == 13'b 0001)
		begin
				h <= ~one;
		end
		
		else if(digit == 13'b 0010)
		begin
				h <= ~two;
		end
		
		else if(digit == 13'b 0011)
		begin
		h <= ~three;
		end
		
		else if(digit == 13'b 0100)
		begin
		h <= ~four;
		end
		
		else if(digit == 13'b 0101)
		begin
		h <= ~five;
		end
		
		else if(digit == 13'b 0110)
		begin
		h <= ~six;
		end
		
		else if(digit == 13'b 0111)
		begin
		h <= ~seven;
		end
		
		else if(digit == 13'b 1000)
		begin
		h <= ~eight;
		end
		
		else if(digit == 13'b 1001)
		begin
		h <= ~nine;
		end
	end
	
endmodule
