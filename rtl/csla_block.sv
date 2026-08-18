module csla_block #(
    parameter int unsigned WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,      
    input  logic [WIDTH-1:0] b,      
    input  logic             cin,    
    output logic [WIDTH-1:0] sum,    
    output logic             cout    
);
    logic [WIDTH-1:0] sum_0;     
    logic             cout_0;    
    ripple_carry_adder #(
        .WIDTH (WIDTH)
    ) u_rca (
        .a    (a),
        .b    (b),
        .cin  (1'b0),
        .sum  (sum_0),
        .cout (cout_0)
    );
    logic [WIDTH:0] rca_concat;
    assign rca_concat = {cout_0, sum_0};
    logic [WIDTH+1:0] bec_result;
    bec #(
        .WIDTH (WIDTH + 1)
    ) u_bec (
        .b       (rca_concat),
        .bec_out (bec_result)
    );
    assign {cout, sum} = cin ? bec_result[WIDTH:0] : {cout_0, sum_0};
endmodule : csla_block
