`timescale 1ns / 1ps

module relu #(
    parameter N = 14    // N = width of input/output, e.g., conv output is 14 bits
)(
    input  [N-1:0] din_relu,     // Input data to ReLU function
    output [N-1:0] dout_relu     // Output data after ReLU activation
);

    // If MSB (sign bit) is 1, output 0; else pass input unchanged
    assign dout_relu = din_relu[N-1] ? {N{1'b0}} : din_relu;

endmodule
