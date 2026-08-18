module vedic_8x8 (
    input  logic [7:0]  a,    
    input  logic [7:0]  b,    
    output logic [15:0] p     
);
    logic [7:0] q0, q1, q2, q3;
    vedic_4x4 u_ll (
        .a (a[3:0]),
        .b (b[3:0]),
        .p (q0)
    );
    vedic_4x4 u_hl (
        .a (a[7:4]),
        .b (b[3:0]),
        .p (q1)
    );
    vedic_4x4 u_lh (
        .a (a[3:0]),
        .b (b[7:4]),
        .p (q2)
    );
    vedic_4x4 u_hh (
        .a (a[7:4]),
        .b (b[7:4]),
        .p (q3)
    );
    logic [15:0] term_a, term_b, term_c;
    assign term_a = {q3, q0};
    assign term_b = {4'b0, q1, 4'b0};
    assign term_c = {4'b0, q2, 4'b0};
    logic [15:0] csa_sum, csa_carry;
    assign csa_sum   = term_a ^ term_b ^ term_c;
    assign csa_carry = (term_a & term_b) | (term_b & term_c) | (term_a & term_c);
    logic cpa_cout;   
    ripple_carry_adder #(.WIDTH(16)) u_cpa (
        .a    (csa_sum),
        .b    ({csa_carry[14:0], 1'b0}),
        .cin  (1'b0),
        .sum  (p),
        .cout (cpa_cout)
    );
endmodule : vedic_8x8
