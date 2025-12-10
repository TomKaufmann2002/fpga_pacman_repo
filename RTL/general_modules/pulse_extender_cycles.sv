module pulse_extender_cycles #(
    parameter longint EXTEND_CYCLES = 1000   // extend duration in clock cycles
)(
    input  logic clk,
    input  logic resetN,
    input  logic pulse_in,          
    output logic extended_signal    
);

    // counter wide enough for EXTEND_CYCLES
    logic [$clog2(EXTEND_CYCLES)-1:0] counter;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            counter         <= '0;
            extended_signal <= 1'b0;
        end else begin
            if (pulse_in) begin
                counter         <= EXTEND_CYCLES - 1;
                extended_signal <= 1'b1;
            end else if (counter != 0) begin
                counter         <= counter - 1;
                extended_signal <= 1'b1;
            end else begin
                extended_signal <= 1'b0;
            end
        end
    end

endmodule
