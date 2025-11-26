`timescale 1ns / 1ps
module cnn_accelerator #(
    parameter N = 16,
    parameter Q = 4,
    parameter IMG_N = 6,
    parameter K = 3,
    parameter P = 2
)(
    input clk,
    input rst,
    input en,
    input [N-1:0] pixel_in,

    input signed [N-1:0] k00, k01, k02,
    input signed [N-1:0] k10, k11, k12,
    input signed [N-1:0] k20, k21, k22,

    output [N-1:0] pooled_out,
    output valid_out
);

    wire [N-1:0] conv_out;
    wire conv_valid;

    conv #(.N(N), .IMG_N(IMG_N), .K(K)) conv_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .pixel_in(pixel_in),
        .k00(k00), .k01(k01), .k02(k02),
        .k10(k10), .k11(k11), .k12(k12),
        .k20(k20), .k21(k21), .k22(k22),
        .conv_out(conv_out),
        .out_valid(conv_valid)
    );

    wire signed [N-1:0] quant_out;
    quantizer #(.N(N), .Q(Q)) quant_inst (
        .din(conv_out),
        .dout(quant_out)
    );

    wire [N-1:0] relu_out;
    relu #(.N(N)) relu_inst (
        .din_relu(quant_out),
        .dout_relu(relu_out)
    );

    pooler #(.N(N), .m(IMG_N-K+1), .p(P)) pool_inst (
        .clk(clk),
        .rst(rst),
        .en(conv_valid),
        .data_in(relu_out),
        .pool_out(pooled_out),
        .done(valid_out)
    );

endmodule
