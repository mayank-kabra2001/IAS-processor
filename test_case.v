module test_IAS ; 
	reg clk ; 

	IAS processor (clk) ; 

	initial 
	begin 
		clk = 0 ;  
		repeat(20)
			begin 
				#5 clk = 1 ; #5 clk = 0 ; 
			end 
	end 

	initial 
	begin 
		$dumpfile ("IAS.vcd") ; 
		$dumpvars (0 , test_IAS) ;

		$monitor ("time = %d, clk = %b, c = %d , PC = %12b: , MAR = %12b , IBR = %20b , MBR = %40b, lefthalf = %d , IR = %8b" ,$time , clk ,  processor.Mem[2] , processor.PC , processor.MAR , processor.IBR , processor.MBR, processor.lefthalf , processor.IR) ; 

		#300 $finish ; 
	end 
endmodule  