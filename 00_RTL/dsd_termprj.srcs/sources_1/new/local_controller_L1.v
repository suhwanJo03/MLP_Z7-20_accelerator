`timescale 1ns / 1ps

//5-31 �ϴ� cnt �κп� 15�� �ϴ� �� ���� �ʿ��� ���̰�, state �Ѿ�� �������� 1 - > 2 ���� state �и��� �ɷ� enable ��ȣ ����� �Ѵ�. 

module local_controller_L1#(
 parameter m_DEPTH = 512,
 parameter m_ADDR_WIDTH = $clog2(m_DEPTH),
  parameter w_DEPTH = 98,                
 parameter w_ADDR_WIDTH = $clog2(w_DEPTH)
 
)(
    input   wire                         clk_i                      ,
    input   wire                         rstn_i                     ,
    input   wire                         start_i                    ,
    input   wire                         mok_i                      ,
    input   wire                         wait_f                     ,
    output  wire    [w_ADDR_WIDTH-1:0]   w_addr_o                   , // din 1 bram address �̹��� 784�� �ּ�
    output  wire                         w_en_o                     ,   // din 1 bram enable
    output  wire    [m_ADDR_WIDTH-1:0]   mat_addr_o                 , // din 1.1 bram addr 784x64 ��� 784�� �Ѿ ���� ����ؼ� �ּҰ� ���ϵ��� �������Ѵ�.
    output  wire                         mat_en_o                   ,   // din1.1 bram en
    output  wire                         mac_en_o                   ,
    output  wire                         mac_clear_o                ,
    output  wire                         mac_ok_o                   , // �̰ɷ� ���� �������� �����.
    output  wire                         done_o                     ,// done��ȣ�� pu���׵� �༭ ���� ���� ���� ����ϵ��� �ϴ� mok�� �޵��� �Ѵ�. 
    output  wire                         next_bram                  ,
    output  wire                         valid_o                     
    );
    localparam  IDLE = 3'b000,//0
                RUN =  3'b001, //1
                OK   =  3'b011,  //3
              
                RE   =  3'b100; // 4 
    reg                                 done;
    reg                                 r_next_bram;
    reg                                 mac_d_r; // mac_done�� reg ��ȣ
    reg    [w_ADDR_WIDTH-1:0]           w_addr;
    reg                                 w_en;
    reg    [m_ADDR_WIDTH-1:0]           mat_addr;
    reg                                 mat_en;
    reg                                 mac_en;
    reg                                 mac_clear;
    reg    [2:0]                        state;
    reg    [2:0]                        next_state;
    reg    [5:0]                        state_cnt; // 98�� ���� 8���ϸ� �ʱ�ȭ ��Ű�� �ڵ� 
    reg    [7-1:0]                      cnt_mac; //98�� count �ϵ��� 
    reg                                 mac_en_r;
    reg                                 valid_r;
    // bram  �߰��� �� addr �� �Ҵ�� bit �� �����ؾ� �Ѵ�.
    
    /* ���� �����ؾ� �� �� cnt�� 98�� ������ clear ��ȣ�� �ش�. �ڵ����ŷ ��ȣ�� �������Ѵ�.
     ouptut ������ pu�� ok ��ȣ�� ������ input�� pu�� ok�� ������  �� �����ϵ��� ������ �Ѵ�.
     ctrl�� ���� �� �� �ִ� ��� ��ȣ�� ������, pu�� �޾Ƽ� ���� ������ ��� ��ȣ�� ������, �׶� ctrl�� bram�� �ִ� ���� pu�� �Ҵ��Ű���� �ϴ� ��ȣ�� ������ �Ѵ�.
     ���� start ��ȣ�� �޴´� -> pu�� ���� �������� ����� -> �����ϴٰ� ���� �޴´� -> �������� ����.
    */
      
      assign valid_o = valid_r;
      assign w_addr_o = w_addr;
      assign w_en_o = w_en;
      assign mat_addr_o = mat_addr;
      assign mat_en_o = mat_en;
      assign mac_en_o = mac_en_r;
      assign mac_clear_o = mac_clear;
      assign done_o = done;
      assign mac_ok_o = mac_d_r;
    
 /*  always @(posedge clk_i) begin
    if (!rstn_i) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end
*/
    always @(posedge clk_i or negedge rstn_i) begin
     if(!rstn_i) begin
      mac_en_r <= 0;
     end
     else begin
      mac_en_r <= mac_en;
     end
    end
    
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            state <= IDLE;        
        end
         else begin
            state <= next_state;
        end
    end
    
    
    always @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        next_state <= IDLE;
        mac_d_r  <= 0;
  //      done <= 0;
        state_cnt  <= 0;         
      //  mac_clear <= 1;
    end
    else begin
        case (state)
            IDLE: begin
                if (start_i) begin // ���� start ��ȣ�� ó���� �� �� 1 �ż� ok�� �Ѿ�� �� ���ķ� 98 ī��Ʈ 8�� �� �� ���� �� ���� �ʾƵ� �ȴ�. 
                    mac_d_r <= 1; // �̰� �ѹ��� ������ �ʱ�ȭ �ٽ� 0���� ������ �ϴµ� 
                    next_state <= OK;
                    state_cnt <= 4'b0000;
             //       done <= 0;
           //       mac_clear <=1;
                end
            end
            OK: begin // PU���� ���� �����ϴٴ� ��ȣ �޾ƾ��� RUN���� �Ѿ�� �ȴ�.
            //3
              if(mok_i) begin // ok state�� ���� �� �Է°����� mok_i�� �ȵ��� ��� ����ؼ� mac_d_r�� 1�� �������鼭 ��ũ�� ����Ѵ�. ��ũ �ϰ� mok_i�� ���� �� ���� RUN���� 
               next_state <= RUN;
               mac_d_r <= 0;
          //     mac_clear <=0;
              end
              else begin
               next_state <= OK;
               mac_d_r <= 1; // OK state�� �Ѿ������ mok_i�� ���� ������ ������ RUN���� �Ѿ�� ���� ���¿��� ��� 1�� �ִ� ü�� OK state�� �ӹ�����.
        //       mac_clear <=0;
              end
            end
            
            RUN: begin //1
                  if (state_cnt == 63 && cnt_mac == 7) begin
                    state_cnt <= 0;
        //            done <= 1;
           //         mac_clear<= 1;
                    next_state <= RE;
                  end
                
                   else if (cnt_mac == 7) begin
                   state_cnt <= state_cnt + 1;
       //            done <= 1;
                   next_state <= RUN;
      //             mac_clear<= 1;
                end
              
            end
            RE: begin //4
            if(1) begin
    //          mac_clear <= 1;
              next_state <= IDLE;
       //       done <= 0;
              end
            else begin
       //     done <= 0;
            end
            end
            default: begin
                next_state <= IDLE;
            end
        endcase
    end
end

    always @(posedge clk_i) begin
    if (!rstn_i) begin
        w_addr <= 0;
        w_en <= 0;
        mat_addr <= 0;
        mat_en <= 0;
        r_next_bram <= 0;
        mac_en <= 0;
        mac_clear <= 0;
        done <= 0;
        valid_r <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                w_addr <= 0;
                w_en <= 0;
                mat_addr <= 0;
                mat_en <= 0;
                r_next_bram <= 0;
                mac_clear <= 0;
                done <= 0;
                mac_en <= 0;
                valid_r <= 0;
                cnt_mac <= 0;
            end
            RUN: begin // ���⼭ next_state�� 2�� �Ѿ �� state�� 1�� �����ؼ� enable ��ȣ�� �߰��� �߰� �Ǵµ�
            // ���⼭ 
            valid_r <= 0;
            if (w_addr == 7 && mat_addr == 511) begin
              mac_clear <= 1;
              done <= 1;
              w_addr <= 0;
              valid_r <= 1;
              mat_addr <= 0;
              cnt_mac<= 0;
              mac_en <= 0;
              mat_en <= 0;
              w_en <= 0;
            end
            else if (w_addr == 7 && cnt_mac == 7)begin
                      w_addr <= 0;
                      cnt_mac<= 0;
                      mat_addr <= mat_addr + 1;
                      w_en <= 0;
                      mac_clear <= 1;
                     done <= 1;
                     mat_en <= 1;
                     r_next_bram <= 0;
                     mac_en <= 1;
                end
               else if (w_addr == 7)begin
                      w_addr <= 0;
                      mat_addr <= mat_addr + 1;
                      w_en <= 1;
                     mac_clear <= 0;
                     done <= 0;
                     mat_en <= 1;
                     r_next_bram <= 0;
                     mac_en <= 1;
                end
                else if (cnt_mac == 7) begin
                     w_en <= 1;
                     w_addr <= w_addr + 1;
                     mat_addr <= mat_addr + 1;
                     mac_clear <= 0;
                     done <= 0;
                     mat_en <= 1;
                     mac_en <= 1;
                     r_next_bram <= 0;
                     cnt_mac <= 0;
  
                end
                else begin
                    if (w_en_o && mat_en_o) begin
                        mac_en <= 1;
                           cnt_mac <= cnt_mac + 1;
                            w_addr <= w_addr + 1;
                            w_en <= 1;
                            mac_clear <= 0;
                     done <= 0;
                            r_next_bram <= 0;
                            mat_addr <= mat_addr + 1;
                            mat_en <= 1;
                    end
                    else begin
                        w_addr <= w_addr;
                        w_en <= 1;
                        mat_addr <= mat_addr;
                        mat_en <= 1;
                        mac_clear <= 0;
                     done <= 0;
                        r_next_bram <= 0;
                        mac_en <= 1;
                    end
                end
            end
            
            RE: begin // 784�� �ʱ�ȭ ��Ű��, 784x64�� �״�� �����ϰ� �ϵ���. ���⼭ mac_clear ��ȣ 8�� �������� �� ���ǹ� �޾Ƽ� clear ��ȣ�� ����Ѵ�. 
                      // �� �κп��� ���� �̹����� �Ѿ� ���� ��ȣ ���� ����� 
                w_addr <= 0;
                w_en <= 0;
                mac_clear <= 1;
                valid_r <= 0;
                mat_addr <= 0;
                mat_en <= 0;
                mac_en <= 0;
                r_next_bram <= 1;
            end
        endcase
    end
end
endmodule