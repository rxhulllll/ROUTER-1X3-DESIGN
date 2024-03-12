module router_fifo(clock,resetn,
write_enb,soft_reset,read_enb,data_in,
lfd_state,empty,data_out,full);

//input signals
input clock;
input resetn;
input write_enb;
input soft_reset;
input read_enb;
input [7:0]data_in;
input lfd_state;

//output signals
output empty;
output reg [7:0]data_out;
output full;

//memory declaration 
reg [8:0]mem[15:0];
reg lfd_state_s;

//variable declaration
integer i;
reg[4:0] wr_pt=4'd0;
reg[4:0] rd_pt=4'd0;
reg[4:0] fifo_counter;


//write operation
always@(posedge clock)
begin
if(!resetn)
begin
for(i=0;i<16;i=i+1)
begin
mem[i]<=8'b0;
end 
end

else if(soft_reset)
begin
for(i=0;i<16;i=i+1)
begin
mem[i]<=8'b0;
end
end

else 
begin
if(write_enb && !full)
{mem[wr_pt[3:0]]}<={lfd_state_s,data_in};
end
end

//pointer incrementing

always@(posedge clock)
begin
if(!resetn)
begin
wr_pt<=5'b0;
rd_pt<=5'b0;
end

else if(soft_reset)
begin
wr_pt<=5'b0;
rd_pt<=5'b0;
end

else if(write_enb && !full)
begin
wr_pt<=wr_pt+1;
end

else if(read_enb && !empty)
begin
rd_pt<=rd_pt+1;
end

else  
begin
wr_pt<=wr_pt;
rd_pt<=rd_pt;
end
end

//full and empty conditions
assign full = (wr_pt=={~rd_pt[4],rd_pt[3:0]})?1'b1:1'b0;  //10000==10000
assign empty = (wr_pt==rd_pt)?1'b1:1'b0;


//READ OPERATIONS

always@(posedge clock)
begin
if(!resetn)
begin
data_out<=8'b0;
end
else if(soft_reset)
begin
data_out<=8'bz;
end

else
begin
if(fifo_counter==0 && data_out!=0)
data_out<=8'bz;
else if(read_enb && ~empty)
begin
data_out<=mem[rd_pt[3:0]];
end
end
end

//counter logic
always@(posedge clock)
begin
if(!resetn)
begin
fifo_counter<=0;
end
else if(soft_reset)
begin
fifo_counter<=0;
end
else if(read_enb && ~empty)
begin
if(mem[rd_pt[3:0]][8] == 1'b1)
fifo_counter <= mem[rd_pt[3:0]][7:2]+1'b1;
else if(fifo_counter != 0)
fifo_counter<=fifo_counter-1;
end
end

//lfd_state
always@(posedge clock)
begin
if(!resetn)
lfd_state_s<=0;
else
lfd_state_s<=lfd_state;
end


endmodule 
