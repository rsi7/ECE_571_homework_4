// Module: CPU.sv
// Author: Rehan Iqbal
// Date: March 3, 2017
// Company: Portland State University
//
// Description:
// ------------
// lorem ipsum
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

	module CPU (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

		main_bus_if.master		MasterBus,
		processor_if.SndRcv		ProcIf

	);

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	int				fhandle;

	ulogic4			page;
	ulogic16		address;

	ulogic64		write_data;
	ulogic32		write_data_1;
	ulogic32		write_data_2;
	ulogic64		read_data;

	/************************************************************************/
	/* initial block : send stimulus to processor_if						*/
	/************************************************************************/

	// send data on bus to memory
	// use 'clk' signal from "main_bus_if.sv"
	// use rd/wr tasks from "processor_if.sv"
	
	initial begin

		$timeformat(-9, 0, "ns", 8);
		fhandle = $fopen("C:/Users/riqbal/Desktop/hw4_results.txt");

		// print header at top of read log
		$fwrite(fhandle,"HW#4 Write & Read Results:\n\n");

		// simulation time
		// write, then read results

		repeat (4) @(posedge MasterBus.clk);

		page = 4'h2;
		address = 12'd32;

		for (int i = 0; i < 16; i ++) begin

			address = address + 8;

			write_data_1 = $urandom_range(32'hFFFFFFFF, 32'h0);
			write_data_2 = $urandom_range(32'hFFFFFFFF, 32'h0);
			write_data = {write_data_1, write_data_2};

			read_data = 64'h0;

			ProcIf.Proc_wrReq(page, address, write_data);
			ProcIf.Proc_rdReq(page, address, read_data);

			// write results to log file
			$fwrite(fhandle, 	"page = %4d\t\t", page,
								"address = %6d\t\t", address,
								"write_data = %16x\t\t", write_data,
								"read_data = %16x\n\n", read_data);
		end

		// wrap up file writing
		$fwrite(fhandle, "\nEND OF FILE");
		$fclose(fhandle);

		// simulation over... review results
		$stop;

	end

endmodule: CPU