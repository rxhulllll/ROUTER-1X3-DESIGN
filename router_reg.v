module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,
detect_add,ld_state,laf_state,
full_state,lfd_state,parity_done,low_pkt_valid,err,dout);
input clock,resetn,pkt_valid;
input[7:0]data_in;
input fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
output reg parity_done,low_pkt_valid,err;
output reg[7:0]dout;

//internal registers
reg [7:0]header_byte,fifo_full_state_byte,internal_parity,packet_parity;

//output logic
always@(posedge clock)
begin
if(!resetn)
dout<=8'b0;
else 
begin
if(detect_add && pkt_valid)
header_byte<=data_in;
else if(lfd_state)
dout<=header_byte;
else if(ld_state && !fifo_full)
dout<=data_in;
else if(ld_state && fifo_full)
fifo_full_state_byte<=data_in;
else
begin
if(laf_state)
dout<=fifo_full_state_byte;
end
end
end



//head_byte and fifo_full state byte
always@(posedge clock)
begin
if(!resetn)
{header_byte,fifo_full_state_byte}<=0;
else 
begin
if(pkt_valid && detect_add)
header_byte<=data_in;
else if(ld_state && fifo_full)
fifo_full_state_byte<=data_in;
end
end

//parity_done logic
always@(posedge clock)
begin
if(!resetn)
parity_done<=0;
else 
begin 
if(ld_state && !fifo_full && !pkt_valid)
parity_done<=1'b1;
else if(laf_state && !parity_done && low_pkt_valid)
parity_done<=1'b1;
else
begin
if(detect_add)
parity_done<=1'b0;
end
end
end

//low_pkt_valid
always@(posedge clock)
begin
if(~resetn)
low_pkt_valid<=1'b0;
else 
begin
if(rst_int_reg)
low_pkt_valid<=0;

else if(ld_state==1'b1 && ~pkt_valid)
low_pkt_valid<=1'b1;
end
end

//packet_parity logic
always@(posedge clock)
begin
if(!resetn)
packet_parity<=0;
else if((ld_state && ~pkt_valid && ~fifo_full) || (laf_state && low_pkt_valid && ~parity_done))
packet_parity<=data_in;
else if(~pkt_valid && rst_int_reg)
packet_parity<=0;
else
begin
if(detect_add)
packet_parity=0;
end
end

//internal parity
always@(posedge clock)
begin
if(!resetn)
internal_parity<=0;

else if(detect_add)
internal_parity<=0;

else if(lfd_state)
internal_parity<=header_byte;

else if(ld_state && pkt_valid && ~full_state)
internal_parity<=internal_parity^data_in;

else if(~pkt_valid && rst_int_reg)
internal_parity<=0;

end

//error logic
always@(posedge clock)
begin
if(!resetn)
err<=0;
else 
begin
if(parity_done==1'b1 && (packet_parity!=internal_parity))
err<=1'b1;
else
err<=1'b0;
end
end
endmodule 
