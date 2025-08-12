`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 20:42:10
// Design Name: 
// Module Name: pu_sub
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


module pu_sub#(
    parameter INIT_FILE = ""
)(
    input               clk,
    input               rst_n,
    input               start,
    output              puDone,
    output  [10*32-1:0] puOutput
    );
wire                puDone_L1;
wire [64*16-1:0]    puOutput_L1;
wire validOut_L1;
wire layerReady_L2;
wire x_ren_L2;
wire [$clog2(256)-1:0] x_addr_L2;
wire [15:0] xInputValue_L2;
wire                puDone_L2;
wire [32*16-1:0]    puOutput_L2;
wire validOut_L2;
wire layerReady_L3;
wire x_ren_L3;
wire [$clog2(256)-1:0] x_addr_L3;
wire [15:0] xInputValue_L3;
wire puDone_L3;
wire [64*16-1:0] puOutput_L3;
wire validOut_L3;
wire layerReady_L4;
wire x_ren_L4;
wire [$clog2(128)-1:0] x_addr_L4;
wire [15:0] xInputValue_L4;

processing_unit_L1 #(
    .data1(1568),
    .data2(1568),
    .INIT_FILE(INIT_FILE)
)processing_unit_L1(
    .i_clk(clk),//input wire             
    .i_rstn(rst_n),//input wire             
    .i_start(start),//input wire             
    .i_l2_ready(layerReady_L2),//input wire             
    .o_l1_output(puOutput_L1),//output wire [16*64-1:0]
    .done(puDone_L1),//output wire            
    .valid()//output wire            
);

x_buffer_L2#(
    .dataWidth(16),//Q8.8
    .weightCol(64)//Weight Row Size
)x_buffer_L2_inst(
    .clk(clk),//input                               
    .rst_n(rst_n),//input                               
    .puDone(puDone_L1),//input                               
    .layerReady(layerReady_L2),//input                               
    .puOutput(puOutput_L1),//input   [dataWidth*weightCol-1:0]   
    .x_ren(x_ren_L2),//input                               
    .x_addr(x_addr_L2),//input   [$clog2(weightCol)-1:0]     
    .bufData(xInputValue_L2),//output  reg [dataWidth-1:0]         
    .validOut(validOut_L1)//output  reg                         
    );

processing_unit_L2 #(
    .dataWidth(16),//Q8.8
    .weightRow(64),//Weight Column Size
    .weightCol(256),//Weight Row Size
    .dspNum(32),
    .bramDepth(),//weightRow*weightCol/dspNum
    .addrWidth(),//$clog2(bramDepth)//Weight BRAM Address Size
    .INIT_FILE("D:/DSD2025/Our_Dream_00_RTL_Skeleton/dsd_termprj.srcs/data/fixed_point_W2_hex_rearranged.txt")
)processing_unit_L2(
    .clk(clk),//input                           
    .rst_n(rst_n),//input                           
    .preLayerValid(validOut_L1),//input                                                  
    .xInputValue(xInputValue_L2),//input   [dataWidth-1:0]    
    .x_ren(x_ren_L2),      
    .x_addr(x_addr_L2),//output  [$clog2(weightRow)-1:0]      
    .puDone(puDone_L2),//output                          
    .puOutput(puOutput_L2),//output  [dspNum*dataWidth-1:0]  
    .layerReady(layerReady_L2)//output                          
    );

x_buffer#(
    .dataWidth(16),
    .weightRow(64),
    .weightCol(256),
    .dspNum(32)
)x_buffer_L3_inst(
    .clk(clk),//input                           
    .rst_n(rst_n),//input                           
    .puDone(puDone_L2),//input                           
    .layerReady(layerReady_L3),//input                           
    .puOutput(puOutput_L2),//input   [dataWidth*dspNum-1:0]  
    .x_ren(x_ren_L3),//input                           
    .x_addr(x_addr_L3),//input   [$clog2(weightCol)-1:0] 
    .bufData(xInputValue_L3),//output  reg [dataWidth-1:0]  
    .validOut(validOut_L2)//output  reg   
    );

processing_unit_L3 #(
    .dataWidth(16),//Q8.8
    .weightRow(256),//Weight Column Size
    .weightCol(128),//Weight Row Size
    .dspNum(64),
    .bramDepth(),//weightRow*weightCol/dspNum
    .addrWidth(),//$clog2(bramDepth)//Weight BRAM Address Size
    .INIT_FILE("D:/DSD2025/Our_Dream_00_RTL_Skeleton/dsd_termprj.srcs/data/fixed_point_W3_hex_rearranged.txt")
)processing_unit_L3(
    .clk(clk),//input                           
    .rst_n(rst_n),//input                           
    .preLayerValid(validOut_L2),//input                           
    .xInputValue(xInputValue_L3),//input   [dataWidth-1:0]   
    .x_ren(x_ren_L3),      
    .x_addr(x_addr_L3),//output  [$clog2(weightRow)-1:0] 
    .puDone(puDone_L3),//output                          
    .puOutput(puOutput_L3),//output  [dspNum*dataWidth-1:0]  
    .layerReady(layerReady_L3)//output                          
    );

x_buffer#(
    .dataWidth(16),
    .weightRow(256),
    .weightCol(128),
    .dspNum(64)
)x_buffer_L4_inst(
    .clk(clk),//input                           
    .rst_n(rst_n),//input                           
    .puDone(puDone_L3),//input                           
    .layerReady(layerReady_L4),//input                           
    .puOutput(puOutput_L3),//input   [dataWidth*dspNum-1:0]  
    .x_ren(x_ren_L4),//input                           
    .x_addr(x_addr_L4),//input   [$clog2(weightCol)-1:0] 
    .bufData(xInputValue_L4),//output  reg [dataWidth-1:0]  
    .validOut(validOut_L3)//output  reg   
    );

processing_unit_L4 #(
    .dataWidth(16),//Q8.8
    .weightRow(128),//Weight Column Size
    .weightCol(10),//Weight Row Size
    .dspNum(10),
    .bramDepth(),//weightRow*weightCol/dspNum
    .addrWidth(),//$clog2(bramDepth)//Weight BRAM Address Size
    .INIT_FILE("D:/DSD2025/Our_Dream_00_RTL_Skeleton/dsd_termprj.srcs/data/fixed_point_W4_hex_rearranged.txt")
)processing_unit_L4(
    .clk(clk),//input                           
    .rst_n(rst_n),//input                           
    .preLayerValid(validOut_L3),//input                           
    .xInputValue(xInputValue_L4),//input   [dataWidth-1:0]    
    .x_ren(x_ren_L4),     
    .x_addr(x_addr_L4),//output  [$clog2(weightRow)-1:0] 
    .puDone(puDone),//output                          
    .puOutput(puOutput),//output  [dspNum*dataWidth-1:0]  
    .layerReady(layerReady_L4)//output                          
    );    

//ila_1 ila_1_inst (
//	.clk(clk), // input wire clk
//
//
//	.probe0(puOutput_L1), // input wire [1023:0]  probe0  
//	.probe1(puOutput_L2), // input wire [511:0]  probe1 
//	.probe2(puOutput_L3), // input wire [1023:0]  probe2 
//	.probe3(puOutput) // input wire [319:0]  probe3
//);
endmodule
