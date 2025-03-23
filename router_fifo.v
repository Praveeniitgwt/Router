module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);
parameter depth =5'd16,width=4'd9;
input clock,resetn,soft_reset,write_enb,read_enb,lfd_state;
input [width-2 : 0]data_in;
output reg [width-2 : 0]data_out;
output empty,full;
reg [width-1 : 0]mem[depth-1 : 0];
reg [7:0]rd_counter;
reg temp;
reg [4:0]rd_pntr,wr_pntr;
integer i;

assign full=((wr_pntr[4]!=rd_pntr[4])&&(wr_pntr[3:0]==rd_pntr[3:0]));
assign empty=(wr_pntr==rd_pntr);

always@(posedge clock)
begin
if(!resetn)
temp<=1'b0;
else
temp<=lfd_state;
end

always@(posedge clock) begin
if(!resetn) begin
for(i=0;i<16;i=i+1) begin
mem[i]<=0;
wr_pntr<=0; end
 end
else if(soft_reset)begin
for(i=0;i<16;i=i+1) begin
mem[i]<=0;
wr_pntr<=0; end
end
else if(write_enb &&(!full)) begin
{mem[wr_pntr[3:0]][8],mem[wr_pntr[3:0]][7:0]}<={temp,data_in};
wr_pntr<=wr_pntr+1'b1; end
else
mem[wr_pntr[3:0]]<=mem[wr_pntr[3:0]]; end

always@(posedge clock) begin
if(!resetn) begin
rd_counter<=0; end
else if(soft_reset) begin
rd_counter<=0; end
else if(mem[rd_pntr[3:0]][8]==1'b1) begin
rd_counter<={data_in[7:2]} + 1'b1; end
else if(read_enb &&(!empty)) begin
rd_counter<=rd_counter-1'b1; end
else begin
rd_counter<=rd_counter; end
end

always@(posedge clock) begin
if(!resetn) begin
data_out<=0;
rd_pntr<=0; end
else if(soft_reset) begin
data_out<=8'hzz;
rd_pntr<=0; end
else if(rd_counter==0) begin
data_out<=8'hzz; end
else if(read_enb &&(!empty)) begin
data_out<={mem[rd_pntr[3:0]][7:0]};
rd_pntr<=rd_pntr+1'b1; end
else begin
data_out<= 8'hzz; end
end

endmodule
