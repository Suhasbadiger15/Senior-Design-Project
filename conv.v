`timescale 1ns / 1ps
module conv #(
    parameter N = 16,
    parameter IMG_N = 6,
    parameter K = 3
)(
    input clk,
    input rst,
    input en,
    input signed [N-1:0] pixel_in,

    // kernel inputs
    input signed [N-1:0] k00, k01, k02,
    input signed [N-1:0] k10, k11, k12,
    input signed [N-1:0] k20, k21, k22,

    output reg signed [N-1:0] conv_out,
    output reg out_valid
);

    // line buffers (2 previous rows)
    reg signed [N-1:0] line0 [0:IMG_N-1];
    reg signed [N-1:0] line1 [0:IMG_N-1];

    // window registers
    reg signed [N-1:0] w00,w01,w02,w10,w11,w12,w20,w21,w22;

    integer i;
    reg [15:0] col, row;
    reg window_ready;

    wire signed [2*N-1:0] sum =
          w00*k00 + w01*k01 + w02*k02 +
          w10*k10 + w11*k11 + w12*k12 +
          w20*k20 + w21*k21 + w22*k22;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0;i<IMG_N;i=i+1) begin
                line0[i] <= 0;
                line1[i] <= 0;
            end
            {w00,w01,w02,w10,w11,w12,w20,w21,w22} <= 0;
            conv_out <= 0;
            out_valid <= 0;
            col <= 0;
            row <= 0;
            window_ready <= 0;
        end else if (en) begin
            // shift window horizontally
            w00 <= w01; w01 <= w02; w02 <= line0[col];
            w10 <= w11; w11 <= w12; w12 <= line1[col];
            w20 <= w21; w21 <= w22; w22 <= pixel_in;

            // update line buffers AFTER using old data
            line0[col] <= line1[col];
            line1[col] <= pixel_in;

            // column/row counter
            if (col == IMG_N-1) begin
                col <= 0;
                if (row != IMG_N-1)
                    row <= row + 1;
            end else begin
                col <= col + 1;
            end

            // window valid when 2 previous rows exist and col >= 2
            if (row >= 2 && col >= 2)
                window_ready <= 1;
            else
                window_ready <= 0;

            // output convolution
            if (window_ready) begin
                conv_out <= sum[N-1:0];
                out_valid <= 1;
            end else begin
                out_valid <= 0;
                conv_out <= 0;
            end
        end else begin
            out_valid <= 0;
        end
    end
endmodule
