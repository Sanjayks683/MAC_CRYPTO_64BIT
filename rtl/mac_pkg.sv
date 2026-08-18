package mac_pkg;
  parameter int unsigned MAC_OPERAND_WIDTH  = 64;
  parameter int unsigned MAC_PRODUCT_WIDTH  = 128;  
  parameter int unsigned MAC_ACC_WIDTH      = 128;
  parameter int unsigned MAC_RESULT_WIDTH   = 128;
  parameter int unsigned MAC_PIPE_STAGES    = 5;
  parameter int unsigned STAGE_INPUT        = 0;   
  parameter int unsigned STAGE_PARTIAL_PROD = 1;   
  parameter int unsigned STAGE_PROD_ASSEM   = 2;   
  parameter int unsigned STAGE_ACCUMULATE   = 3;   
  parameter int unsigned STAGE_OUTPUT       = 4;   
  parameter int unsigned CSLA_NUM_GROUPS = 8;
  parameter int unsigned CSLA_GROUP_WIDTHS [CSLA_NUM_GROUPS] = '{8, 12, 14, 16, 18, 20, 20, 20};
  parameter int unsigned CSLA_GROUP_OFFSETS [CSLA_NUM_GROUPS] = '{0, 8, 20, 34, 50, 68, 88, 108};
  typedef enum logic [1:0] {
    MODE_MULT_ONLY = 2'b00,  
    MODE_MAC       = 2'b01,  
    MODE_MAC_SAT   = 2'b10,  
    MODE_MAC_MOD   = 2'b11   
  } mac_mode_t;
  typedef struct packed {
    logic overflow;    
    logic saturated;   
    logic valid;       
  } mac_status_t;
  typedef struct packed {
    logic [MAC_OPERAND_WIDTH-1:0] operand_a;
    logic [MAC_OPERAND_WIDTH-1:0] operand_b;
    mac_mode_t                    mode;
    logic                         mac_en;
    logic                         clear_acc;
    logic                         valid;
  } pipe_stage_ctrl_t;
  parameter logic [MAC_ACC_WIDTH-1:0] ACC_ZERO = {MAC_ACC_WIDTH{1'b0}};
  parameter logic [MAC_ACC_WIDTH-1:0] ACC_MAX  = {MAC_ACC_WIDTH{1'b1}};
  parameter logic [MAC_ACC_WIDTH-1:0] ACC_SAT_VAL = {MAC_ACC_WIDTH{1'b1}};
  parameter int unsigned VEDIC_LEAF_WIDTH = 2;   
  parameter int unsigned VEDIC_4_WIDTH    = 4;
  parameter int unsigned VEDIC_8_WIDTH    = 8;
  parameter int unsigned VEDIC_16_WIDTH   = 16;
  parameter int unsigned VEDIC_32_WIDTH   = 32;
  parameter int unsigned VEDIC_64_WIDTH   = 64;
  parameter logic [MAC_ACC_WIDTH-1:0] DEFAULT_MODULUS = {MAC_ACC_WIDTH{1'b1}};
endpackage : mac_pkg
