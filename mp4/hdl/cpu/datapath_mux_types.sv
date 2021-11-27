package datapath_mux_types;
import rv32i_types::*;

typedef enum bit [1:0] {
    alumux_out     = 2'b00,
    mem_alu_out    = 2'b01,
    wb_regfile_mux = 2'b10
} forwardingmux_t;

typedef enum bit {
    nottaken  = 1'b0,
    taken     = 1'b1
} predictmux_t;

typedef enum bit {
    predicted  = 1'b0,
    expected   = 1'b1
} nextpcmux_t;

endpackage : datapath_mux_types