module bec #(
    parameter int unsigned WIDTH = 8
) (
    input  logic [WIDTH-1:0] b,         
    output logic [WIDTH:0]   bec_out    
);
    logic [WIDTH-1:0] and_chain;
    assign and_chain[0] = b[0];
    genvar i;
    generate
        for (i = 1; i < WIDTH; i++) begin : gen_and_chain
            assign and_chain[i] = b[i] & and_chain[i-1];
        end
    endgenerate
    assign bec_out[0] = ~b[0];
    generate
        for (i = 1; i < WIDTH; i++) begin : gen_bec_bits
            assign bec_out[i] = b[i] ^ and_chain[i-1];
        end
    endgenerate
    assign bec_out[WIDTH] = and_chain[WIDTH-1];
endmodule : bec
