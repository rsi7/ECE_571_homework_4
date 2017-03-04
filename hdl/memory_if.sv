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

	ulogic1			type_FSM = 1'b0;
	ulogic1			page_valid = 1'b0;

	ulogic12		AddrReg;
	ulogic16		baseaddr_FSM = 16'd0;

	ulogic12		A_Addr_reg;
	ulogic16		A_DataIn_reg;
	ulogic1			A_rdEn_reg;
	ulogic1			A_wrEn_reg;
	ulogic16		S_AddrData_reg;

	state_t			state = STATE_A;
	state_t			next = STATE_A;

	/************************************************************************/
	/* Wire assignments														*/
	/************************************************************************/

	assign A.Addr 		= (page_valid) ? A_Addr_reg : 'z;
	assign A.DataIn 	= (page_valid) ? A_DataIn_reg : 'z;
	assign A.rdEn 		= (page_valid) ? A_rdEn_reg : 'z;
	assign A.wrEn 		= (page_valid) ? A_wrEn_reg : 'z;
	assign S.AddrData 	= S_AddrData_reg;


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

		case (state)

			// each state lasts exactly 1 cycle,
			// except STATE_A, which holds until valid_FSM

			STATE_A : next = (S.AddrValid) ? STATE_B : STATE_A;
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

		A_Addr_reg = 'z;
		A_DataIn_reg = 'z;
		A_rdEn_reg = 1'b0;
		A_wrEn_reg = 1'b0;

		S_AddrData_reg = 'z;

		case (state)

			STATE_A : begin

				type_FSM = S.rw;
				baseaddr_FSM = S.AddrData;
				page_valid = (baseaddr_FSM[15:12] == PAGE);

				A_Addr_reg = (S.AddrValid) ? S.AddrData[11:0] : 'z;

			end

			STATE_B, STATE_C, STATE_D, STATE_E : begin

				A_Addr_reg = AddrReg;
				A_rdEn_reg = (type_FSM);
				A_wrEn_reg = (!type_FSM);

				if (type_FSM) S_AddrData_reg = (page_valid) ? A.DataOut : 'z;
				else A_DataIn_reg = S.AddrData;

			end

		endcase
	end

	/************************************************************************/
	/* Mealy FSM Block 4: handling AddrReg									*/
	/************************************************************************/

	always_ff@(posedge S.clk or posedge S.resetH) begin

		case (state)

			STATE_A: AddrReg <= baseaddr_FSM[11:0];

			STATE_B, STATE_C, STATE_D, STATE_E : AddrReg <= AddrReg + 1;

		endcase
	end

endinterface : memory_if