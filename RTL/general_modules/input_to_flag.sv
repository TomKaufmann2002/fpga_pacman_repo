
module	input_to_flag	
#(parameter int size_of_input = 1, int if_input_is = 1)
  
( 
input logic [size_of_input-1:0] input_to_check,
output logic flag
) ;



assign flag = (if_input_is[size_of_input-1:0] == input_to_check);	 	 

endmodule