import rv32i_types::*;

module arbiter(
    input rv32i_word i_pmem_address,
    input logic i_pmem_read,
    output logic [255:0] i_pmem_rdata,
    output logic i_pmem_resp,
    input rv32i_word d_pmem_address,
    input logic d_pmem_read,
    input logic d_pmem_write,
    input logic [255:0] d_pmem_wdata,
    output logic [255:0] d_pmem_rdata,
    output logic d_pmem_resp, 
    input logic [255:0] pmem_rdata_c,
    input logic pmem_resp_c,
    output rv32i_word pmem_address_c,
    output logic pmem_read_c,
    output logic pmem_write_c,
    output logic [255:0] pmem_wdata_c
);

function void set_defaults();
    i_pmem_rdata = 256'b0;
    i_pmem_resp = 1'b0;
    d_pmem_rdata = 256'b0;
    d_pmem_resp = 1'b0;
    pmem_address_c = 32'b0;
    pmem_read_c = 1'b0;
    pmem_write_c = 1'b0;
    pmem_wdata_c = 256'b0;
endfunction

always_comb begin
    set_defaults();
    if (d_pmem_read) begin
        pmem_read_c = 1'b1;
        pmem_address_c = d_pmem_address;
        d_pmem_rdata = pmem_rdata_c;
        if (pmem_resp_c)
            d_pmem_resp = 1'b1;
    end
    else if (d_pmem_write) begin
        pmem_write_c = 1'b1;
        pmem_address_c = d_pmem_address;
        pmem_wdata_c = d_pmem_wdata;
        if (pmem_resp_c)
            d_pmem_resp = 1'b1;
    end
    else if (i_pmem_read) begin
        pmem_read_c = 1'b1;
        pmem_address_c = i_pmem_address;
        i_pmem_rdata = pmem_rdata_c;
        if (pmem_resp_c)
            i_pmem_resp = 1'b1;
    end
end

endmodule : arbiter