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

	ulogic1			cycle_finish = 1'b0;

	ulogic1			type_FSM = 1'b0;
	ulogic1			valid_FSM = 1'b0;

	ulogic16		baseaddr_FSM;
	ulogic64		data_FSM;

	ulogic16		M_AddrData_reg;

	state_t			state = STATE_A;
	state_t			next = STATE_A;

	/************************************************************************/
	/* Task : Proc_rdReq													*/
	/************************************************************************/

	task Proc_rdReq (

		input 	ulogic4		page, 
		input 	ulogic12 	baseaddr, 
		output	ulogic64	data

		);

		begin

			data_FSM <= 64'd0;

			cycle_finish <= 1'b0;

			baseaddr_FSM <= {page, baseaddr};

			valid_FSM <= 1'b1;
			type_FSM <= 1'b1;

			@(posedge M.clk) valid_FSM <= 1'b0;

			while(!cycle_finish) begin
				@(posedge M.clk);
			end

			data = data_FSM;

		end

	endtask : Proc_rdReq

	/************************************************************************/
	/* Task : Proc_wrReq													*/
	/************************************************************************/

	task Proc_wrReq (

		input	ulogic4		page,
		input	ulogic12	baseaddr,
		input	ulogic64 	data

		);

		begin

			cycle_finish <= 1'b0;

			baseaddr_FSM <= {page, baseaddr};
			data_FSM <= data;

			valid_FSM <= 1'b1;
			type_FSM <= 1'b0;

			@(posedge M.clk) valid_FSM <= 1'b0;

			while(!cycle_finish) begin
				@(posedge M.clk);
			end

		end

	endtask : Proc_wrReq

	/************************************************************************/
	/* Wire assignments														*/
	/************************************************************************/

	assign M.AddrData = M_AddrData_reg;

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

		case (state)

			// each state lasts exactly 1 cycle,
			// except STATE_A, which holds until valid_FSM

			STATE_A : next <= (valid_FSM) ? STATE_B : STATE_A;
			STATE_B : next <= STATE_C;
			STATE_C : next <= STATE_D;
			STATE_D : next <= STATE_E;
			STATE_E : next <= STATE_A;

		endcase
	end

	/************************************************************************/
	/* Mealy FSM Block 3: assigning outputs									*/
	/************************************************************************/

	always_comb begin

		M.rw = 1'b0;
		M.AddrValid = 1'b0;
		M_AddrData_reg = 'bz;

		cycle_finish = 1'b0;

		case (state)

			STATE_A : begin

				M.rw = type_FSM;
				M.AddrValid = valid_FSM;
				M_AddrData_reg = (valid_FSM) ? baseaddr_FSM : 'bz;

			end

			STATE_B : begin

				if (type_FSM) data_FSM[15:0] = M.AddrData;
				else M_AddrData_reg = data_FSM[15:0];

			end

			STATE_C : begin

				if (type_FSM) data_FSM[31:16] = M.AddrData;
				else M_AddrData_reg = data_FSM[31:16];

			end

			STATE_D : begin

				if (type_FSM) data_FSM[47:32] = M.AddrData;
				else M_AddrData_reg = data_FSM[47:32];

			end

			STATE_E : begin

				if (type_FSM) data_FSM[63:48] = M.AddrData;
				else M_AddrData_reg = data_FSM[63:48];

				cycle_finish = 1'b1;

			end

		endcase
	end

endinterface : processor_if