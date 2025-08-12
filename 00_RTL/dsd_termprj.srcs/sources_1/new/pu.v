module pu #(
    //parameter IN_X_BUF_DATA_WIDTH = 32,         // you should change if you try to design the int8 streamline architecture
    //parameter IN_W_BUF_DATA_WIDTH = 32,         // you should change if you try to design the int8 streamline architecture
    //parameter OUT_BUF_ADDR_WIDTH = 32,
    //parameter OUT_BUF_DATA_WIDTH = 32,
    parameter INIT_FILE = ""
)(
    // system interface
    input   wire                            clk,
    input   wire                            rst_n,
    // global controller interface
    input   wire                            prcss_start,
    output  wire                            prcss_done,
    output  wire    [10*32-1:0]             prcss_data
    // input data buffer interface
    //input   wire [IN_X_BUF_DATA_WIDTH-1:0]  x_buf_data,
    //input   wire [IN_W_BUF_DATA_WIDTH-1:0]  w_buf_data,
    // output data buffer interface
    //output  wire                            y_buf_en,
    //output  wire                            y_buf_wr_en,
    //output  wire [OUT_BUF_ADDR_WIDTH-1:0]   y_buf_addr,
    //output  wire [OUT_BUF_DATA_WIDTH-1:0]   y_buf_data,
   //output  wire all_done
);
pu_sub #(
    .INIT_FILE(INIT_FILE)
)pu_sub_inst(
    .clk(clk),//input               
    .rst_n(rst_n),//input               
    .start(prcss_start),//input               
    .puDone(prcss_done),//output              
    .puOutput(prcss_data)//output  [10*16-1:0] 
    );
endmodule