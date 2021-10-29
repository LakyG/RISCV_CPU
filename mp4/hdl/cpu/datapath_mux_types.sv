package datapath_mux_types;
import rv32i_types::*;

typedef enum bit [1:0] {
    alumux_out     = 2'b00,
    mem_alu_out    = 2'b01
    wb_regfile_mux = 2'b10
} forwardingmux_t;

endpackage : datapath_mux_types