module router_fsm(clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,
                  fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,
                  laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

input clock,resetn,pkt_valid;
output busy;
input parity_done;
input [1:0]data_in;
input soft_reset_0,soft_reset_1,soft_reset_2;
input fifo_full;
input low_pkt_valid;
input fifo_empty_0,fifo_empty_1,fifo_empty_2;
output detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;

parameter DECODE_ADDRESS=3'b000,
          WAIT_TILL_EMPTY=3'b001,
          LOAD_FIRST_DATA=3'b010,
          LOAD_DATA=3'b011,
          LOAD_PARITY = 3'b100,
          FIFO_FULL_STATE=3'b101,
          LOAD_AFTER_FULL=3'b110,
          CHECK_PARITY_ERROR= 3'b111;
          
reg [2:0]state,next_state;
reg [1:0]addr; 

assign detect_add=(state==DECODE_ADDRESS);
assign lfd_state=(state==LOAD_FIRST_DATA);
assign busy =(state==LOAD_FIRST_DATA || state== LOAD_PARITY || state == FIFO_FULL_STATE || state == LOAD_AFTER_FULL || state==WAIT_TILL_EMPTY ||state==CHECK_PARITY_ERROR);
assign ld_state =(state==LOAD_DATA);
assign laf_state =(state==LOAD_AFTER_FULL);
assign full_state =(state==FIFO_FULL_STATE);
assign write_enb_reg =(state==LOAD_DATA || state==LOAD_PARITY || state==LOAD_AFTER_FULL);
assign rst_int_reg =(state==CHECK_PARITY_ERROR);

         //storing address
always @(posedge clock) begin
if(~resetn) 
addr<=2'b00;
else if(detect_add)
addr<=data_in;
end



always @(posedge clock) begin
if(~resetn)
state<=DECODE_ADDRESS;
else if(((soft_reset_0)&&(data_in[1:0]==2'b00)) || ((soft_reset_1)&&(data_in[1:0]==2'b01)) || ((soft_reset_2)&&(data_in[1:0]==2'b10)))
state<=DECODE_ADDRESS;
else
state<=next_state;
end

always @(*)
begin
case(state)
DECODE_ADDRESS:begin 
               if((pkt_valid && (data_in[1:0]==2'b00) && fifo_empty_0)||(pkt_valid && (data_in[1:0]==2'b01) && fifo_empty_1) ||
                   (pkt_valid && (data_in[1:0]==2'b10) && fifo_empty_2))
                   next_state=LOAD_FIRST_DATA;
               else if((pkt_valid && (data_in[1:0]==2'b00) && !fifo_empty_0)|| (pkt_valid && (data_in[1:0]==2'b01) && 
               !fifo_empty_1) || (pkt_valid && (data_in[1:0]==2'b10) && !fifo_empty_2))
                   next_state=WAIT_TILL_EMPTY;
               else next_state=DECODE_ADDRESS;
               end
LOAD_FIRST_DATA:begin 
                next_state=LOAD_DATA;
                end
LOAD_DATA:begin
          if(fifo_full == 1'b1)
          next_state = FIFO_FULL_STATE;
          else if(!(fifo_full)&&(!(pkt_valid)))
             next_state=LOAD_PARITY;
          else next_state=LOAD_DATA;
          end
LOAD_PARITY:begin
            next_state=CHECK_PARITY_ERROR;
            end
CHECK_PARITY_ERROR:begin
                   if(!fifo_full) next_state=DECODE_ADDRESS;
                   else next_state = FIFO_FULL_STATE;
                   end
FIFO_FULL_STATE:begin
                if(fifo_full == 1'b0) next_state=LOAD_AFTER_FULL;
                else next_state=FIFO_FULL_STATE;
                end
LOAD_AFTER_FULL:begin
                if(!parity_done && (low_pkt_valid)) next_state=LOAD_PARITY;
                else if(!parity_done && !(low_pkt_valid)) next_state=LOAD_DATA;
                else if(parity_done == 1'b1) next_state=DECODE_ADDRESS;
                else next_state = LOAD_AFTER_FULL;   
                end
WAIT_TILL_EMPTY:begin
                if((fifo_empty_0 && (addr==2'd0)) || (fifo_empty_1 && (addr==2'd1)) || (fifo_empty_2 && (addr==2'd2)))
                next_state=LOAD_FIRST_DATA;
                else next_state=WAIT_TILL_EMPTY;
                end
default:next_state=DECODE_ADDRESS;
endcase
end

 endmodule               

                   


          

