module glbl_ctrl #(
    parameter BUF_ADDR_WIDTH = 32
)(
    // system interface
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        start_i,
    output  wire                        done_intr_o,
    output  wire                        done_led_o,
    output  wire                        prcss_start,
    input   wire                        prcss_done,
    input   wire    [32*10-1:0]         prcss_data,
    output  wire                        y_buf_en,
    output  wire                        y_buf_wen,
    output  wire [BUF_ADDR_WIDTH-1:0]   y_buf_addr,
    output  wire [BUF_ADDR_WIDTH-1:0]   y_buf_data
);
localparam  IDLE = 'd0,
            LOAD = 'd1,
            SEND = 'd2,
            DONE = 'd3;
reg [1:0] state, nextState;
reg [3:0] puDone_Cnt;
(* ram_style = "block" *) reg [31:0] y_buf_temp [0:99];//Final Temp Buffer
reg y_buf_en_temp;
reg [BUF_ADDR_WIDTH-1:0]   y_buf_addr_temp;
reg done_intr_temp;
integer i;
always @(posedge clk) begin
    if (!rst_n) begin
        nextState <= IDLE;
    end
    else begin
        case (state)
            IDLE:   if(start_i) nextState <= LOAD;
            LOAD:   if(puDone_Cnt == 10) nextState <= SEND;
            SEND:   if(y_buf_addr_temp == 98) nextState <= DONE;
            default:nextState <= nextState;
        endcase
    end
end
always @(posedge clk ) begin
    if (!rst_n) state <= IDLE;
    else state <= nextState;
end
always @(posedge clk ) begin
    if (!rst_n) begin
        y_buf_en_temp <= 0;
        y_buf_addr_temp <= {BUF_ADDR_WIDTH{1'b1}};
        done_intr_temp <= 0;
    end
    else begin
        case (state)
            SEND: begin
                y_buf_en_temp <= 1;
                y_buf_addr_temp <= y_buf_addr_temp + 1;
                done_intr_temp <= 0;
            end
            DONE: begin
                y_buf_en_temp <= 0;
                y_buf_addr_temp <= {BUF_ADDR_WIDTH{1'b1}};
                done_intr_temp <= 1;
            end
            default: begin
                y_buf_en_temp <= 0;
                y_buf_addr_temp <= {BUF_ADDR_WIDTH{1'b1}};
                done_intr_temp <= 0;
            end
        endcase
    end
end
//Final Temp Buffer Logic
always @(posedge clk ) begin
    if (!rst_n) begin
        puDone_Cnt <= 0;
    end
    else begin
        if (prcss_done) begin
            puDone_Cnt <= puDone_Cnt + 1;
        end
    end
end
always @(posedge clk ) begin
    if (!rst_n) begin
        for ( i=0; i<100; i=i+1) begin
            y_buf_temp[i] <= 0;
        end
    end
    else begin
        if (prcss_done) begin
            for ( i=0; i<10; i=i+1) begin
                y_buf_temp[puDone_Cnt*10+i] <= prcss_data[32*(10-i)-1-:32];
            end
        end
    end
end
//Signals of Final Temp Buffer
assign y_buf_en = y_buf_en_temp;
assign y_buf_wen = y_buf_en_temp;
assign y_buf_addr = y_buf_addr_temp << 2;
assign y_buf_data = y_buf_temp[y_buf_addr_temp];
//Signals for System Interface
assign done_intr_o = done_intr_temp;
assign done_led_o = done_intr_temp;
assign prcss_start = start_i;
endmodule
