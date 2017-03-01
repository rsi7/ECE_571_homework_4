// Module: processor_if.sv
// Author: Rehan Iqbal
// Date: March 3, 2017
// Company: Portland State University
//
// Description:
// ------------
// This interface is responsible for initiating bus transactions (memory reads 
// and writes) from a CPU model (part of your testbench) across the main bus to
//  the memory interface.
//
// The processor interface provides a transaction-level interface to the CPU in
// the form of two tasks:
//
// -- Proc_rdReq --
// performs a 4 word memory read to “page” starting at “baseaddr”
// the data from memory is returned in the 64-bit packed array
// (four 16-bit words) “data”
//
// -- Proc_wrReq --
// performs a 4 word memory read to “page” starting at “baseaddr”
// the data from memory is returned in the 64-bit packed array
// (four 16-bit words) “data”
//
////////////////////////////////////////////////////////////////////////////////

`include "definitions.sv"

interface processor_if (main_bus_if.master M);

	modport SndRcv(import Proc_rdReq, import Proc_wrReq);

	/************************************************************************/
	/* Task : Proc_rdReq													*/
	/************************************************************************/

	task Proc_rdReq (

		input bit	[3:0]				page, 
		input bit 	[11:0] 				baseaddr, 
		output bit 	[DBUFWIDTH-1:0] 	data

		);

	endtask : Proc_rdReq

	/************************************************************************/
	/* Task : Proc_wrReq													*/
	/************************************************************************/

	task Proc_wrReq (

		input bit	[3:0]				page,
		input bit	[11:0] 				baseaddr,
		input bit	[DBUFWIDTH-1:0] 	data

		);

	endtask : Proc_wrReq


endinterface : processor_if