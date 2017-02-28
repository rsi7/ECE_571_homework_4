//////////////////////////////////////////////////////////////
// mcDefs.sv - Global definitions for memory controller assignment
// Author:	Roy Kravitz 
// Date:	01-Feb-2017
//
// Description:
// ------------
// Contains the global typedefs, const, enum, structs, etc. for the memory
// controller assignment 
////////////////////////////////////////////////////////////////
package mcDefs;

parameter	BUSWIDTH = 16;
parameter	DATAPAYLOADSIZE = 4;
parameter	MEMSIZE = 256;

// page number for the memory controllers
parameter [3:0] MEMPAGE1 = 4'h2;
parameter [3:0] MEMPAGE2 = 4'hF;

typedef struct packed {
	logic		[3:0]	page;
	logic		[11:0]	loc;
} memAddr_t;

typedef union packed {
	memAddr_t			PgLoc;
	logic		[15:0]	ma;	
} areg_t;

endpackage