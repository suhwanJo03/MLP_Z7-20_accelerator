/*
neuron #(
    .layerNum(),
    .neuronNum(),
    .dataWidth()
)neuron_inst(
    .clk(),   //input                       
    .rst_n(), //input                       
    .neuronEnable(),  //input                       
    .dspValid(),  //input                       
    .xInputValue(),   //input       [dataWidth-1:0] 
    .weightValue(),   //input       [dataWidth-1:0] 
    .actValid(),  //output  reg                 
    .actValue()   //output      [dataWidth-1:0] 
    );
*/
module neuron#(
    parameter   dataWidth = 16
)(
    input                       clk,
    input                       rst_n,
    input                       neuronEnable,
    input                       dspValid,//A signal indicating that one MAC parallel operation has been completed
    input       [dataWidth-1:0] xInputValue,
    input       [dataWidth-1:0] weightValue,
    output                   actValid,
    output      [dataWidth-1:0] actValue
    );

wire    [47:0]   partialSum;
wire    [47:0]   dspValue;
reg     dspValid_d;
reg     actValid_r;

always @(posedge clk) begin
    if (!rst_n) begin
        dspValid_d <= 0;
        actValid_r <= 0;
    end
    else begin
        dspValid_d <= dspValid;
        actValid_r <= dspValid_d;
    end
end
dsp_macro_0 MAC (
  .CLK(clk),    // input wire CLK
  .CE(neuronEnable),      // input wire CE
  .SCLR(dspValid_d),  // input wire SCLR
  .A(xInputValue),        // input wire [15 : 0] A
  .B(weightValue),        // input wire [15 : 0] B
  .C(partialSum),        // input wire [31 : 0] C
  .P(partialSum)        // output wire [31 : 0] P
);
ReLU #(
    .dataWidth(dataWidth)  //parameter   
)ReLU_inst(
    .clk(clk),        //input                           
    .dspValue(dspValue),   //input       [2*dataWidth-1:0]   
    .actValue(actValue)    //output  reg [dataWidth-1:0]     
);
assign dspValue = dspValid_d ? partialSum : {48{1'b0}};
assign actValid = actValid_r;
endmodule
