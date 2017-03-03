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
	ulogic64		memdata;
	ulogic16		address;

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

		page = 4'h2;
		address = 12'd32;

		repeat (4) @(posedge MasterBus.clk);
		ProcIf.Proc_wrReq(page, address, 63'd128);
		
		repeat (8) @(posedge MasterBus.clk);
		ProcIf.Proc_rdReq(page, address, memdata);
		
		@(posedge MasterBus.clk);

		// write results to log file
		$fwrite(fhandle, 	"page = %4d\t\t", page,
							"address = %6d\t\t", address,
							"memdata = %6d\n\n", memdata);

		// wrap up file writing
		$fwrite(fhandle, "\nEND OF FILE");
		$fclose(fhandle);

		// simulation over... review results
		$stop;

	end

endmodule: CPU