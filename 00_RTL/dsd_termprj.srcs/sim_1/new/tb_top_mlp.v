`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/14 18:02:49
// Design Name: 
// Module Name: tb_top_mlp
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


module tb_top_mlp();
reg clk;
reg rst_n;
reg start;
wire done_intr_o;
wire done_led_o;
wire y_buf_en;
wire y_buf_wr_en;
wire [$clog2(400)-1:0] y_buf_addr;
wire [31:0] y_buf_data;

top_mlp #(
    .IN_IMG_NUM(10),	
	/*************DO NOT MODIFY THESE PARAMETERS	*****************/
    .Y_BUF_DATA_WIDTH(32),
	.Y_BUF_ADDR_WIDTH(32),
    .Y_BUF_DEPTH()				// we need to store data using byte addressing ( * 4 means byte addressing)
	/*************DO NOT MODIFY THESE PARAMETERS	*****************/
)dut(
	/*************DO NOT MODIFY THESE I/O PORTS	*****************/
    .clk(clk),//input   wire                            
    .rst_n(rst_n),//input   wire                            
    .start_i(start),//input   wire                            
    .done_intr_o(done_intr_o),//output  wire                            
    .done_led_o(done_led_o),//output  wire                            
    .y_buf_en(y_buf_en),//output  wire                            
    .y_buf_wr_en(y_buf_wr_en),//output  wire                            
    .y_buf_addr(y_buf_addr),//output  wire [$clog2(Y_BUF_DEPTH)-1:0]  
    .y_buf_data(y_buf_data)//output  wire [Y_BUF_DATA_WIDTH-1:0]     
	/*************DO NOT MODIFY THESE I/O PORTS	*****************/
);

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset and stimulus generation
    initial begin
        // Initialize inputs
        rst_n = 0;
        start = 0;
        // Apply reset
        #20;
        rst_n = 1;

        // Wait for system to settle
        #20;

        // Stimulus: Assert preLayerValid
        @(posedge clk);
        start <= 1;
        @(posedge clk);
        start <= 0;

    end
endmodule
