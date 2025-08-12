`timescale 1ns / 1ps

module top_mlp #(
    parameter IN_IMG_NUM = 10,
   //parameter FP_BW = 16,
   //parameter INT_BW = 8,
   // parameter X_BUF_DATA_WIDTH = INT_BW,              // if you try INT8 recursive, you should change X_BUF_DATA_WIDTH to this line
   //parameter X_BUF_DATA_WIDTH = FP_BW,
   //parameter X_BUF_DEPTH = 784*IN_IMG_NUM,
    // parameter W_BUF_DATA_WIDTH = INT_BW,               // if you try INT8 recursive, you should change W_BUF_DATA_WIDTH to this line
   //parameter W_BUF_DATA_WIDTH = FP_BW,
   //parameter W_BUF_DEPTH = 784*64,                     // just example
   // parameter W2_BUF_DEPTH = .. ,
   // parameter W3_BUF_DEPTH = .. ,   
   
   
   /*************DO NOT MODIFY THESE PARAMETERS   *****************/
    parameter Y_BUF_DATA_WIDTH = 32,
   parameter Y_BUF_ADDR_WIDTH = 32,
    parameter Y_BUF_DEPTH = 10*IN_IMG_NUM * 4            // we need to store data using byte addressing ( * 4 means byte addressing)
   /*************DO NOT MODIFY THESE PARAMETERS   *****************/
)(
   /*************DO NOT MODIFY THESE I/O PORTS   *****************/
    // system interface
    input   wire                            clk,
    input   wire                            rst_n,
    input   wire                            start_i,
    output  wire                            done_intr_o,
    output  wire                            done_led_o,
    // output buffer interface
    output  wire                            y_buf_en,
    output  wire                            y_buf_wr_en,
    output  wire [$clog2(Y_BUF_DEPTH)-1:0]     y_buf_addr,
    output  wire [Y_BUF_DATA_WIDTH-1:0]     y_buf_data
   /*************DO NOT MODIFY THESE I/O PORTS   *****************/
);

    localparam X_BUF_INIT_FILE =  "D:/DSD25_Termproject_Materials_Updated250519/00_RTL_Skeleton/dsd_termprj.srcs/input_data/final_demo_rearranged.txt";
    //localparam W_BUF_INIT_FILE =  "D:/idsl_hw/DSD/w.txt";
    
    //wire x_buf_en;
    //wire [$clog2(X_BUF_DEPTH)-1:0] x_buf_addr;
    //wire [X_BUF_DATA_WIDTH:0] x_buf_data;
    //wire w_buf_en;
    //wire [$clog2(W_BUF_DEPTH)-1:0] w_buf_addr;
    //wire [W_BUF_DATA_WIDTH:0] w_buf_data;
    
    wire prcss_start;
    wire prcss_done;
    wire [32*10-1:0] prcss_data;
    
    glbl_ctrl #(
        .BUF_ADDR_WIDTH(32)
    ) glbl_ctrl_inst(
        // system interface
        .clk(clk),
        .rst_n(rst_n),
        .start_i(start_i),
        .done_intr_o(done_intr_o),
        .done_led_o(done_led_o),
        // x_buffer interface
        //.x_buf_en(x_buf_en),
        //.x_buf_addr(x_buf_addr),
        // w_buffer interface
        //.w_buf_en(w_buf_en),
        //.w_buf_addr(w_buf_addr),
        // processing unit interface
        .prcss_start(prcss_start),
        .prcss_done(prcss_done),
        .prcss_data(prcss_data),
        // output data buffer interface
        .y_buf_en(y_buf_en),
        .y_buf_wen(y_buf_wr_en),
        .y_buf_addr(y_buf_addr),
        .y_buf_data(y_buf_data)
    );
   
   
    pu #(
        //.IN_X_BUF_DATA_WIDTH(X_BUF_DATA_WIDTH),
        //.IN_W_BUF_DATA_WIDTH(W_BUF_DATA_WIDTH),
        //.OUT_BUF_ADDR_WIDTH($clog2(Y_BUF_DEPTH)),
        //.OUT_BUF_DATA_WIDTH(Y_BUF_DATA_WIDTH),
        .INIT_FILE(X_BUF_INIT_FILE)
    ) pu_inst(
        // system interface
        .clk(clk),
        .rst_n(rst_n),
        // global controller interface
        .prcss_start(prcss_start),
        .prcss_done(prcss_done),
        .prcss_data(prcss_data)
    );
    
    //ila_0 ila_inst_0 (
    //	.clk(clk), // input wire clk
    //
    //
    //	.probe0(rst_n), // input wire [0:0]  probe0  
    //	.probe1(start_i), // input wire [0:0]  probe1 
    //	.probe2(done_intr_o), // input wire [0:0]  probe2 
    //	.probe3(y_buf_addr), // input wire [31:0]  probe3 
    //	.probe4(y_buf_data), // input wire [31:0]  probe4 
    //	.probe5(prcss_data), // input wire [319:0]  probe5 
    //	.probe6(done_led_o), // input wire [0:0]  probe6 
    //	.probe7(y_buf_en), // input wire [0:0]  probe7 
    //	.probe8(y_buf_wr_en), // input wire [0:0]  probe8 
    //	.probe9(prcss_start), // input wire [0:0]  probe9 
    //	.probe10(prcss_done) // input wire [0:0]  probe10
    //);
endmodule