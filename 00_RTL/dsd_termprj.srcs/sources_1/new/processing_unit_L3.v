`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 19:09:12
// Design Name: 
// Module Name: processing_unit_L3
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
module processing_unit_L3#(
    parameter   dataWidth = 16,//Q8.8
                weightRow = 256,//Weight Column Size
                weightCol  = 128,//Weight Row Size
                dspNum = 64,
                bramDepth = weightRow*weightCol/dspNum,
                addrWidth = $clog2(bramDepth),//Weight BRAM Address Size
                INIT_FILE = "D:/DSD2025/Our_Dream_00_RTL_Skeleton/dsd_termprj.srcs/data/fixed_point_W3_hex_rearranged.txt"
)(
    input   clk,
    input   rst_n,
    input   preLayerValid,
    input   [dataWidth-1:0] xInputValue,
    output                          x_ren,
    output  [$clog2(weightRow)-1:0] x_addr,
    output  puDone,
    output  [dspNum*dataWidth-1:0]  puOutput,
    output                          layerReady
    );
wire    [dataWidth-1:0] actValue    [0:dspNum-1];
wire    [dspNum-1:0]                actValid   ;
wire    [dataWidth-1:0] weightValue [0:dspNum-1];
wire    [dspNum*dataWidth-1:0]  bramData;
wire                    w_ren;
wire    [addrWidth-1:0] w_addr;
wire                    neuronEnable;
wire                    neuronValid;
//Neuron(dsp) Instanciation
genvar i;
generate
    for (i=0; i<dspNum; i=i+1) begin: neuron
        neuron #(
            .dataWidth(dataWidth)
        )neuron_inst(
            .clk(clk),   //input                       
            .rst_n(rst_n), //input                       
            .neuronEnable(neuronEnable),  //input                       
            .dspValid(neuronValid),  //input                       
            .xInputValue(xInputValue),   //input       [dataWidth-1:0] 
            .weightValue(weightValue[i]),   //input       [dataWidth-1:0] 
            .actValid(actValid[i]),  //output  reg                 
            .actValue(actValue[i])   //output      [dataWidth-1:0] 
            );
        assign puOutput[dataWidth*i+:dataWidth] = actValue[i];
    end
endgenerate
//Weight BRAM Unpacking
genvar j;
generate
    for (j=0; j<dspNum; j=j+1) begin
        assign weightValue[j] = bramData[dataWidth*j+:dataWidth];
    end
endgenerate
//Weight BRAM Instanciation
single_port_bram  #(
    .WIDTH(dataWidth*dspNum),
    .DEPTH(bramDepth),
    .INIT_FILE(INIT_FILE)
) single_port_bram_inst (
    .clk(clk),
    .en(w_ren),
    .wen(),
    .addr(w_addr),
    .din(),
    .dout(bramData)
);
//Local Controller Instanciations
local_controller_L3#(
    .dataWidth(dataWidth),
    .weightRow(weightRow),
    .weightCol(weightCol),
    .dspNum(dspNum),
    .bramDepth(bramDepth),
    .addrWidth(addrWidth)
)local_controller_L3_inst(
    .clk(clk),//input                       
    .rst_n(rst_n),//input                       
    .preLayerValid(preLayerValid),//input                       
    .w_ren(w_ren),//output  reg                 
    .w_addr(w_addr),//output  reg [addrWidth-1:0] 
    .x_addr(x_addr),//output  reg [$clog2(weightRow)-1:0] 
    .neuronEnable(neuronEnable),//output  reg                 
    .neuronValid(neuronValid),//output                      
    .layerReady(layerReady)//output  reg                 
    );
assign x_ren = w_ren;
assign puDone = &actValid;
endmodule