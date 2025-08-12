`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/13 21:31:14
// Design Name: 
// Module Name: x_buffer_L2
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module x_buffer_L2#(
    parameter   dataWidth = 16,//Q8.8
                weightCol  = 64//Weight Row Size
)(
    input                               clk,
    input                               rst_n,
    input                               puDone,
    input                               layerReady,
    input   [dataWidth*weightCol-1:0]   puOutput,
    input                               x_ren,
    input   [$clog2(weightCol)-1:0]     x_addr,
    output  reg [dataWidth-1:0]         bufData,
    output  reg                         validOut
    );
reg [dataWidth*weightCol-1:0]       buffer1;
reg [dataWidth*weightCol-1:0]       buffer2;

always @(posedge clk) begin
    if (!rst_n) begin
        buffer1 <= 0;
    end
    else begin
        if (puDone) begin
            buffer1 <= puOutput;
        end
    end
end

always @(posedge clk ) begin
    if (!rst_n) begin
        buffer2 <= 0;
    end
    else begin
        if (validOut && layerReady) begin
            buffer2 <= buffer1;
        end
    end
end

always @(posedge clk) begin
    if (!rst_n|layerReady) begin
        validOut <= 0;
    end
    if (puDone) begin
        validOut <= 1;
    end
end

always @(posedge clk) begin
    if (x_ren) begin
        bufData <= buffer2[dataWidth*x_addr +: dataWidth];
    end
end
endmodule