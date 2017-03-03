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
	/* Local parameters and variables										*/
	/************************************************************************/

	ulogic1			cycle_finish;

	ulogic1			type_FSM;
	ulogic1			valid_FSM;
	ulogic4			page_FSM;

	ulogic16		baseaddr_FSM;
	ulogic64		data_FSM;

	state_t			state = STATE_A;
	state_t			next = STATE_A;

	/************************************************************************/
	/* Task : Proc_rdReq													*/
	/************************************************************************/

	task Proc_rdReq (

		input bit	[3:0]				page, 
		input bit 	[11:0] 				baseaddr, 
		output bit 	[63:0] 				data

		);

		begin

			cycle_finish <= 0;

			page_FSM <= page;
			baseaddr_FSM <= baseaddr;

			valid_FSM <= 1'b1;
			type_FSM <= 1'b1;

			@(posedge M.clk) valid_FSM <= 1'b0;

			while(!cycle_finish)

			data <= data_FSM;

		end

	endtask : Proc_rdReq

	/************************************************************************/
	/* Task : Proc_wrReq													*/
	/************************************************************************/

	task Proc_wrReq (

		input bit	[3:0]				page,
		input bit	[11:0] 				baseaddr,
		input bit	[63:0] 				data

		);

		begin

			cycle_finish <= 0;

			page_FSM <= page;
			baseaddr_FSM <= baseaddr;
			data_FSM <= data;

			valid_FSM <= 1'b1;
			type_FSM <= 1'b0;

			@(posedge M.clk) valid_FSM <= 1'b0;

			while(!cycle_finish) begin
			end

		end

	endtask : Proc_wrReq

	/************************************************************************/
	/* Mealy FSM Block 1: reset & state advancement							*/
	/************************************************************************/

	always_ff@(posedge M.clk or posedge M.resetH) begin

		// reset the FSM to waiting state
		if (M.resetH) state <= STATE_A;

		// otherwise, advance the state
		else state <= next;

	end

	/************************************************************************/
	/* Mealy FSM Block 2: state transitions									*/
	/************************************************************************/

	always_comb begin

		unique case (state)

			// each state lasts exactly 1 cycle,
			// except STATE_A, which holds until valid_FSM

			STATE_A : next = (valid_FSM) ? STATE_B : STATE_A;
			STATE_B : next = STATE_C;
			STATE_C : next = STATE_D;
			STATE_D : next = STATE_E;
			STATE_E : next = STATE_A;

		endcase
	end

	/************************************************************************/
	/* Mealy FSM Block 3: assigning outputs									*/
	/************************************************************************/

	always_comb begin

		M.rw = 1'b0;
		M.AddrValid = 1'b0;
		M.AddrData = 'bz;

		cycle_finish = 1'b0;

		unique case (state)

			STATE_A : begin

				M.rw = type_FSM;
				M.AddrValid = valid_FSM;
				M.AddrData = (valid_FSM) ? baseaddr_FSM : 'bz;

			end

			STATE_B : begin

				if (type_FSM) data_FSM = M.AddrData[15:0];
				else M.AddrData = data_FSM[15:0];

			end

			STATE_C : begin

				if (type_FSM) data_FSM = M.AddrData[31:16];
				else M.AddrData = data_FSM[31:16];

			end

			STATE_D : begin

				if (type_FSM) data_FSM = M.AddrData[47:32];
				else M.AddrData = data_FSM[47:32];

			end

			STATE_E : begin

				if (type_FSM) data_FSM = M.AddrData[63:48];
				else M.AddrData = data_FSM[63:48];

				cycle_finish = 1'b1;

			end
		endcase
	end

endinterface : processor_if