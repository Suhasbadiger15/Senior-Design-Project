`timescale 1ns / 1ps


module conv #(
parameter DATA_W = 16,
parameter IMG_N = 6,
parameter K = 3
)(
input wire clk,
input wire rst,
input wire en,
input wire [DATA_W-1:0] pixel_in,
output reg [DATA_W-1:0] conv_out,
output reg out_valid
);


localparam WIN = K;
reg [DATA_W-1:0] shift [0:WIN-1];
integer i;


always @(posedge clk) begin
if (rst) begin
for (i=0;i<WIN;i=i+1) shift[i] <= 0;
conv_out <= 0;
out_valid <= 0;
end else begin
if (en) begin
// shift register
for (i=WIN-1;i>0;i=i-1) shift[i] <= shift[i-1];
shift[0] <= pixel_in;
// compute simple sum
conv_out <= shift[0] + shift[1] + shift[2];
out_valid <= 1'b1;
end else begin
out_valid <= 1'b0;
end
end
end


endmodule
