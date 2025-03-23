module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,
       parity_done,low_pkt_valid,err,d_out);
       
input clock,resetn,pkt_valid;
input [7:0]data_in;
input fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
output reg parity_done,err;
output low_pkt_valid;
output reg [7:0]d_out;

reg [7:0]header_byte,fifo_full_byte,internal_parity,packet_parity;
wire parity_check;

//d_out output logic
always @(posedge clock) begin
if(!resetn) begin
d_out<=8'b00000000; 
end
else if(lfd_state)
d_out<=header_byte;
else if(pkt_valid && ld_state && (!fifo_full))
d_out<=data_in;
else if(ld_state && fifo_full)
begin
fifo_full_byte <= data_in;
if(laf_state) begin
d_out<=fifo_full_byte; end
else
d_out<=d_out;
end
else if(~pkt_valid)
d_out<=data_in;
else
d_out<=d_out;
end


always @(posedge clock) begin
if(!resetn)
header_byte <= 8'b00000000;
else if(detect_add && pkt_valid&&(data_in[1:0] != 2'b11))
header_byte <= data_in;
else
header_byte <= header_byte;
end

always @(posedge clock) begin
if((ld_state && (~fifo_full) && (~pkt_valid)) || (laf_state && ~pkt_valid))
parity_done <= 1'b1;
else if(detect_add)
parity_done<=1'b0;
else
parity_done<=parity_done;
end

always @(posedge clock) begin
if(~resetn)
internal_parity <= 8'd0;
else if(detect_add)
internal_parity <= internal_parity ^ header_byte;
else if(pkt_valid && !full_state)
internal_parity <= internal_parity ^ data_in;
else
internal_parity <= internal_parity;
end

always @(posedge clock) begin
if(!resetn)
packet_parity <= 8'd0;
else if(~pkt_valid)
packet_parity <= data_in;
else
packet_parity <= packet_parity;
end

always @(posedge clock) begin
if(!resetn)
err <= 1'b0;
else if(!pkt_valid && rst_int_reg) begin
if(parity_check) begin
err <= 1'b0;
end
else begin
err <= 1'b1;
end
end
else
err <= err;
end

assign parity_check = (internal_parity == packet_parity)?1'b1:1'b0;
assign low_pkt_valid = (ld_state && ~pkt_valid);

endmodule





