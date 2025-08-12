`timescale 1ns / 1ps
// 16 16 48 32
module neuron_L1#(
parameter data1 = 1568,
parameter data2 = 1568,
parameter macs = 98
)
(
input       wire                             rstn_i,
input       wire                             clk_i,
input       wire                             en_i,
input       wire                             mac_ok_i,
input       wire  [data1-1:0]                din1_i,
input       wire  [data2-1:0]                din2_i,
input       wire                             clear,
input       wire                             valid_i,


output      wire                             mac_ok_o, // 1              ?                  ขา           ? .
output      wire  [macs*48-1:0]               mul_o //         buffer          ?  . buffer              ctrl     done   ?    ??          .

//output reg valid_o
    );
    
    // mac_ok_i          ?                                                        ?  ?             ??         mac_ok_o           ?  ? .
   
    wire [47:0] mac_output [0:97];
    reg mac_ok_r; 
    reg [macs*48-1:0] mul_o_r;
    
      assign mac_ok_o = mac_ok_r;
      assign mul_o = mul_o_r;
      
      
      always @(posedge clk_i or negedge rstn_i) begin// ?                   ?   ?               ?  ctrl     OK state        ?   ?     ?     ?   ??            ??    ?       
          if (!rstn_i) begin
              mac_ok_r = 0;
              
          end
          else if (mac_ok_i && en_i) begin // mac_ok_i // ?        en_i              0           .
              mac_ok_r = 0; // OK   ?     
          end
          else begin
              mac_ok_r = 1;
          end
      end
      //   ?    ?                      ?   ?  CTRL      CLK ?   ?   . 

    
    
    genvar i;
    generate
    for(i = 0; i < 98;i = i + 1) begin: gemv1
    MAC MAC_1 (
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    .clear_i(clear),
    .dsp_valid_i(valid_i),
    .dsp_enable_i(en_i),
 //   .dsp_valid_o(pu_w),
    .dsp_input_i(din1_i[i*16+:16]),
    .dsp_weight_i(din2_i[i*16+:16]),
    .dsp_output_o(mac_output[i])
 );
    end
    endgenerate 
 
 integer k;   
 
 always@(*) begin
     for(k = 0; k < 98; k = k + 1)begin
       mul_o_r[k*48+:48] = mac_output[k];
     end
end
    
        
endmodule
module MAC(
 input       wire                                clk_i,
 input       wire                                rstn_i,
 input       wire                                clear_i,
 input       wire                                dsp_enable_i,
 input       wire                                dsp_valid_i,
 input       wire        signed      [15:0]       dsp_input_i,
 input       wire        signed      [15:0]       dsp_weight_i,
 output      wire        signed      [47:0]      dsp_output_o
 );
 reg         signed      [47:0]      partial_sum;
 reg         signed      [47:0]      store_sum;
reg clear_r;
reg clear_l;

wire        signed      [47:0]      dsp_output;
reg valid_r;
always@(posedge clk_i or negedge rstn_i) begin
      if(!rstn_i) begin
        clear_r<= 0;
        clear_l<= 0;
      end
      else begin
        clear_r <= clear_i;
        clear_l <= clear_r;
        
        valid_r <= dsp_valid_i;
      end
end

 always@(posedge clk_i or negedge rstn_i) begin
    if(!rstn_i) begin
      partial_sum<= 0;
      store_sum<= 0;
    end
    else begin
      if (clear_r) begin
        partial_sum <= $signed({dsp_output[31], dsp_output[29:0]});
        end
        
       else if (clear_l) begin
        partial_sum <= 0;
       end
       else begin
        partial_sum<= $signed({dsp_output[31], dsp_output[29:0]});
       end
       end
 end
 assign dsp_output_o = (valid_r) ? dsp_output : 0 ;
 
 
 dsp_macro_1 DSP_for_MAC(
 .CLK(clk_i),  // input wire CLK
 .CE(dsp_enable_i),    // input wire CE
 .SCLR(clear_r),
 .A(dsp_input_i),      // input wire [7 : 0] A
 .B(dsp_weight_i),      // input wire [7 : 0] B
 .C(partial_sum),      // input wire [30 : 0] C
 .P(dsp_output)      // output wire [31 : 0] P
 );
 endmodule
