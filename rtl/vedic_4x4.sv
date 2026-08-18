module vedic_4x4 (
    input  logic [3:0] a,    
    input  logic [3:0] b,    
    output logic [7:0] p     
);
    logic [3:0] q0, q1, q2, q3;
    vedic_2x2 u_ll (
        .a (a[1:0]),
        .b (b[1:0]),
        .p (q0)
    );
    vedic_2x2 u_hl (
        .a (a[3:2]),
        .b (b[1:0]),
        .p (q1)
    );
    vedic_2x2 u_lh (
        .a (a[1:0]),
        .b (b[3:2]),
        .p (q2)
    );
    vedic_2x2 u_hh (
        .a (a[3:2]),
        .b (b[3:2]),
        .p (q3)
    );
    assign p[1:0] = q0[1:0];
    logic [3:0] cross_sum;
    logic        cross_carry;
    ripple_carry_adder #(.WIDTH(4)) u_cross_add (
        .a    (q1),
        .b    (q2),
        .cin  (1'b0),
        .sum  (cross_sum),
        .cout (cross_carry)
    );
    logic [1:0] mid_sum;
    logic        mid_carry;
    ripple_carry_adder #(.WIDTH(2)) u_mid_add (
        .a    (q0[3:2]),
        .b    (cross_sum[1:0]),
        .cin  (1'b0),
        .sum  (mid_sum),
        .cout (mid_carry)
    );
    assign p[3:2] = mid_sum;
    logic [3:0] upper_sum;
    logic        upper_carry;   
    ripple_carry_adder #(.WIDTH(4)) u_upper_add (
        .a    (q3),
        .b    ({1'b0, cross_carry, cross_sum[3:2]}),
        .cin  (mid_carry),
        .sum  (upper_sum),
        .cout (upper_carry)
    );
    assign p[7:4] = upper_sum;
endmodule : vedic_4x4
