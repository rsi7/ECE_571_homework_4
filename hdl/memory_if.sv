// Module: memory_if.sv
// Author: Rehan Iqbal
// Date: March 3, 2017
// Company: Portland State University
//
// Description:
// ------------
// This interface is responsible for handling bus transactions originating 
// in the processor_if interface. This interface (in my suggested implementation, 
// but feel free to innovate) directly drives the ports of the shared memory 
// through the MemArray interface in response to the protocol on the main bus. 
//
// When rw is asserted high the memory interface should initiate a read 
// operation to the memory and return the memory data on the AddrData
// bus. When rw is deasserted (low) the memory interface should initiate a 
// write operation to the memory starting at the address on AddrData 
// and writing four consecutive locations with thedata appearing 
// on the AddrData bus (one word per cycle) after the address. 
//
// The memory interface should accept a parameter to specify the page that 
// the memory controller should respond to. Accesses to pages other than 
// its page should be ignored.
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

interface memory_if #(parameter logic [3:0] PAGE = 4'h2) (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/
	
	main_bus_if.slave	S,		// interface to memory is a slave
	memArray_if.MemIF	A		// interface to memory array
	
	);

endinterface : memory_if