// Module: CPU.sv
// Author: Rehan Iqbal
// Date: March 3, 2017
// Company: Portland State University
//
// Description:
// ------------
// This is the top-level module for HW4. It instantiates all other modules
// and interfaces, sets the parameters for the memory interfaces, and starts
// the clock signal.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

module top();

	timeunit 1ns;
	timeprecision 100ps;
	
	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	ulogic1		clk = 1'b0;
	ulogic1		resetH = 1'b0;

	/************************************************************************/
	/* Module instantiations												*/
	/************************************************************************/

	main_bus_if i_main_bus_if		(.clk(clk), 
									.resetH(resetH));

	processor_if i_processor_if		(.M(i_main_bus_if.master));

	CPU i_CPU 						(.MasterBus(i_main_bus_if.master),
									.ProcIf(i_processor_if.SndRcv)
									);

	memArray_if i_memArray_if		();

	memory_if #(4'h2) i_memory_if	(.S(i_main_bus_if.slave),
									.A(i_memArray_if.MemIF)
									);

	memory_if #(4'h1) i2_memory_if	(.S(i_main_bus_if.slave),
									.A(i_memArray_if.MemIF)
									);

	mem i_mem 						(.MBUS(i_main_bus_if.slave), 
									.MIF(i_memArray_if.MemIF));



	/************************************************************************/
	/* always block : clk													*/
	/************************************************************************/

	always begin
		#0.5 clk <= !clk;
	end

endmodule