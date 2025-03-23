module router_syn(detect_add,data_in,write_enb_reg,clock,resetn,valid_out_0,valid_out_1,valid_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,
                  fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
                  
input detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2;
input [1:0]data_in;
output reg [2:0]write_enb;
output reg fifo_full;
output valid_out_0,valid_out_1,valid_out_2;
input empty_0,empty_1,empty_2;
output reg soft_reset_0,soft_reset_1,soft_reset_2;
input full_0,full_1,full_2;
reg [1:0]temp;
reg [4:0]count_0,count_1,count_2;

always @(posedge clock) begin
if(~resetn)
temp<=2'b00;
else if(detect_add)
temp<=data_in;
end

always @(*) begin
case(temp)
2'b00:fifo_full=full_0;
2'b01:fifo_full=full_1;
2'b10:fifo_full=full_2;
default:fifo_full=1'b0;
endcase
end

assign valid_out_0=~empty_0;
assign valid_out_1=~empty_1;
assign valid_out_2=~empty_2;

always @(*) begin
if(write_enb_reg) begin
case(temp)
2'b00:write_enb=3'b001;
2'b01:write_enb=3'b010;
2'b10:write_enb=3'b100;
endcase end
else write_enb=3'b000;
end

always @(posedge clock) begin
if(~resetn)
count_0<=5'b0;
else if(valid_out_0) begin
if(!read_enb_0) begin                
if(count_0==5'd29) begin 
soft_reset_0<=1'b1;
count_0<=5'b0; end
else begin
count_0<=count_0+1'b1;
soft_reset_0<=1'b0; end
end
end
else count_0<=5'b0; end

always @(posedge clock) begin
if(~resetn)
count_1<=5'b0;
else if(valid_out_1) begin
if(!read_enb_1) begin                
if(count_1==5'd29) begin 
soft_reset_1<=1'b1;
count_1<=5'b0; end
else begin
count_1<=count_1+1'b1;
soft_reset_1<=1'b0; end
end
end
else count_1<=5'b0; end

always @(posedge clock) begin
if(~resetn)
count_2<=5'b0;
else if(valid_out_2) begin
if(!read_enb_2) begin                
if(count_2==5'd29) begin 
soft_reset_2<=1'b1;
count_2<=5'b0; end
else begin
count_2<=count_2+1'b1;
soft_reset_2<=1'b0; end
end
end
else count_2<=5'b0; end

endmodule



