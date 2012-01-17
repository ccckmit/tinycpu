module instruction_fetch(
	input clk,
	input reset,
	output DOR,
	input DIR,
	input ack_from_next,
	output ack_prev,
	input [31:0] data_in,
	output [31:0] data_out, 

	output cache_en, 
	output [15:0] cache_addr, 
	input [31:0] cache_do, 
	input cache_do_ack
);

parameter IDLE = 2'd0;
parameter WAITING_ACK_FROM_I_CACHE = 2'd1;
parameter WAITING_ACK_FROM_NEXT_STAGE = 2'd2;

reg [1:0] state = IDLE;
reg [31:0] data_out_reg = 32'd0;
reg DOR_reg = 0;
reg ack_prev_reg = 0;
reg [31:0] data_in_buffer;
reg [15:0] cache_addr_reg = 16'd0;
reg cache_en_reg = 0;
reg [31:0] data_in_cached = 32'd0;


assign data_out = data_out_reg;
assign DOR = DOR_reg;
assign ack_prev = ack_prev_reg;
assign cache_addr = cache_addr_reg;
assign cache_en = cache_en_reg;

always @(posedge clk)
begin
	if (reset)
	begin
		state <= IDLE;
		data_out_reg <= 0;
		DOR_reg <= 0;
		ack_prev_reg <= 0;
		cache_addr_reg <= 16'd0;
		cache_en_reg <= 0;
		data_in_cached <= 32'd0;
	end
	else
	begin
		case (state)

		IDLE:
		begin
			if (DIR)
			begin
				$display("Fetching opcode @ PC = %02X", data_in);
				state <= WAITING_ACK_FROM_I_CACHE;
				ack_prev_reg <= 1;
				cache_en_reg <= 1;
				DOR_reg <= 0;
				data_in_cached <= data_in;
				cache_addr_reg <= { 2'd0, data_in[9:2] };
			end
			else
			begin
				cache_en_reg <= 0;
				DOR_reg <= 0;
				cache_addr_reg <= data_in;
			end
		end

		WAITING_ACK_FROM_I_CACHE:
		begin
			if (cache_do_ack)
			begin
				$display("instruction fetcher fetched 0x%02X from PC = 0x%02X", cache_do, data_in_cached);
				data_out_reg <= cache_do;
				DOR_reg <= 1;
				cache_en_reg <= 0;
				state <= WAITING_ACK_FROM_NEXT_STAGE;
			end
			else
			begin
				state <= WAITING_ACK_FROM_I_CACHE;
				DOR_reg <= 0;
				cache_en_reg <= 1;
			end
			ack_prev_reg <= 0;
		end

		WAITING_ACK_FROM_NEXT_STAGE:
		begin
			if (ack_from_next)
			begin
				$display("instruction_fetcher got ACK from next stage");
				DOR_reg <= 0;
				cache_en_reg <= 0;
				state <= IDLE;
			end
			else
			begin
				DOR_reg <= 1;
				cache_en_reg <= 0;
				state <= WAITING_ACK_FROM_NEXT_STAGE;
			end
		end

		endcase
	end
end

endmodule
