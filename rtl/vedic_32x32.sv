module vedic_32x32 (
    input  logic [31:0] a,    
    input  logic [31:0] b,    
    output logic [63:0] p     
);
    logic [31:0] q0, q1, q2, q3;
    vedic_16x16 u_ll (
        .a (a[15:0]),
        .b (b[15:0]),
        .p (q0)
    );
    vedic_16x16 u_hl (
        .a (a[31:16]),
        .b (b[15:0]),
        .p (q1)
    );
    vedic_16x16 u_lh (
        .a (a[15:0]),
        .b (b[31:16]),
        .p (q2)
    );
    vedic_16x16 u_hh (
        .a (a[31:16]),
        .b (b[31:16]),
        .p (q3)
    );
    logic [63:0] term_a, term_b, term_c;
    assign term_a = {q3, q0};                  
    assign term_b = {16'b0, q1, 16'b0};       
    assign term_c = {16'b0, q2, 16'b0};       
    logic [63:0] csa_sum, csa_carry;
    assign csa_sum   = term_a ^ term_b ^ term_c;
    assign csa_carry = (term_a & term_b) | (term_b & term_c) | (term_a & term_c);
    logic [63:0] cpa_b;
    assign cpa_b = {csa_carry[62:0], 1'b0};
    logic [4:0] group_carry;
    assign group_carry[0] = 1'b0;
    csla_block #(.WIDTH(16)) u_cpa_g0 (
        .a    (csa_sum[15:0]),
        .b    (cpa_b[15:0]),
        .cin  (group_carry[0]),
        .sum  (p[15:0]),
        .cout (group_carry[1])
    );
    csla_block #(.WIDTH(16)) u_cpa_g1 (
        .a    (csa_sum[31:16]),
        .b    (cpa_b[31:16]),
        .cin  (group_carry[1]),
        .sum  (p[31:16]),
        .cout (group_carry[2])
    );
    csla_block #(.WIDTH(16)) u_cpa_g2 (
        .a    (csa_sum[47:32]),
        .b    (cpa_b[47:32]),
        .cin  (group_carry[2]),
        .sum  (p[47:32]),
        .cout (group_carry[3])
    );
    csla_block #(.WIDTH(16)) u_cpa_g3 (
        .a    (csa_sum[63:48]),
        .b    (cpa_b[63:48]),
        .cin  (group_carry[3]),
        .sum  (p[63:48]),
        .cout (group_carry[4])   
    );
endmodule : vedic_32x32
