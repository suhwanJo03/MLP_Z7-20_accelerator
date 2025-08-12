`timescale 1ns / 1ps
/*
local_controller#(
    .dataWidth(),
    .weightRow(),
    .weightCol(),
    .dspNum(),
    .bramDepth(),
    .addrWidth()
)local_controller_inst(
    .clk(),//input                       
    .rst_n(),//input                       
    .preLayerValid(),//input                       
    .w_ren(),//output  reg                 
    .w_addr(),//output  reg [addrWidth-1:0] 
    .neuronEnable(),//output  reg                 
    .neuronValid(),//output                      
    .layerReady()//output  reg                 
    );
*/
module local_controller_L2#(
    parameter   dataWidth = 16,
                weightRow = 64,//Weight Column Size
                weightCol  = 256,//Weight Row Size
                dspNum = 32,
                bramDepth = weightRow*weightCol/dspNum,
                addrWidth = $clog2(bramDepth)
)(
    input   clk,
    input   rst_n,
    input   preLayerValid,//x_buffer valid signal
    output  reg w_ren,
    output  reg [addrWidth-1:0] w_addr,
    output  reg [$clog2(weightRow)-1:0] x_addr,
    output  reg neuronEnable,
    output      neuronValid,
    output  reg layerReady
    );
localparam  IDLE = 'd0,
            CAL = 'd1,
            WAIT = 'd2,
            DONE = 'd3;
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
                else nextState <= nextState;
            end
            CAL: begin
                if ((w_addr==weightRow-2)||
                    (w_addr==2*weightRow-2)||
                    (w_addr==3*weightRow-2)||
                    (w_addr==4*weightRow-2)||
                    (w_addr==5*weightRow-2)||
                    (w_addr==6*weightRow-2)||
                    (w_addr==7*weightRow-2))
                    nextState = WAIT;
                else if ((w_addr==8*weightRow-2)) begin
                    nextState <= DONE;
                end
                else nextState <= nextState;
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