module csla_128bit
    import mac_pkg::*;
(
    input  logic [127:0] a,          
    input  logic [127:0] b,          
    input  logic         cin,        
    input  logic         sat_en,     
    output logic [127:0] sum,        
    output logic         cout,       
    output logic         overflow,   
    output logic [CSLA_NUM_GROUPS:0] group_carries
);
    localparam int unsigned NG = CSLA_NUM_GROUPS;     
    localparam int unsigned GW [NG] = CSLA_GROUP_WIDTHS;   
    localparam int unsigned GO [NG] = CSLA_GROUP_OFFSETS;   
    logic [127:0] sum_internal;    
    assign group_carries[0] = cin;
    csla_block #(.WIDTH(GW[0])) u_group_0 (
        .a    (a[GO[0] +: GW[0]]),
        .b    (b[GO[0] +: GW[0]]),
        .cin  (group_carries[0]),
        .sum  (sum_internal[GO[0] +: GW[0]]),
        .cout (group_carries[1])
    );
    csla_block #(.WIDTH(GW[1])) u_group_1 (
        .a    (a[GO[1] +: GW[1]]),
        .b    (b[GO[1] +: GW[1]]),
        .cin  (group_carries[1]),
        .sum  (sum_internal[GO[1] +: GW[1]]),
        .cout (group_carries[2])
    );
    csla_block #(.WIDTH(GW[2])) u_group_2 (
        .a    (a[GO[2] +: GW[2]]),
        .b    (b[GO[2] +: GW[2]]),
        .cin  (group_carries[2]),
        .sum  (sum_internal[GO[2] +: GW[2]]),
        .cout (group_carries[3])
    );
    csla_block #(.WIDTH(GW[3])) u_group_3 (
        .a    (a[GO[3] +: GW[3]]),
        .b    (b[GO[3] +: GW[3]]),
        .cin  (group_carries[3]),
        .sum  (sum_internal[GO[3] +: GW[3]]),
        .cout (group_carries[4])
    );
    csla_block #(.WIDTH(GW[4])) u_group_4 (
        .a    (a[GO[4] +: GW[4]]),
        .b    (b[GO[4] +: GW[4]]),
        .cin  (group_carries[4]),
        .sum  (sum_internal[GO[4] +: GW[4]]),
        .cout (group_carries[5])
    );
    csla_block #(.WIDTH(GW[5])) u_group_5 (
        .a    (a[GO[5] +: GW[5]]),
        .b    (b[GO[5] +: GW[5]]),
        .cin  (group_carries[5]),
        .sum  (sum_internal[GO[5] +: GW[5]]),
        .cout (group_carries[6])
    );
    csla_block #(.WIDTH(GW[6])) u_group_6 (
        .a    (a[GO[6] +: GW[6]]),
        .b    (b[GO[6] +: GW[6]]),
        .cin  (group_carries[6]),
        .sum  (sum_internal[GO[6] +: GW[6]]),
        .cout (group_carries[7])
    );
    csla_block #(.WIDTH(GW[7])) u_group_7 (
        .a    (a[GO[7] +: GW[7]]),
        .b    (b[GO[7] +: GW[7]]),
        .cin  (group_carries[7]),
        .sum  (sum_internal[GO[7] +: GW[7]]),
        .cout (group_carries[8])
    );
    assign overflow = group_carries[NG];
    assign cout     = group_carries[NG];
    assign sum = (sat_en && overflow) ? ACC_SAT_VAL : sum_internal;
endmodule : csla_128bit
