// Data types for Cache Muxes
package cache_types;

// Write Enable Select
typedef enum logic [1:0] {
    ALL_DIS = 2'b00,
    ALL_EN  = 2'b01,
    CPU_EN  = 2'b10
} write_en_sel_t;

// Write Data Select
typedef enum logic {
    CPU_DATA = 1'b0,
    RAM_DATA = 1'b1
} write_data_sel_t;

// RAM Address Select
typedef enum logic {
    CPU_ADDR = 1'b0,
    TAG_ADDR = 1'b1
} ram_addr_sel_t;

endpackage