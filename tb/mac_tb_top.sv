`timescale 1ns/1ps
`include "mac_transaction.sv"
`include "mac_generator.sv"
`include "mac_driver.sv"
`include "mac_monitor.sv"
`include "mac_scoreboard.sv"
module mac_tb_top;
    import mac_pkg::*;
    localparam CLK_PERIOD = 10;
    localparam NUM_TXNS   = 50;
    logic clk;
    logic rst_n;
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end
    initial begin
        rst_n = 1'b0;
        repeat (20) @(posedge clk);
        rst_n = 1'b1;
        $display("[%0t] TB: Reset released", $time);
    end
    mac_if mac_vif(.clk(clk), .rst_n(rst_n));
    mac_top_64bit u_dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .operand_a  (mac_vif.operand_a),
        .operand_b  (mac_vif.operand_b),
        .mac_en     (mac_vif.mac_en),
        .mode       (mac_vif.mode),
        .clear_acc  (mac_vif.clear_acc),
        .stall      (mac_vif.stall),
        .flush      (mac_vif.flush),
        .modulus    (mac_vif.modulus),
        .result     (mac_vif.result),
        .overflow   (mac_vif.overflow),
        .saturated  (mac_vif.saturated),
        .valid      (mac_vif.valid)
    );
    mailbox #(mac_transaction) gen2drv  = new();
    mailbox #(mac_transaction) drv2scb  = new();
    mailbox #(mac_transaction) mon2scb  = new();
    mac_generator  gen;
    mac_driver     drv;
    mac_monitor    mon;
    mac_scoreboard scb;
    initial begin
        gen = new(gen2drv, NUM_TXNS);
        drv = new(mac_vif, gen2drv, drv2scb);
        mon = new(mac_vif, mon2scb);
        scb = new(drv2scb, mon2scb);
        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none
        @(gen.done);
        repeat (20) @(posedge clk);
        scb.report();
        $finish;
    end
    initial begin
        #50_000_000;
        $display("TB: Simulation timeout");
        $finish;
    end
    `ifdef DUMP_WAVES
        initial begin
            $dumpfile("mac_tb.vcd");
            $dumpvars(0, mac_tb_top);
        end
    `endif
endmodule : mac_tb_top
