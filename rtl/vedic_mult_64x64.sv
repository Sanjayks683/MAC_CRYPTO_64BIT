module vedic_mult_64x64 (
    input  logic [63:0]  a,    
    input  logic [63:0]  b,    
    output logic [127:0] p     
);
    logic [63:0] q0, q1, q2, q3;
    vedic_32x32 u_ll (
        .a (a[31:0]),
        .b (b[31:0]),
        .p (q0)
    );
    vedic_32x32 u_hl (
        .a (a[63:32]),
        .b (b[31:0]),
        .p (q1)
    );
    vedic_32x32 u_lh (
        .a (a[31:0]),
        .b (b[63:32]),
        .p (q2)
    );
    vedic_32x32 u_hh (
        .a (a[63:32]),
        .b (b[63:32]),
        .p (q3)
    );
    logic [127:0] term_a, term_b, term_c;
    assign term_a = {q3, q0};                    
    assign term_b = {32'b0, q1, 32'b0};         
    assign term_c = {32'b0, q2, 32'b0};         
    logic [127:0] csa_sum, csa_carry;
    assign csa_sum   = term_a ^ term_b ^ term_c;
    assign csa_carry = (term_a & term_b) | (term_b & term_c) | (term_a & term_c);
    logic         cpa_cout;       
    logic         cpa_overflow;   
    logic [8:0]   cpa_group_carries;   
    csla_128bit u_cpa (
        .a             (csa_sum),
        .b             ({csa_carry[126:0], 1'b0}),
        .cin           (1'b0),
        .sat_en        (1'b0),                 
        .sum           (p),
        .cout          (cpa_cout),
        .overflow      (cpa_overflow),
        .group_carries (cpa_group_carries)
    );
endmodule : vedic_mult_64x64
