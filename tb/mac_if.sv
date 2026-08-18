interface mac_if (
    input logic clk,
    input logic rst_n
);
    import mac_pkg::*;
    logic [MAC_OPERAND_WIDTH-1:0] operand_a;
    logic [MAC_OPERAND_WIDTH-1:0] operand_b;
    logic                         mac_en;
    logic                         clear_acc;
    logic [1:0]                   mode;
    logic                         stall;
    logic                         flush;
    logic [MAC_ACC_WIDTH-1:0]     modulus;
    logic [MAC_RESULT_WIDTH-1:0]  result;
    logic                         overflow;
    logic                         saturated;
    logic                         valid;
endinterface : mac_if
