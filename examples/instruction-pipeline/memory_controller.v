module memory_controller(clk,
			 reset,
			 devices_mem_en,
			 device_1_mem_addr,
			 device_2_mem_addr,
			 device_3_mem_addr,
			 device_1_mem_di,
			 device_2_mem_di,
			 device_3_mem_di,
			 devices_mem_we,
			 devices_do_ack,
			 mem_do);

input 	clk;
input	reset;
input	[2:0] devices_mem_en;
input	[7:0] device_1_mem_addr;
input	[7:0] device_2_mem_addr;
input	[7:0] device_3_mem_addr;
input	[7:0] device_1_mem_di;
input	[7:0] device_2_mem_di;
input	[7:0] device_3_mem_di;
input	[2:0] devices_mem_we;
output	[2:0] devices_do_ack;
output	[7:0] mem_do;

parameter DEVICE_1 = 3'd0;
parameter DEVICE_2 = 3'd1;
parameter DEVICE_3 = 3'd2;
parameter NO_ONE = 3'b111;

reg	mem_enable = 0;
reg	[7:0] mem_addr = 7'd0;
reg	[7:0] mem_di = 7'd0;
reg	[2:0] current_slave = NO_ONE;
reg	mem_we = 0;
reg	[2:0] serving_slave = 2'd0;
reg	[2:0] devices_do_ack = 3'd0;

always @(posedge clk)
begin
	if (reset)
	begin
		current_slave <= NO_ONE;
	end
	else
	begin
		case (current_slave)
		NO_ONE:
		begin
			if (devices_mem_en[0])
                	begin
                	        current_slave <= DEVICE_1;
				mem_addr <= device_1_mem_addr;
				mem_di <= device_1_mem_di;
				mem_we <= devices_mem_we[0];
                	end
                	else if (devices_mem_en[1])
                	begin
                	        current_slave <= DEVICE_2;
				mem_addr <= device_2_mem_addr;
				mem_di <= device_2_mem_di;
				mem_we <= devices_mem_we[1];
                	end
                	else if (devices_mem_en[2])
                	begin
                	        current_slave <= DEVICE_3;
				mem_addr <= device_3_mem_addr;
				mem_di <= device_3_mem_di;
				mem_we <= devices_mem_we[2];
                	end
                	else
                	begin
                	        current_slave <= NO_ONE;
				mem_addr <= 7'd0;
				mem_di <= 7'd0;
				mem_we <= 0;
                	end
                	devices_do_ack <= 3'b000;
		end
	
		DEVICE_1:
	        begin
	                if (devices_mem_en[1])
	                begin
	                        current_slave <= DEVICE_2;
				mem_addr <= device_2_mem_addr;
				mem_di <= device_2_mem_di;
				mem_we <= devices_mem_we[1];
	                end
	                else if (devices_mem_en[2])
	                begin
	                        current_slave <= DEVICE_3;
				mem_addr <= device_3_mem_addr;
				mem_di <= device_3_mem_di;
				mem_we <= devices_mem_we[2];
	                end
                	else
                	begin
                	        current_slave <= NO_ONE;
				mem_addr <= 7'd0;
				mem_di <= 7'd0;
				mem_we <= 0;
                	end
			devices_do_ack <= 3'b001;
	        end

		DEVICE_2:
		begin
			if (devices_mem_en[2])
			begin
				current_slave <= DEVICE_3;
				mem_addr <= device_3_mem_addr;
				mem_di <= device_3_mem_di;
				mem_we <= devices_mem_we[2];
			end
			else if (devices_mem_en[0])
			begin
				current_slave <= DEVICE_1;
				mem_addr <= device_1_mem_addr;
				mem_di <= device_1_mem_di;
				mem_we <= devices_mem_we[0];
			end
                	else
                	begin
                	        current_slave <= NO_ONE;
				mem_addr <= 7'd0;
				mem_di <= 7'd0;
				mem_we <= 0;
                	end
			devices_do_ack <= 3'b010;
		end

		DEVICE_3:
		begin
			if (devices_mem_en[0])
			begin
				current_slave <= DEVICE_1;
				mem_addr <= device_1_mem_addr;
				mem_di <= device_1_mem_di;
				mem_we <= devices_mem_we[0];
			end
			else if (devices_mem_en[1])
			begin
				current_slave <= DEVICE_2;
				mem_addr <= device_2_mem_addr;
				mem_di <= device_2_mem_di;
				mem_we <= devices_mem_we[1];
			end
                	else
                	begin
                	        current_slave <= NO_ONE;
				mem_addr <= 7'd0;
				mem_di <= 7'd0;
				mem_we <= 0;
                	end
			devices_do_ack <= 3'b100;
		end
		endcase
	end
end

ram mem(clk, ~reset, mem_addr, mem_di, mem_do, mem_we);

endmodule
