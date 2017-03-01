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
	/* initial block : send stimulus to processor_if						*/
	/************************************************************************/

	// send data on bus to memory
	// use 'clk' signal from "main_bus_if.sv"
	// use rd/wr tasks from "processor_if.sv"
	
	initial begin

		repeat (4) @(posedge MasterBus.clk);
		ProcIf.Proc_wrReq(24'h012345);
		
		repeat (5) @(posedge MasterBus.clk);
		ProcIf.Proc_rdReq(24'hfedcba);
		@(posedge T.clk);

	end

endmodule: CPU