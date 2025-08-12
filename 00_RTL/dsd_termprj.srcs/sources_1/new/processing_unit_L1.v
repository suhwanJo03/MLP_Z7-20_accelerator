`timescale 1ns / 1ps

module processing_unit_L1#(
parameter data1 = 1568,
parameter data2 = 1568,
parameter INIT_FILE = ""
)
(
input wire              i_clk,
input wire              i_rstn,
input wire              i_start,
input     wire          i_l2_ready,
output wire [16*64-1:0] o_l1_output,
output wire             done,
output wire             valid
// 256 normalize
    );
    wire        [data1-1:0]    din1; // bit �Ҵ�
    wire        [data2-1:0]    din2; // bit �Ҵ�
    wire                       clear;       
    wire                       mac_ok_o;
    wire                       mac_ok_i;
    wire                       mac_en;
    wire       [2:0]           w_addr;
    wire                       m_b_en;
    wire                       w_b_en;
    wire       [8:0]           m_addr;
    wire                       column_done;
    wire                       valid_done;
    wire       [4704-1:0]      mul_o;
    wire                       assemble_w_done;
    wire        [4704-1:0]      assemble_mul;
    reg                        done_r;
    wire [16-1:0]    w_at_output; //parkjunha
//    wire             w_ready;     //parkjunha
    wire             w_valid;
    
 // parkjunha
    reg  [3:0]       image_cnt;
    reg  [32*64-1:0] r_o_l1_output;
    
    assign assemble_w_done = done_r; 
    
     always@ (posedge i_clk or negedge i_rstn) begin // �̰� ���� �־�� �ϴ� ���� �𸣰��� �̹� ���� CTRL���� �ϼ� ��ȣ�� �̹� ������ְ� �ִ�. 
     if(!i_rstn) begin
      done_r <= 0;
     end
     
     else if(done_r)begin
       done_r <= 0;
     end
     
     else begin
     done_r <= column_done;
     end
    end
    //assemble �κ� �������� ���� �ʿ� 
    assign assemble_mul = (done_r) ? mul_o : 0;
    wire [3:0] w_image_cnt;
    assign w_image_cnt = image_cnt;
    input_bram #(
     .WIDTH  (98*16),
     .DEPTH  (80),
     .ADDR_WIDTH ($clog2(8)),
     .INIT_FILE (INIT_FILE)
    )input_bram1(
    .clk                         (i_clk)       , 
    .en                          (w_b_en)       , 
    .image_cnt                   (w_image_cnt), 
   // .next_ok                     (valid_done)        , // 10�� ����� bram�� ������� ���� ������ ��ȣ �ִ� �� valid_done���� ��ȣ �� �� �� �Ҵ� ��Ų��. 
    .wen                         ()       , //not use
    .addr                        (w_addr)       , //addr ������ ctrl���� �ؾ��Ѵ�. 
    .din                         ()       , //not use
    .dout                        (din1)       
    
    );
      
    
    weight_bram #(
         .WIDTH  (16*98),             
         .DEPTH  (512),            
         .ADDR_WIDTH ($clog2(512)) ,
        .INIT_FILE ("D:/DSD2025/Our_Dream_00_RTL_Skeleton/dsd_termprj.srcs/data/REAL_HEX_FIXED_POINT_W1_HEX.txt")
    )weight_bram1 (
    .clk_i                       (i_clk)       ,      
    .en                          (m_b_en)       ,     
    .wen                         ()       , //not use 
    .addr                        (m_addr)       ,     
    .din                         ()       , //not use 
    .dout                        (din2)        
    );       

    neuron_L1 #( // pu ����� gemv ������ �ݴ��� gemv 0�� 98�� gemv 97�� 1�� 
    .macs(98) 
    ) neuron_L1_inst(
     .      rstn_i                (i_rstn),     
     .       clk_i                (i_clk),      
     .       en_i                 (mac_en),       
     .       mac_ok_i             (mac_ok_o),   // �̰ɷ� ctrl���� ��ȣ ��� �ָ鼭 �����.
     .       din1_i               (din1),  
     .       din2_i               (din2),
     .       valid_i              (column_done),           // ������ �� �� pu ��ȣ�� �޾ƿ����� �ϴ� ��ȣ 
     .       clear                (clear),       
     .       mac_ok_o             (mac_ok_i),   // ���� ������ �ƴ��� Ȯ�� �����ش�.
     .       mul_o                (mul_o) // 
    );
    
    reg r_start;
    reg [3:0] stop_start;

    
    reg  relu_ok_d;  // delay register
    reg [3:0] relu_cnt;
    


    wire relu_ok;
    
wire relu_ok_edge;

assign relu_ok_edge = relu_ok & ~relu_ok_d ;

always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        relu_ok_d <= 1'b0;
        end
      else begin
        relu_ok_d <= relu_ok;
      end
end
    
    
    // ���� ���ʿ� 
    local_controller_L1 lctr (
             . clk_i                       (i_clk),      
             . rstn_i                      (i_rstn),                      
             . start_i                     (r_start),                     
             . mok_i                       (mac_ok_i),        
             . w_addr_o                    (w_addr),
             . w_en_o                      (w_b_en), //
             . mat_addr_o                  (m_addr),   
             . mat_en_o                    (m_b_en), 
             . mac_en_o                    (mac_en),   
             . mac_clear_o                 (clear),
             . mac_ok_o                    (mac_ok_o),   
             . done_o                      (column_done),  // 8�� ������ �� �����ٴ� ��ȣ �ϳ��� �� ���� ��, 64���� ������ ���Ҵ�. ���ֱ� delay�� �������� ���� ���´�.
             . valid_o                     (valid_done) // ���⼭ done�� ready�� ������ �Ѵ�. 
    
    );
    
    
    final_adder#()addertree1(
        .i_clk          (i_clk),
        .i_rstn         (i_rstn),
        .i_en           (assemble_w_done),//
        .i_datas        (assemble_mul), 
        .i_l2_ready     (i_l2_ready),
        .o_data         (w_at_output),
    //    .o_ready        (w_ready),//
        .for_relu       (relu_ok), // ���⼭ ������ �ʿ��ϴٰ� ������.
        .o_valid        (w_valid)
    );

reg [6:0] ready_cnt;
reg [16*64-1:0]      store_mul;
reg [16*64-1:0]      for_store;
reg                  for_ready;  

wire [16-1:0]     RELU_output;
assign valid = for_ready; //
assign done  = for_ready; // ���� �����߾��� 
assign o_l1_output = store_mul;

assign RELU_output = (w_at_output[15:12] == 4'hF) ? 0 : w_at_output;

always@ (posedge i_clk or negedge i_rstn) begin // ���� �̹����� �Ѿ �� ready_cnt�� �޾ƿ��� ������ ������ �ʿ��ϴ�.
   if(!i_rstn) begin
     ready_cnt <= 0;
     store_mul <= 0;
     for_store <= 0;
     image_cnt <= 0;
     for_ready <= 0;
   end
   else if (for_ready == 1) begin
     ready_cnt <= 0;
     store_mul <= 0;
     for_store <= 0;
     for_ready <= 0;
   end
   else if(ready_cnt == 64) begin // �̶� ���� bram���� �Ѿ ��ȣ �ֱ� input bram 10�� �� ���� ��ȣ��
    ready_cnt <= 0;
    store_mul <= for_store;
    image_cnt <= image_cnt + 1;
    for_ready <= 1;
   end
   
   else if (relu_ok_edge) begin // �ϴ� valid ��ȣ�� �ȵ��ͼ� output ��ȣ�� ��ü 
    for_store[16*ready_cnt +: 16] <= RELU_output;
    ready_cnt <= ready_cnt + 1;
   end
   else begin
    image_cnt <= image_cnt;
    ready_cnt <= ready_cnt;
    for_store <= for_store;
    for_ready <= 0;
   end
end

//wire relu_ok_edge = relu_ok & ~relu_ok_d;

always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        r_start <= 1'b0;
        stop_start <=0;
        end
    else if(for_ready) begin
       if (stop_start == 8) begin
        r_start <= 0;
       end
       else
        stop_start <= stop_start + 1;
     end    
        
    else if (i_start)
        r_start <= 1'b1;
        
end


endmodule