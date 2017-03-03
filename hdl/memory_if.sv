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
// When rw is asserted high the memory interface should initiate S read 
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
	
	main_bus_if.slave	S,		// interface to memory is S slave
	memArray_if.MemIF	A		// interface to memory array
	
	);

	/************************************************************************/
	/* Local parameters and variables										*/
	/************************************************************************/

	ulogic1			type_FSM;
	ulogic1			valid_FSM;

	ulogic16		AddrReg;
	ulogic16		baseaddr_FSM;

	state_t			state;
	state_t			next;

	/************************************************************************/
	/* Mealy FSM Block 1: reset & state advancement							*/
	/************************************************************************/

	always_ff@(posedge S.clk or posedge S.resetH) begin

		// reset the FSM to waiting state
		if (S.resetH) state <= STATE_A;

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

		A.Addr = 'z;
		A.DataIn = 'z;
		A.rdEn = 1'b0;
		A.wrEn = 1'b0;

		S.AddrData = 'z;

		unique case (state)

			STATE_A : begin

				type_FSM = S.rw;
				baseaddr_FSM = S.AddrData;

				A.Addr = (S.AddrValid) ? S.AddrData : 'z;

			end

			STATE_B, STATE_C, STATE_D, STATE_E : begin

				A.Addr = AddrReg;
				A.rdEn = (type_FSM);
				A.wrEn = (!type_FSM);

				if (type_FSM) S.AddrData = A.DataOut;
				else A.DataIn = S.AddrData;

			end

		endcase
	end

	/************************************************************************/
	/* Mealy FSM Block 4: handling AddrReg									*/
	/************************************************************************/

	always_ff@(posedge S.clk or posedge S.resetH) begin

		unique case (state)

			STATE_A, STATE_B : AddrReg = baseaddr_FSM;

			STATE_C, STATE_D, STATE_E : AddrReg <= AddrReg + 1;

		endcase
	end

endinterface : memory_if