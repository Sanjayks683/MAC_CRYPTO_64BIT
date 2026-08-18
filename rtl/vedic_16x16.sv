module vedic_16x16 (
    input  logic [15:0] a,    
    input  logic [15:0] b,    
    output logic [31:0] p     
);
    logic [15:0] q0, q1, q2, q3;
    vedic_8x8 u_ll (
        .a (a[7:0]),
        .b (b[7:0]),
        .p (q0)
    );
    vedic_8x8 u_hl (
        .a (a[15:8]),
        .b (b[7:0]),
        .p (q1)
    );
    vedic_8x8 u_lh (
        .a (a[7:0]),
        .b (b[15:8]),
        .p (q2)
    );
    vedic_8x8 u_hh (
        .a (a[15:8]),
        .b (b[15:8]),
        .p (q3)
    );
    logic [31:0] term_a, term_b, term_c;
    assign term_a = {q3, q0};                
    assign term_b = {8'b0, q1, 8'b0};       
    assign term_c = {8'b0, q2, 8'b0};       
    logic [31:0] csa_sum, csa_carry;
    assign csa_sum   = term_a ^ term_b ^ term_c;
    assign csa_carry = (term_a & term_b) | (term_b & term_c) | (term_a & term_c);
    logic cpa_cout;   
    ripple_carry_adder #(.WIDTH(32)) u_cpa (
        .a    (csa_sum),
        .b    ({csa_carry[30:0], 1'b0}),
        .cin  (1'b0),
        .sum  (p),
        .cout (cpa_cout)
    );
endmodule : vedic_16x16
