module mac_top_64bit
    import mac_pkg::*;
(
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic [MAC_OPERAND_WIDTH-1:0]  operand_a,   
    input  logic [MAC_OPERAND_WIDTH-1:0]  operand_b,   
    input  logic                          mac_en,      
    input  logic                          clear_acc,   
    input  logic [1:0]                    mode,        
    input  logic                          stall,       
    input  logic                          flush,       
    input  logic [MAC_ACC_WIDTH-1:0]      modulus,     
    output logic [MAC_RESULT_WIDTH-1:0]   result,      
    output logic                          overflow,    
    output logic                          saturated,   
    output logic                          valid        
);
    logic [MAC_PIPE_STAGES-1:0] stage_valid;
    logic                       pipe_stall, pipe_flush, pipe_enable;
    logic                       output_valid;
    pipeline_ctrl u_pipe_ctrl (
        .clk          (clk),
        .rst_n        (rst_n),
        .mac_en       (mac_en),
        .stall        (stall),
        .flush        (flush),
        .stage_valid  (stage_valid),
        .pipe_stall   (pipe_stall),
        .pipe_flush   (pipe_flush),
        .pipe_enable  (pipe_enable),
        .output_valid (output_valid)
    );
    logic [MAC_OPERAND_WIDTH-1:0] a_s1, b_s1;
    mac_mode_t                    mode_s1;
    logic                         clear_acc_s1;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_s1         <= '0;
            b_s1         <= '0;
            mode_s1      <= MODE_MULT_ONLY;
            clear_acc_s1 <= 1'b0;
        end else if (pipe_flush) begin
            clear_acc_s1 <= 1'b0;
        end else if (!pipe_stall) begin
            a_s1         <= operand_a;
            b_s1         <= operand_b;
            mode_s1      <= mac_mode_t'(mode);
            clear_acc_s1 <= clear_acc;
        end
    end
    logic [63:0] q0, q1, q2, q3;
    vedic_32x32 u_mult_ll (
        .a (a_s1[31:0]),
        .b (b_s1[31:0]),
        .p (q0)              
    );
    vedic_32x32 u_mult_hl (
        .a (a_s1[63:32]),
        .b (b_s1[31:0]),
        .p (q1)              
    );
    vedic_32x32 u_mult_lh (
        .a (a_s1[31:0]),
        .b (b_s1[63:32]),
        .p (q2)              
    );
    vedic_32x32 u_mult_hh (
        .a (a_s1[63:32]),
        .b (b_s1[63:32]),
        .p (q3)              
    );
    logic [127:0] term_a, term_b, term_c;
    logic [127:0] csa_sum_comb, csa_carry_comb;
    assign term_a = {q3, q0};
    assign term_b = {32'b0, q1, 32'b0};
    assign term_c = {32'b0, q2, 32'b0};
    assign csa_sum_comb   = term_a ^ term_b ^ term_c;
    assign csa_carry_comb = (term_a & term_b) | (term_b & term_c) | (term_a & term_c);
    logic [127:0] csa_sum_s2, csa_carry_s2;
    mac_mode_t    mode_s2;
    logic         clear_acc_s2;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            csa_sum_s2   <= '0;
            csa_carry_s2 <= '0;
            mode_s2      <= MODE_MULT_ONLY;
            clear_acc_s2 <= 1'b0;
        end else if (pipe_flush) begin
            clear_acc_s2 <= 1'b0;
        end else if (!pipe_stall) begin
            csa_sum_s2   <= csa_sum_comb;
            csa_carry_s2 <= csa_carry_comb;
            mode_s2      <= mode_s1;
            clear_acc_s2 <= clear_acc_s1;
        end
    end
    logic [127:0] product_comb;
    logic         prod_cout, prod_overflow;
    logic [CSLA_NUM_GROUPS:0] prod_group_carries;
    csla_128bit u_product_cpa (
        .a             (csa_sum_s2),
        .b             ({csa_carry_s2[126:0], 1'b0}),
        .cin           (1'b0),
        .sat_en        (1'b0),            
        .sum           (product_comb),
        .cout          (prod_cout),       
        .overflow      (prod_overflow),
        .group_carries (prod_group_carries)
    );
    logic [127:0] product_s3;
    mac_mode_t    mode_s3;
    logic         clear_acc_s3;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product_s3   <= '0;
            mode_s3      <= MODE_MULT_ONLY;
            clear_acc_s3 <= 1'b0;
        end else if (pipe_flush) begin
            clear_acc_s3 <= 1'b0;
        end else if (!pipe_stall) begin
            product_s3   <= product_comb;
            mode_s3      <= mode_s2;
            clear_acc_s3 <= clear_acc_s2;
        end
    end
    logic [MAC_ACC_WIDTH-1:0] accumulator;
    logic [MAC_ACC_WIDTH-1:0] acc_writeback_val;
    logic                     acc_wr_en;
    logic acc_hazard;
    assign acc_hazard = stage_valid[STAGE_ACCUMULATE] && acc_wr_en;
    logic [MAC_ACC_WIDTH-1:0] acc_input;
    always_comb begin
        if (mode_s3 == MODE_MULT_ONLY) begin
            acc_input = '0;
        end else if (clear_acc_s3) begin
            acc_input = '0;
        end else if (acc_hazard) begin
            acc_input = acc_writeback_val;
        end else begin
            acc_input = accumulator;
        end
    end
    logic [127:0] mac_raw_result;
    logic         mac_cout, mac_overflow_raw;
    logic [CSLA_NUM_GROUPS:0] acc_group_carries;
    csla_128bit u_acc_adder (
        .a             (product_s3),
        .b             (acc_input),
        .cin           (1'b0),
        .sat_en        (mode_s3 == MODE_MAC_SAT),   
        .sum           (mac_raw_result),
        .cout          (mac_cout),
        .overflow      (mac_overflow_raw),
        .group_carries (acc_group_carries)
    );
    logic [127:0] mac_result_processed;
    logic         overflow_detected;
    logic         saturation_triggered;
    always_comb begin
        mac_result_processed = mac_raw_result;
        overflow_detected    = 1'b0;
        saturation_triggered = 1'b0;
        case (mode_s3)
            MODE_MULT_ONLY: begin
                mac_result_processed = mac_raw_result;
            end
            MODE_MAC: begin
                mac_result_processed = mac_raw_result;
                overflow_detected    = mac_overflow_raw;
            end
            MODE_MAC_SAT: begin
                mac_result_processed = mac_raw_result;
                overflow_detected    = mac_overflow_raw;
                saturation_triggered = mac_overflow_raw;
            end
            MODE_MAC_MOD: begin
                overflow_detected = mac_overflow_raw;
                if (modulus != '0 && (mac_overflow_raw || mac_raw_result >= modulus)) begin
                    mac_result_processed = mac_raw_result - modulus;
                end else begin
                    mac_result_processed = mac_raw_result;
                end
            end
            default: begin
                mac_result_processed = mac_raw_result;
            end
        endcase
    end
    logic [127:0] result_s4;
    logic         overflow_s4;
    logic         saturated_s4;
    mac_mode_t    mode_s4;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_s4    <= '0;
            overflow_s4  <= 1'b0;
            saturated_s4 <= 1'b0;
            mode_s4      <= MODE_MULT_ONLY;
        end else if (pipe_flush) begin
            overflow_s4  <= 1'b0;
            saturated_s4 <= 1'b0;
        end else if (!pipe_stall) begin
            result_s4    <= mac_result_processed;
            overflow_s4  <= overflow_detected;
            saturated_s4 <= saturation_triggered;
            mode_s4      <= mode_s3;
        end
    end
    assign acc_wr_en = output_valid && (mode_s4 != MODE_MULT_ONLY);
    assign acc_writeback_val = result_s4;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= '0;
        end else if (!pipe_stall) begin
            if (clear_acc && !mac_en) begin
                accumulator <= '0;
            end else if (acc_wr_en) begin
                accumulator <= acc_writeback_val;
            end
        end
    end
    assign result    = result_s4;
    assign overflow  = overflow_s4;
    assign saturated = saturated_s4;
    assign valid     = output_valid;
endmodule : mac_top_64bit
