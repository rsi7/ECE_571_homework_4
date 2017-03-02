//////////////////////////////////////////////////////////////
// main_bus_if.sv - Main Bus interface for memory controller
//
// Author:	Roy Kravitz 
// Date:	23-Feb-2017
//
// Description:
// ------------
// Defines the interface between the processor interface (a master) and
// the memory interface (a slave).  Bus is based on the processor/memory
// bus used in HW #3
// 
// Note:  Original concept by Don T. but the implementation is my own
//
//////////////////////////////////////////////////////////////////////

`include "definitions.sv"
	
interface main_bus_if (

	/************************************************************************/
	/* Top-level port declarations											*/
	/************************************************************************/

	input logic		clk,
	input logic		resetH

	);
	
	/************************************************************************/
	/* Bus signals															*/
	/************************************************************************/

	tri		[BUSWIDTH-1: 0]		AddrData;
	logic						AddrValid;
	logic						rw;
	
	/************************************************************************/
	/* Modport : master														*/
	/************************************************************************/

	modport master (

		input		clk,
		input		resetH,

		output		AddrValid,
		output		rw,

		inout		AddrData

	);

	/************************************************************************/
	/* Modport : slave														*/
	/************************************************************************/

	modport slave (

		input		clk,
		input		resetH,

		input		AddrValid,
		input		rw,
		
		inout		AddrData

	);
	
endinterface: main_bus_if