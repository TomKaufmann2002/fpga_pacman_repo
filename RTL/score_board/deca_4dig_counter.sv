module deca_4dig_counter (
    input  logic clk,
    input  logic resetN,
    input  logic ate_pdot,   // increment request (1 pulse per increment)
	 input  logic ate_edot,
	 input  logic is_rg_alive,
	 input  logic is_pg_alive,
	 input  logic is_cg_alive,
	 input  logic is_og_alive,


    output logic [3:0] digit_units,
    output logic [3:0] digit_tens,
    output logic [3:0] digit_hundreds,
    output logic [3:0] digit_thousands
);

    // registers for each digit
    logic [3:0] units, tens, hundreds, thousands;
    logic ate_pdot_d;  // delayed version for edge detection
	 logic ate_edot_d;
	 logic ate_rgst_d;
	 logic ate_pgst_d;
	 logic ate_cgst_d;
	 logic ate_ogst_d;
    logic pdot_pulse;   // rising edge detect result
	 logic edot_pulse;
	 logic rgst_pulse;
	 logic pgst_pulse;
	 logic cgst_pulse;
	 logic ogst_pulse;


    // rising edge detection
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            ate_pdot_d <= 0;
				ate_edot_d <= 0;
				ate_rgst_d <= 0;
				ate_pgst_d <= 0;
				ate_cgst_d <= 0;
				ate_ogst_d <= 0;
		  end
        else begin
				ate_pdot_d <= ate_pdot;
				ate_edot_d <= ate_edot;
				ate_rgst_d <= is_rg_alive;
				ate_pgst_d <= is_pg_alive;
				ate_cgst_d <= is_cg_alive;
				ate_ogst_d <= is_og_alive;
		  end
    end

    assign pdot_pulse = (ate_pdot && !ate_pdot_d);  // rising edge pulse
	 assign edot_pulse = (ate_edot && !ate_edot_d);  // rising edge pulse
	 assign rgst_pulse = (ate_rgst_d && ~is_rg_alive);  // falling edge pulse
	 assign pgst_pulse = (ate_pgst_d && ~is_pg_alive);  // falling edge pulse
	 assign cgst_pulse = (ate_cgst_d && ~is_cg_alive);  // falling edge pulse
	 assign ogst_pulse = (ate_ogst_d && ~is_og_alive);  // falling edge pulse

    // decimal counting logic
    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            units      <= 4'd0;
            tens       <= 4'd0;
            hundreds   <= 4'd0;
            thousands  <= 4'd0;
        end
		  else if (pdot_pulse) begin
            if (units == 4'd9) begin
					 units <= 4'd0;
                if (tens == 4'd9) begin
                    tens <= 4'd0;
                    if (hundreds == 4'd9) begin
                        hundreds <= 4'd0;
                        if (thousands == 4'd9)
                            thousands <= 4'd0; // wrap around
                        else
                            thousands <= thousands + 1;
                    end else
                        hundreds <= hundreds + 1;
                end else
                    tens <= tens + 1;
            end else
                units <= units + 1;
        end
		  else if (edot_pulse) begin
				if (units >= 4'd5) begin
					 units <= units + 5 - 10;
                if (tens == 4'd9) begin
                    tens <= 4'd0;
                    if (hundreds == 4'd9) begin
                        hundreds <= 4'd0;
                        if (thousands == 4'd9)
                            thousands <= 4'd0; // wrap around
                        else
                            thousands <= thousands + 1;
                    end else
                        hundreds <= hundreds + 1;
                end else
                    tens <= tens + 1;
            end else
                units <= units + 5;
		  end
		  else if (rgst_pulse || pgst_pulse || cgst_pulse || ogst_pulse) begin
				 if (tens >= 4'd8) begin
					  tens <= tens + 2 - 10;
					  if (hundreds == 4'd9) begin
							hundreds <= 4'd0;
							if (thousands == 4'd9)
								 thousands <= 4'd0; // wrap around
							else
								 thousands <= thousands + 1;
					  end else
							hundreds <= hundreds + 1;
				 end else
					  tens <= tens + 2;
		  end
    end

// assigning outputs
assign digit_units     = units;
assign digit_tens      = tens;
assign digit_hundreds  = hundreds;
assign digit_thousands = thousands;

endmodule
