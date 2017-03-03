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

module top();

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	ulogic1		clk;
	ulogic1		resetH;

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

	memory_if i_memory_if			(.S(i_main_bus_if.slave),
									.A(i_memArray_if.MemIF)
									);

	mem i_mem 						(.MBUS(i_main_bus_if.slave), 
									.MIF(i_memArray_if.MemIF));



	/************************************************************************/
	/* initial block : clk & resetH											*/
	/************************************************************************/

	initial begin
		resetH = 1'b0;
		resetH <= #1 1'b1;
		resetH <= #1 1'b0;
	end


	always #0.5 clk <= !clk;

endmodule