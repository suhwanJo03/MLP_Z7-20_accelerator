/*
ReLU #(
    .dataWidth()  //parameter   
)ReLU_inst(
    .clk(),        //input                           
    .dspValue(),   //input       [2*dataWidth-1:0]   
    .actValue()    //output  reg [dataWidth-1:0]     
);
*/
module ReLU #(
    parameter   dataWidth = 16
)(
    input                           clk,
    input       [47:0]              dspValue,
    output  reg [dataWidth-1:0]     actValue
);
localparam sliceWidth = dataWidth/2;
always @(posedge clk) begin
    if (dspValue[47]) begin
        actValue <= 0;
    end
    else begin
        actValue <= dspValue[2*dataWidth-1-sliceWidth-:dataWidth];
    end
end
    
endmodule
