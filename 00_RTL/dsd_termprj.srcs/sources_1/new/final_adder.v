module final_adder#(                  //250528 parkjunha. addertree for layer 1.
    parameter   INPUTNUMBER = 98,   //number of input data
    parameter   I_BITSIZE = 48,     //bit size of input data
    parameter   O_BITSIZE = 16      //bit size of output data
)(
    input   wire                                  i_clk,
    input   wire                                  i_rstn,
    input   wire                                  i_en,
    input   wire    [INPUTNUMBER*I_BITSIZE-1:0]   i_datas, 
    input   wire                                  i_l2_ready, //ready signal from layer2
    output  wire                                  for_relu,
    output  reg     [O_BITSIZE-1:0]              o_data,
 //   output  reg                                   o_ready, //on when addertree's 7 phase done
    output  reg                                   o_valid // addertree outputs all done(total 64)
        );
(* ram_style = "distributed" *)     reg     [I_BITSIZE-1:0]     r_datas     [0:INPUTNUMBER-1];
            reg                         r_en;
            reg                         r_en_delay; //0613
            reg     [2:0]               r_ready; // up + 1 when addertree's each phase calculation done
            reg     [7-1:0]             r_ready_cnt; //count numbers of addertree outputs
            reg                         r_adder_rstn; //adder reset signal
            reg                         r_last_adder_rstn;
            //reg     [O_BITSIZE-1:0]     r_o_data;
            wire                        w_adder_rstn; //adder reset signal
            wire                        w_last_adder_rstn;

            wire     [I_BITSIZE-1:0]     w_final;
            wire     [I_BITSIZE-1:0]     w_sixth     [0:1];
            wire     [I_BITSIZE-1:0]     w_fifth     [0:2];
            wire     [I_BITSIZE-1:0]     w_forth     [0:5];
            wire     [I_BITSIZE-1:0]     w_third     [0:11];
            wire     [I_BITSIZE-1:0]     w_second    [0:23];
            wire     [I_BITSIZE-1:0]     w_first     [0:48];

            wire                        w_en;
            wire                        w_en_delay; //0613

    genvar i; //number of adder i made
    generate for(i=0;i<97;i=i+1)begin:adders //instanciation
            if(i==96)begin
                adderadder     adder8(
                    .i_clk      (i_clk),
                    .i_rstn     (w_last_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_sixth[2*(i-96)]),
                    .i_input2   (w_sixth[2*(i-96)+1]),
                    .o_dout     (w_final)                   
                );
            end
            else if(i==95)begin
                adderadder     adder7(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_fifth[2*(i-94)]),
                    .i_input2   (w_first[48]), // 이 부분에 순서가 맞는지 확인이 또 필요함 
                    .o_dout     (w_sixth[i-94])                   
                );

            end
            else if(i==94)begin
                adderadder     adder6(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_fifth[2*(i-94)]),
                    .i_input2   (w_fifth[2*(i-94)+1]),
                    .o_dout     (w_sixth[i-94])                   
                );
            end
            else if(i>=91)begin
                adderadder     adder5(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_forth[2*(i-91)]),
                    .i_input2   (w_forth[2*(i-91)+1]),
                    .o_dout     (w_fifth[i-91])                   
                );
            end
            else if(i>=85)begin
                adderadder     adder4(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_third[2*(i-85)]),
                    .i_input2   (w_third[2*(i-85)+1]),
                    .o_dout     (w_forth[i-85])                   
                );
            end 
            else if(i>=73)begin
                adderadder     adder3(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_second[2*(i-73)]),
                    .i_input2   (w_second[2*(i-73)+1]),
                    .o_dout     (w_third[i-73])                   
                );
            end
            else if(i>=49)begin
                adderadder     adder2(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (w_first[2*(i-49)]),
                    .i_input2   (w_first[2*(i-49)+1]),
                    .o_dout     (w_second[i-49])                   
                );
            end
            else begin
                adderadder     adder1(
                    .i_clk      (i_clk),
                    .i_rstn     (w_adder_rstn),
                    .i_en       (w_en),
                    .i_input1   (r_datas[2*i]),
                    .i_input2   (r_datas[2*i+1]),
                    .o_dout     (w_first[i])                   
                );
            end



        end
    endgenerate

    assign w_en = r_en;
    //assign w_en_delay = r_en_delay; //0613
    assign w_last_adder_rstn = r_last_adder_rstn;
    

    integer j;
reg valid_rr;
    always @(posedge i_clk or negedge i_rstn) begin
        if (!i_rstn) begin
        o_data <= 0;
        valid_rr <= 0;
            for (j = 0; j < INPUTNUMBER; j = j + 1) begin
                r_datas[j] <= 0;
            end
            r_en  <= 1'b0;
            //r_en_delay <= 1'b0;
        end 
        else if (i_en) begin
            for (j = 0; j < INPUTNUMBER; j = j + 1) begin
                r_datas[j] <= i_datas[j*I_BITSIZE +: I_BITSIZE];
            end
            r_en <= 1'b1;
            valid_rr <= 0;
            //r_en_delay <= r_en; //0613
        end
        else if(r_ready == 3'b111)begin
            o_data <= w_final[23:8]; //Q(8.8)
            r_en <= 1'b0;
            valid_rr <=1;
            //r_en_delay <= r_en; //0613
        end
    end
    

    always@(posedge i_clk or negedge i_rstn)begin
        if (!i_rstn) begin   
            r_ready <= 0; 
        end 
        else if (r_en) begin
            r_ready <= r_ready + 1'b1;
//            o_ready <= &r_ready;
        end
        else begin
            r_ready <= 1'b0;
 //           o_ready <= &r_ready;
        end
    end

    always@(posedge i_clk or negedge i_rstn)begin
        if(!i_rstn)begin
            r_ready_cnt <= 7'd0;
            o_valid <= 1'b0;
        end
        else if(r_ready_cnt == 7'd64)begin
            o_valid <= 1'b1;
            r_ready_cnt <= 7'd0;
        end
        else if(r_ready == 3'd7)begin
            r_ready_cnt <= r_ready_cnt + 7'd1;
        end
        else if(i_l2_ready) begin
            o_valid <= 1'b0;
        end
    end

    always@(posedge i_clk or negedge i_rstn)begin
        if(!i_rstn)begin
            r_adder_rstn <= 1'b0;
        end
        else if(r_ready == 3'd7)begin
            r_adder_rstn <= 1'b0;
        end
        else begin
            r_adder_rstn <= 1'b1;
        end
    end

    always@(posedge i_clk or negedge i_rstn)begin
    if (!i_rstn) begin
     r_last_adder_rstn <= 0;
    end
    else begin
        r_last_adder_rstn <= r_adder_rstn;
    end
   end
    assign w_adder_rstn = r_adder_rstn;

    assign for_relu = valid_rr;


endmodule



module adderadder#( //250527 parkjunha. fundamental adder module desgin for addertree.
    parameter BITSIZE = 48
    )(
        input   wire          i_clk,
        input   wire          i_rstn,
        input   wire          i_en,
        input   wire  [BITSIZE-1:0]  i_input1,
        input   wire  [BITSIZE-1:0]  i_input2,
       
        output   reg  [BITSIZE-1:0]  o_dout
        
    );  
    always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)begin
            o_dout <= 0;
        end
        else if(i_en == 1'b1)begin
            o_dout <= i_input1 + i_input2;
        end   
    end
endmodule