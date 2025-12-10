module clk_divider #(
    parameter int DIVIDE_BY = 31_500_000   // default: 1 Hz from 31.5 MHz
)(
    input  logic clk,
    input  logic resetN,
    output logic slow_clk
);

    logic [$clog2(DIVIDE_BY)-1:0] counter;

    always_ff @(posedge clk or negedge resetN) begin
        if (!resetN) begin
            counter  <= '0;
            slow_clk <= 1'b0;
        end else begin
            if (counter == DIVIDE_BY-1) begin
                counter  <= '0;
                slow_clk <= ~slow_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
