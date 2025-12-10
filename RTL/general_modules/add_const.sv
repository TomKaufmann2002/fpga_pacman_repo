module add_const #(
    parameter WIDTH = 8,               // bus width
    parameter signed CONST = 1         // signed constant to add
)(
    input  logic signed [WIDTH-1:0] data_in,
    output logic signed [WIDTH-1:0] data_out
);

    assign data_out = data_in + CONST;

endmodule
