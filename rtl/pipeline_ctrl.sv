module pipeline_ctrl
    import mac_pkg::*;
(
    input  logic                          clk,
    input  logic                          rst_n,
    input  logic                          mac_en,    
    input  logic                          stall,     
    input  logic                          flush,     
    output logic [MAC_PIPE_STAGES-1:0]    stage_valid,   
    output logic                          pipe_stall,    
    output logic                          pipe_flush,    
    output logic                          pipe_enable,   
    output logic                          output_valid   
);
    assign pipe_stall  = stall;
    assign pipe_flush  = flush;
    assign pipe_enable = !pipe_stall && !pipe_flush;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage_valid <= '0;
        end else if (pipe_flush) begin
            stage_valid <= '0;
        end else if (!pipe_stall) begin
            stage_valid[STAGE_INPUT] <= mac_en;
            for (int i = 1; i < MAC_PIPE_STAGES; i++) begin
                stage_valid[i] <= stage_valid[i-1];
            end
        end
    end
    assign output_valid = stage_valid[STAGE_OUTPUT] && !pipe_flush;
endmodule : pipeline_ctrl
