// module mem(clk , write , addr , data_in , data_out) ; 
// 	parameter ADDR_Width = 12 , DATA_Width = 40 ; 

// 	input clk ; 
// 	input write ;
// 	input [ADDR_Width - 1 : 0] addr ;  
// 	input [DATA_Width - 1 : 0] data_in ; 
// 	output [DATA_Width - 1 : 0] data_out ; 

// 	output [DATA_Width - 1 : 0] data ; 

// 	reg [DATA_Width - 1 : 0] Mem [1024] ; 1

// 	initial 
// 	begin 
// 		Mem[0] = 
// 		Mem[1] = 
// 		Mem[2] = 
// 		Mem[3] = 
// 		Mem[4] = 
// 		Mem[5] = 
// 		Mem[6] = 
// 		Mem[7] = 
// 		Mem[8] = 
// 		Mem[9] = 
// 		Mem[10] = 
// 		Mem[11] = 
// 	end 

// 	always @(posedge clk) 
// 	begin 
// 		if(write)
// 		begin
// 			Mem[addr] <= data_in ; 
// 		end 
// 		else
// 		begin 
// 			data <= Mem[addr] ; 
// 		end 
// 	end
// 	assign data_out = data ; 

// endmodule 

module IAS(clk) ; 
	
	input clk ;

	reg [11:0] PC ;   
	reg [11:0] MAR ; 
	reg [19:0] IBR ; 
	reg [7:0] IR ; 
	reg [39:0] MBR ;
	reg [39:0] AC ; 
	reg [39:0] MQ ; 
	reg HALTED ; 
	reg [79:0] intermediate ;
	reg lefthalf ;  
	reg check ; 

	reg [39:0] Mem [0:1024] ; 

	initial 
	begin 
		Mem[0] = 40'b0000000000000000000000000000000000001111;
		Mem[1] = 40'b0000000000000000000000000000000000000101;
		Mem[2] = 40'b0000000000000000000000000000000000000000;
		Mem[3] = 40'b0000000100000000000000000110000000000001;
		Mem[4] = 40'b0000111100000000011000001101000000001000;
		Mem[5] = 40'b0000000000000000000000000000000000000000;
		Mem[6] = 40'b0000000100000000000000000110000000000001;
		Mem[7] = 40'b0010000100000000001000001110000000001010;
		Mem[8] = 40'b0000000100000000000000000101000000000001;
		Mem[9] = 40'b0010000100000000001011111111000000000000;
	end 


	parameter 	LOAD_MQ = 8'b00001010 , 
				LOAD_MQ_MX = 8'b00001001 , 
				STOR_MX = 8'b00100001 ,
				LOAD_MX = 8'b00000001 , 
				LOAD_neg_MX = 8'b0000010 , 
				LOAD_abs_MX = 8'b00000011 , 
				LOAD_neg_abs_MX = 8'b00000100 , 
				JUMP_MX_0to19 = 8'b00001101 , 
				JUMP_MX_20to39 = 8'b00001110 ,
				JUMP_plus_MX_0to19 = 8'b00001111 , 
				JUMP_plus_MX_20to39 = 8'b00010000 , 
				ADD_MX = 8'b00000101 , 
				ADD_abs_MX = 8'b00000111 , 
				SUB_MX = 8'b00000110 , 
				SUB_abs_MX = 8'b00001000 , 
				MUL_MX = 8'b00001011 ,
				LSH = 8'b00010100 , 
				RSH = 8'b00010101 , 
				STOR_MX_8to19 = 8'b00010010 , 
				STOR_MX_28to39 = 8'b00010011 ,  
				HALT = 8'b11111111 ;  

	// mem MEM(clk , write_mem , addr_mem , data_in_mem , data_out_mem) ; 

	initial
	begin 
		PC <= 3 ;
		AC <= 0 ; 
		MQ <= 0 ; 
		IR <= 0 ; 
		MAR <= 0 ; 
		MBR <= 0 ; 
		IBR <= 0 ; 
		lefthalf <= 1 ; 
		HALTED <= 0 ; 
		check <= 1 ; 
	end  

	always @(posedge clk) 
	begin 
		if(!HALTED)
		begin

			if((IR == JUMP_MX_20to39) || (IR == JUMP_plus_MX_20to39))
			begin 
				// check <= 0 ; 
				MBR = Mem[MAR] ;
				IR = MBR[19:12] ; 
				MAR = MBR[11:0] ; 
			end 

			else if((IR == JUMP_MX_0to19) || (IR == JUMP_plus_MX_0to19)) 
			begin
				// check <= 0 ; 
				MBR =  Mem[MAR] ; 
				IBR = MBR[19:0] ; 
				IR = MBR[39:32] ; 
				MAR = MBR[31:20] ; 
			end 

			else if (lefthalf)
			begin 	
				// check <= 0 ; 
				MAR = PC ; 
				MBR = Mem[MAR] ; 
				IBR = MBR[19:0] ; 
				IR = MBR[39:32] ; 
				MAR = MBR[31:20] ;
			end  

			case(IR) 
				LOAD_MQ 			:	MQ = AC ; 

				LOAD_MQ_MX  		:	MQ = Mem[MAR] ; 

				STOR_MX 			:	Mem[MAR] = AC ;

				LOAD_MX 			:	AC = Mem[MAR] ; 

				LOAD_neg_MX  		:	AC = - Mem[MAR] ; 

				LOAD_abs_MX  		:	begin 
											if(Mem[MAR] > 0) 
												AC = Mem[MAR] ; 
											else 
												AC = -Mem[MAR] ; 
										end

				LOAD_neg_abs_MX  	:	begin 
											if(Mem[MAR] > 0) 
												AC = -Mem[MAR] ; 
											else 
												AC = Mem[MAR] ; 
										end

				JUMP_MX_0to19 		:	PC = MAR ; 

				JUMP_MX_20to39 		:	PC = MAR ; 

				JUMP_plus_MX_0to19  :	if(AC >= 0) 
											PC = MAR ; 

				JUMP_plus_MX_20to39 :	if(AC >= 0)
											PC = MAR ; 

				ADD_MX  			:	AC = AC + Mem[MAR] ; 

				ADD_abs_MX  		:	begin 
											if(Mem[MAR] > 0) 
												AC = AC + Mem[MAR] ; 
											else 
												AC = AC - Mem[MAR] ; 
										end
				SUB_MX  			:	AC = AC - Mem[MAR] ; 
				
				SUB_abs_MX  		:	begin 
											if(Mem[MAR] > 0) 
												AC = AC - Mem[MAR] ; 
											else 
												AC = AC + Mem[MAR] ; 
										end

				MUL_MX 				:	begin 
											intermediate = MQ*Mem[MAR] ;
											AC = intermediate[39:0] ; 
											MQ = intermediate[79:40] ; 
										end 

				LSH  				:	AC = AC*2 ; 

				RSH  				: 	AC = AC/2 ; 

				STOR_MX_8to19  		:	Mem[MAR][39:28] = AC[11:0] ; 

				STOR_MX_28to39   	:	Mem[MAR][19:8] = AC[11:0] ;	

				HALT  				:	HALTED = 1 ; 

				default 			:	HALTED = 1 ;  
			endcase 

			if(!(IR == JUMP_MX_0to19))
			begin 
				if(!(IR == IBR[19:12]))
				begin
					// PC <= PC + 1 ; 
					lefthalf = 0 ;
					IR = IBR[19:12] ;
					MAR = IBR[11:0] ;  
				end

				else 
				begin
					PC = PC + 1 ; 
					lefthalf = 1 ; 
				end
			end

		end 
	end	
endmodule

// || JUMP_MX_20to39 || JUMP_plus_MX_0to19 || JUMP_plus_MX_20to39))



