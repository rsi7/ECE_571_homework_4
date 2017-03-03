// Module: definitions.pkg
// Author: Rehan Iqbal
// Date: February 10, 2017
// Company: Portland State University
//
// Description:
// ------------
// Package definitions file for the memController module & testbench. Contains
// type definitions for unsigned vars and parameters for FSM states.
//
// Include in target modules through syntax: `include "definitions.pkg"
// Make sure library paths include this file!
// 
//////////////////////////////////////////////////////////////////////////////
	
// check if file has been imported already
`ifndef IMPORT_DEFS

	// make sure other modules dont' re-import
	`define IMPORT_DEFS

	package definitions;

		// type definitions for unsigned 4-state variables
		typedef	logic		unsigned			ulogic1;
		typedef	logic		unsigned	[1:0]	ulogic2;
		typedef	logic		unsigned	[3:0]	ulogic4;
		typedef	logic		unsigned	[7:0]	ulogic8;
		typedef logic		unsigned	[11:0]	ulogic12;
		typedef	logic		unsigned	[15:0]	ulogic16;
		typedef	logic		unsigned	[31:0]	ulogic32;
		typedef	logic		unsigned	[63:0]	ulogic64;

		// type definitions for unsigned 2-state variables
		typedef bit			unsigned			uint1;
		typedef	bit			unsigned	[1:0]	uint2;
		typedef	bit			unsigned	[3:0]	uint4;
		typedef	byte		unsigned			uint8;
		typedef	shortint	unsigned			uint16;
		typedef	int			unsigned			uint32;
		typedef	longint		unsigned			uint64;

		// typedef for state
		typedef enum logic unsigned [2:0] {	

			STATE_A = 3'd0, 
			STATE_B = 3'd1, 
			STATE_C = 3'd2, 
			STATE_D = 3'd3, 
			STATE_E = 3'd4,
			STATE_X = 3'bxxx

			} state_t;

		///////////////////////////////////////
		// import from mcDefs.sv file		 //
		// included in HW #4 release package //
		///////////////////////////////////////

		parameter	BUSWIDTH = 16;
		parameter	DATAPAYLOADSIZE = 4;
		parameter	MEMSIZE = 256;

		// page number for the memory controllers
		parameter [3:0] MEMPAGE1 = 4'h2;
		parameter [3:0] MEMPAGE2 = 4'hF;

		// structure for holding split address 
		// 16'b address = 4'b page + 12'b location
		typedef struct packed {
			ulogic4		page;
			ulogic12	loc;
		} memAddr_t;

		// structure for holding full memory address
		typedef union packed {
			memAddr_t	PgLoc;
			ulogic16	ma;	
		} areg_t;

	endpackage

	// include the above definitions in the modules
	import definitions::*;

`endif