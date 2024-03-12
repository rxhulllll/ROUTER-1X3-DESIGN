module router_sync(detect_add,data_in,write_enb_reg,clock,resetn,
vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,
write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

//input ports 
input detect_add;
input [1:0]data_in;
input write_enb_reg;
input clock,resetn;
input read_enb_0,read_enb_1,read_enb_2;
input empty_0,empty_1,empty_2;
input full_0,full_1,full_2;

//output ports
output vld_out_0,vld_out_1,vld_out_2;
output reg [2:0]write_enb;
output reg fifo_full;
output reg soft_reset_0,soft_reset_1,soft_reset_2;

//register declaration
reg [1:0]addr;
reg [4:0]timer_0,timer_1,timer_2;

//timer_0 and soft_reset_0 logic
always@(posedge clock)
begin
if(!resetn)
begin
timer_0<=0;
soft_reset_0<=0;
end

else if(vld_out_0)
begin
if(!read_enb_0)
begin
if(timer_0 ==5'd29) // we will be cheching for 30th clock pulse 
begin
soft_reset_0<=1'b1;
timer_0<=0;
end
else
begin
soft_reset_0<=1'b0;
timer_0<=timer_0+1;
end
end
else timer_0<=0;
end
else timer_0<=0;
end


//timer_1 and soft_reset_1 logic
always@(posedge clock)
begin
if(!resetn)
begin
timer_1<=0;
soft_reset_1<=0;
end

else if(vld_out_1)
begin
if(!read_enb_1)
begin
if(timer_1==5'd29) // we will be cheching for 30th clock pulse 
begin
soft_reset_1<=1'b1;
timer_1<=0;
end
else
begin
soft_reset_1<=1'b0;
timer_1<=timer_1+1;
end
end
else timer_1<=0;
end
else timer_1<=0;
end


//timer_2 and soft_reset_2 logic
always@(posedge clock)
begin
if(!resetn)
begin
timer_2<=0;
soft_reset_2<=0;
end

else if(vld_out_2)
begin
if(!read_enb_2)
begin
if(timer_2==5'd29) // we will be cheching for 30th clock pulse 
begin
soft_reset_2<=1'b1;
timer_2<=0;
end
else
begin
soft_reset_2<=1'b0;
timer_2<=timer_2+1;
end
end
timer_2<=0;
end
timer_2<=0;
end

//addr logic 
always@(posedge clock)
begin
if(!resetn)
addr<=2'b0;
else if(detect_add)
addr<=data_in;
end


//write operation
always@(*)
begin
if(write_enb_reg)
begin
case(addr)
2'b00:write_enb=3'b001;
2'b01:write_enb=3'b010;
2'b10:write_enb=3'b100;
default:write_enb=3'b000;
endcase
end
else
write_enb=3'b000;
end

//fifo_full logic
always@(*)
begin
case(addr)
2'b00:fifo_full=full_0;
2'b01:fifo_full=full_1;
2'b10:fifo_full=full_2;
default:fifo_full=0;
endcase
end

//vld_out 
assign vld_out_0=~empty_0;
assign vld_out_1=~empty_1;
assign vld_out_2=~empty_2;

endmodule 
