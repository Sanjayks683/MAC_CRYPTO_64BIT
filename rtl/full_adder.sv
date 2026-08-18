module full_adder (
    input  logic a,      
    input  logic b,      
    input  logic cin,    
    output logic sum,    
    output logic cout    
);
    logic a_xor_b;   
    logic a_and_b;   
    logic cin_and_p; 
    assign a_xor_b = a ^ b;
    assign sum = a_xor_b ^ cin;
    assign a_and_b   = a & b;
    assign cin_and_p  = cin & a_xor_b;
    assign cout       = a_and_b | cin_and_p;
endmodule : full_adder
