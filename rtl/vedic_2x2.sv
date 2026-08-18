module vedic_2x2 (
    input  logic [1:0] a,    
    input  logic [1:0] b,    
    output logic [3:0] p     
);
    logic pp0, pp1, pp2, pp3;
    assign pp0 = a[0] & b[0];   
    assign pp1 = a[1] & b[0];   
    assign pp2 = a[0] & b[1];   
    assign pp3 = a[1] & b[1];   
    logic ha1_carry;   
    assign p[0] = pp0;
    assign p[1]      = pp1 ^ pp2;
    assign ha1_carry  = pp1 & pp2;
    assign p[2] = pp3 ^ ha1_carry;
    assign p[3] = pp3 & ha1_carry;
endmodule : vedic_2x2
