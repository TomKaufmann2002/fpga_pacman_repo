
import digits_pkg::*;

module digit_bit_map	(	
	// inputs:
	input	logic	clk,
	input	logic	resetN,
	input logic	[10:0] offsetX, 
	input logic	[10:0] offsetY,
	input	logic	in_container, 
	input logic	[3:0] digit,
	
	// outputs:
	output logic dr
);
											

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		dr <=	1;
	end
	else begin
		dr <=	0; // default
		if (in_container)
			dr <= (digits_bitmap[digit][offsetY][offsetX]);
	end 
end


endmodule