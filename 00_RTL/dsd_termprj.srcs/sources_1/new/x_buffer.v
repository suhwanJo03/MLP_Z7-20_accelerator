`timescale 1ns / 1ps
/*
x_buffer#(
    .dataWidth(),
    .weightRow(),
    .weightCol(),
    .dspNum()
)x_buffer_inst(
    .clk(),//input                           
    .rst_n(),//input                           
    .puDone(),//input                           
    .layerReady(),//input                           
    .puOutput(),//input   [dataWidth*dspNum-1:0]  
    .x_ren(),//input                           
    .x_addr(),//input   [$clog2(weightCol)-1:0] 
    .bufData(),//output  reg [dataWidth-1:0]     
    .validOut()//output  reg
    );
*/
module x_buffer#(
    parameter   dataWidth = 16,//Q8.8
                weightRow = 64,//Weight Column Size(x)
                weightCol  = 256,//Weight Row Size
                dspNum = 32
)(
    input                           clk,
    input                           rst_n,
    input                           puDone,
    input                           layerReady,
    input   [dataWidth*dspNum-1:0]  puOutput,
    input                           x_ren,
    input   [$clog2(weightCol)-1:0] x_addr,
    output  reg [dataWidth-1:0]     bufData,
    output  reg                     validOut
    );
localparam OPERNUM = weightCol/dspNum;
reg [dataWidth*weightCol-1:0]       buffer1;
reg [dataWidth*weightCol-1:0]       buffer2;
reg [$clog2(OPERNUM):0]    xBufCnt;

always @(posedge clk) begin
    if (!rst_n) begin
        xBufCnt <= 0;
    end
    else begin
        if (xBufCnt == OPERNUM) begin
            xBufCnt <= 0;
        end
        else begin
            if (puDone) begin
                xBufCnt <= xBufCnt + 1;
            end
        end
    end
end

always @(posedge clk) begin
    if (!rst_n) begin
        buffer1 <= 0;
    end
    else begin
        if (puDone) begin
            buffer1[dataWidth*(dspNum*(OPERNUM-xBufCnt))-1 -: dataWidth*dspNum] <= puOutput;
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
    if (xBufCnt == OPERNUM) begin
        validOut <= 1;
    end
end

always @(posedge clk) begin
    if (x_ren) begin
        bufData <= buffer2[dataWidth*(weightCol-x_addr)-1 -: dataWidth];
    end
end
endmodule