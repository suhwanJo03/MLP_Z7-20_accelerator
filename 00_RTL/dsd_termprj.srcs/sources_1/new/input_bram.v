`timescale 1ns / 1ps
/*
bram_L1 #(
    .WIDTH(),
    .DEPTH(),
    .ADDR_WIDTH(),
    .IMAGE_NUM(),
    .INIT_FILE()
)bram_L1_inst(
    .clk(),//input wire                  
    .en(),//input wire                  
    .wen(),//input wire                  
    .addr(),//input wire [ADDR_WIDTH-1:0] 
    .din(),//input wire [WIDTH-1:0]      
    .dout()//output reg [WIDTH*64-1:0]   
);
*/
module input_bram#(
    parameter WIDTH = 16*98,
    parameter DEPTH = 80,
    parameter ADDR_WIDTH = $clog2(8),
    parameter INIT_FILE = ""
)(
    input wire clk,
    input wire en,
    input wire [3:0] image_cnt,
    input wire wen,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [WIDTH-1:0] din,
    output reg [WIDTH-1:0] dout
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];

    //Initialization
    generate
        if (INIT_FILE != "") begin: use_init_file
            initial
                $readmemh(INIT_FILE, mem, 0, DEPTH-1);
        end
        else begin: init_bram_to_zero
            integer i;
            initial begin
                for (i = 0; i < DEPTH; i = i + 1)
                    mem[i] = {WIDTH{1'b0}};
            end
        end
    endgenerate

    //Read & Write Sequence
    always @(posedge clk) begin
        if (en) begin
            if (wen) begin
                mem[addr] <= din;
            end
            else begin: read_concat
            
                    dout <= mem[image_cnt*8+addr];
            end
        end
    end

endmodule
