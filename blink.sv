// create module
	module blink (
	input wire clk, // 50MHz input clock
	output wire LED // LED ouput
	);

// create a binary counter
reg [31:0] cnt; // 32-bit counter

initial begin
cnt <= 32'h00000000; // start at zero

end

always @(posedge clk) begin
cnt <= cnt + 1; // count up

end

always @ (posedge clk)
begin
cnt <= cnt + 1;
end
assign clk_enable = count==3? 1: 0;
endmodule


//assign LED to 25th bit of the counter to blink the LED at a few Hz
assign LED = cnt[24];



endmodule 
