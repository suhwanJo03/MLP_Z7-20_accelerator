`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/04 18:06:03
// Design Name: 
// Module Name: local_controller_L3
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
module local_controller_L3 #(
    parameter   dataWidth = 16,
                weightRow = 256,//Weight Column Size
                weightCol  = 128,//Weight Row Size
                dspNum = 64,
                bramDepth = weightRow*weightCol/dspNum,
                addrWidth = $clog2(bramDepth)
)(
    input                               clk,
    input                               rst_n,
    input                               preLayerValid,//x_buffer valid signal
    output  reg                         w_ren,
    output  reg [addrWidth-1:0]         w_addr,
    output  reg [$clog2(weightRow)-1:0] x_addr,
    output  reg                         neuronEnable,
    output                              neuronValid,
    output  reg                         layerReady
    );
localparam  IDLE = 2'd0,
            CAL = 2'd1,
            WAIT = 2'd2,
            DONE = 2'd3;
reg [1:0]   state, nextState;

always @(posedge clk) begin
    if (!rst_n) begin
        nextState <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if (preLayerValid & layerReady)
                    nextState <= CAL;
            end
            CAL: begin
                if (w_addr==weightRow-2)
                    nextState <= WAIT;
                else if ((w_addr==2*weightRow-2)) begin
                    nextState <= DONE;
                end
            end
            WAIT: begin
                nextState <= CAL;
            end
            DONE: begin
                nextState <= IDLE;
            end
        default: nextState <= nextState;
        endcase
    end
end
always @(posedge clk) begin
    if (!rst_n) begin
        state <= IDLE;
        w_ren <= 0;
        w_addr <= {addrWidth{1'b1}};
        x_addr <= {$clog2(weightRow){1'b1}};
    end
    else begin
        state <= nextState;
        case (state)
            IDLE: begin
                w_ren <= 0;
                w_addr <= {addrWidth{1'b1}};
                x_addr <= {$clog2(weightRow){1'b1}};
            end
            CAL: begin
                w_ren <= 1;
                w_addr <= w_addr + 1;
                x_addr <= x_addr + 1;
            end
            WAIT: begin
                w_ren <= 0;
                w_addr <= w_addr;
                x_addr <= x_addr;
            end
            DONE: begin
                w_ren <= 0;
                w_addr <= w_addr;
                x_addr <= x_addr;
            end
        endcase
    end
end
always @(posedge clk) begin
    if (!rst_n) begin
        layerReady = 0;
    end
    else begin
        case (state)
            IDLE: begin
                layerReady <= 1;
            end
            CAL: begin
                layerReady <= 0;
            end
            default: begin
                layerReady <= 0;
            end
        endcase
    end
end
always @(posedge clk) begin
    if (!rst_n) begin
        neuronEnable <= 0;
    end
    else begin
        neuronEnable <= w_ren;
    end
end
assign neuronValid =  neuronEnable ? ~w_ren : 1'b0;
endmodule