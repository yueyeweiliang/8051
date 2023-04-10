module tap( CLOCK_DR, CLOCK_IR, ENABLE, RESET, SELECT, SHIFT_DR, SHIFT_IR, TCK, TMS,
            UPDATE_DR, UPDATE_IR, XTCK, XTRST );


output CLOCK_DR, CLOCK_IR, ENABLE, RESET, SELECT, SHIFT_DR, SHIFT_IR;
input TCK, TMS;
output UPDATE_DR, UPDATE_IR;
input XTCK, XTRST;

reg [3:0] TAP;
reg RESET;
reg ENABLE;
reg SHIFT_IRq;
reg SHIFT_DRq;
reg CLOCK_IRq;
reg UPDATE_IR;
reg CLOCK_DRq;
reg UPDATE_DR;


wire SELECT;
wire SHIFT_IR;
wire SHIFT_DR;
wire CLOCK_IR;
wire CLOCK_DR;
wire TRST;

assign SELECT = TAP[0];
assign SHIFT_IR = !SHIFT_IRq;
assign SHIFT_DR = !SHIFT_DRq;
assign CLOCK_IR = !CLOCK_IRq;
assign CLOCK_DR = !CLOCK_DRq;

assign TRST = !XTRST;

always @(posedge TCK or posedge TRST) begin
	if (TRST) begin
		TAP[3:0] <= 4'b1111;
	end
	else begin
		TAP[3] <= !(!(TAP[3] & !TAP[1] & !TMS)   		& 
				    !(TMS & !TAP[2])               		& 
				    !(TMS & !TAP[3])               		& 
				    !(TAP[1] & TAP[0] & TMS));

		TAP[2] <= !(!(TAP[2] & !TAP[3] & !TMS)   		& 
				    !(!TAP[1] & !TMS)              		& 
				    !(TAP[2] & !TAP[0] & !TMS)     		& 
				    !(!TAP[3] & !TAP[0] & !TMS)    		& 
				    !(TAP[1] & TMS & !TAP[2])      		& 
				    !(TAP[3] & TAP[1] & TAP[0] & TMS));

		TAP[1] <= !(!(TAP[1] & !TAP[2]) 				& 
				    !(TAP[3] & TAP[1]) 					& 
				    !(TMS & !TAP[2]));

		TAP[0] <= !(!(TAP[0] & !TAP[1]) 				& 
				    !(TAP[2] & TAP[0]) 					& 
				    !(TAP[1] & !TAP[2] & !TMS) 			& 
				    !(TAP[1] & !TAP[3] & !TAP[2] & !TAP[0]));
	end
end

always @(posedge XTCK or posedge TRST) begin
	if (TRST) begin
		RESET <= 1'b1;
		ENABLE <= 1'b0;
		SHIFT_IRq <= 1'b0;
		SHIFT_DRq <= 1'b0;
		CLOCK_IRq <= 1'b1;
		CLOCK_DRq <= 1'b1;	
		UPDATE_IR <= 1'b0;
		UPDATE_DR <= 1'b0;
	end
	else begin
		RESET <= &TAP[3:0];
		ENABLE <= !(!(TAP[2] & TAP[0] & !TAP[3] & !TAP[1]) 		& 
					!(TAP[2] & !TAP[3] & !TAP[1] & !TAP[0]));

		SHIFT_IRq <= !(TAP[2] & TAP[0] & !TAP[3] & !TAP[1]);

		SHIFT_DRq <= !(TAP[2] & !TAP[3] & !TAP[1] & !TAP[0]);

		CLOCK_IRq <= !(TAP[2] & TAP[0] & !TAP[3]);

		CLOCK_DRq <= !(TAP[2] & !TAP[3] & !TAP[0]);

		UPDATE_IR <= TAP[3] & TAP[1] & TAP[0] & !TAP[2];
		UPDATE_DR <= TAP[3] & !TAP[2] & TAP[1] & !TAP[0];

	end
end




endmodule // tap
