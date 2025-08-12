/*
single_port_bram #(
    .WIDTH(),
    .DEPTH(),
    .INIT_FILE("")
    ) bram_inst(
    .clk(clk),
    .en(),
    .wen(),
    .addr(),
    .din(),
    .dout()
);
*/

 module weight_bram #(
 parameter WIDTH = 16*98,
 parameter DEPTH = 512,
 parameter ADDR_WIDTH = $clog2(DEPTH),
 parameter INIT_FILE = ""
 )(
 input wire clk_i,
 input wire en,
 input wire wen,
 input wire [ADDR_WIDTH-1:0] addr,
 input wire [WIDTH-1:0] din,
 output reg [WIDTH-1:0] dout
 );

  reg [WIDTH-1:0] mem [0:DEPTH];
 generate
    if (INIT_FILE != "") begin: use_init_file
        initial
        $readmemh(INIT_FILE, mem, 0, DEPTH -1);
    end
    else begin: init_bram_to_zero
        integer ram_index;
        initial
        for (ram_index= 0; ram_index< DEPTH; ram_index= ram_index+ 1)
        mem[ram_index] = {WIDTH{1'b0}};
    end
 endgenerate

 always @(posedge clk_i) begin
    if (en) begin
        if (wen) begin
            mem[addr] <= din;
        end
        else begin
            dout<= mem[addr];
        end
    end
 end   
 endmodule