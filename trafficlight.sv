module light_sys
(mode,
 complement,
 click, 
 clk,
 rst);
 
parameter HG_FR=2'b11, HY_FR = 2'b10, HR_FG=2'b01,HR_FY=2'b00; //states of the FSM 
clk, // 50,000,000hz clock
rst;

output reg [2:0] mode, complement; //output of traffic lights

reg [27:0] cnt=0, cnt_d=0;

reg delay_long=0, delayshort_st=0, delayshort_en=0, Rcnt_en=0, Ycnt_en=0, Ycnt_enc=0;

wire clk_enable;
reg [1:0] state, next_state;

// next state
always @ (posedge clk or negedge rst)
begin
if(~rst)
state <= 2'b11;
else
state <= next_state;
end

// Finite state
always @ (*)
begin
case(state)

HG_FR: begin //staring with initial, epected state
Rcnt_en=1;
Ycnt_en=1;
Ycnt_enc=1;
state = 3'b110;
complement = 3'b011;

if(click) next_state = HY_FR;//referencing to forced button click
else next_state =HG_FR;
end

HY_FR: begin
state = 3'b101;
complement = 3'b001;
Rcnt_en=1;
Ycnt_en=0;
Ycnt_enc=1;

if(delay_long) next_state = HR_FG;
else next_state = HY_FR;
end
HR_FG: begin
state = 3'b011;
complement = 3'b100;
Rcnt_en=0;
Ycnt_en=1;
Ycnt_enc=1;
if(delay_short_en) next_state = HR_FY;
else next_state =HR_FG;
end

HR_FY:begin
state = 3'b001;
complement = 3'b101;
Rcnt_en=1;
Ycnt_en=0;
Ycnt_enc=0;
if(delayshort_en) next_state = HG_FR;
else next_state =HR_FY;
end

default: next_state = HG_FR;
endcase
end

//clocks

always @ (posedge clk)
begin
cnt <= cnt + 1;
end
assign clk_enable = count==3? 1: 0; // 50,000,000 for 50MHz running on FPGA
endmodule

always @ (posedge clk)

begin
if(clk_enable==1) begin
if (Rcnt_en||Ycnt_en||Ycnt_enc)
cnt_delay <= cnt_delay + 1;
if ((cnt_delay == 9) && Rcnt_en)
begin
delay_long=1;
delayshort_st=0;
delayshort_en=0;
cnt_delay<=0;
end
else if ((cnt_delay == 2) && Ycnt_en)
begin
delay_long=0;
delayshort_st=1;
delayshort_en=0;
cnt_delay<=0;
end
else if ((cnt_delay == 2) && Ycnt_enc)
begin
delay_long=0;
delayshort_st=0;
delayshort_en=1;
cnt_delay<=0;
end
else
begin
delay_long=0;
delayshort_st=0;
delayshort_en=0;
end
end
end


