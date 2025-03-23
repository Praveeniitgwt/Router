module router_top(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,
                  valid_out_0,valid_out_1,valid_out_2,error,busy);
                  
input clock,resetn;
input read_enb_0,read_enb_1,read_enb_2;
input [7:0]data_in;
input pkt_valid;
output [7:0]data_out_0,data_out_1,data_out_2;
output valid_out_0,valid_out_1,valid_out_2;
output error,busy;
wire [2:0]write_enb;
wire [7:0]d_out;

router_fifo fifo_0(clock,resetn,write_enb[0],soft_reset_0,read_enb_0,d_out,lfd_state,empty_0,data_out_0,full_0);
router_fifo fifo_1(clock,resetn,write_enb[1],soft_reset_1,read_enb_1,d_out,lfd_state,empty_1,data_out_1,full_1);
router_fifo fifo_2(clock,resetn,write_enb[2],soft_reset_2,read_enb_2,d_out,lfd_state,empty_2,data_out_2,full_2);

router_syn synchronizer(detect_add,data_in[1:0],write_enb_reg,clock,resetn,valid_out_0,valid_out_1,valid_out_2,
                        read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,
                        soft_reset_1,soft_reset_2,full_0,full_1,full_2);
                        
router_fsm fsm(clock,resetn,pkt_valid,busy,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,
               fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,
               full_state,write_enb_reg,rst_int_reg,lfd_state);
               
router_reg register(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,
                    parity_done,low_pkt_valid,error,d_out);
endmodule                
