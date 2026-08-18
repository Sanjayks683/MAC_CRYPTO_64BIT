class mac_scoreboard;
    mailbox #(mac_transaction) scb_mbx;
    mailbox #(mac_transaction) mon_mbx;
    int pass_count = 0;
    int fail_count = 0;
    int total      = 0;
    logic [127:0] acc_model = '0;
    function new(mailbox #(mac_transaction) scb, mailbox #(mac_transaction) mon);
        this.scb_mbx = scb;
        this.mon_mbx = mon;
    endfunction
    task run();
        mac_transaction in_txn, out_txn;
        logic [127:0] product;
        logic [127:0] expected;
        logic [128:0] sum_ext;
        forever begin
            scb_mbx.get(in_txn);
            mon_mbx.get(out_txn);
            total++;
            if (in_txn.stall || in_txn.flush || !in_txn.mac_en) begin
                continue;
            end
            product = in_txn.operand_a * in_txn.operand_b;
            if (in_txn.clear_acc)
                acc_model = '0;
            case (in_txn.mode)
                2'b00: begin
                    expected  = product;
                end
                2'b01: begin
                    sum_ext   = {1'b0, acc_model} + {1'b0, product};
                    expected  = sum_ext[127:0];
                    acc_model = expected;
                end
                2'b10: begin
                    sum_ext = {1'b0, acc_model} + {1'b0, product};
                    if (sum_ext[128]) begin
                        expected = {128{1'b1}};
                    end else begin
                        expected = sum_ext[127:0];
                    end
                    acc_model = expected;
                end
                2'b11: begin
                    sum_ext = {1'b0, acc_model} + {1'b0, product};
                    expected = sum_ext[127:0];
                    if (in_txn.modulus != 0 && (sum_ext[128] || expected >= in_txn.modulus))
                        expected = expected - in_txn.modulus;
                    acc_model = expected;
                end
            endcase
            if (in_txn.mode == 2'b00)
                acc_model = '0;
            if (out_txn.result === expected) begin
                pass_count++;
            end else begin
                fail_count++;
                $display("[%0t] SCB FAIL #%0d: mode=%0b a=0x%0h b=0x%0h", $time, total, in_txn.mode, in_txn.operand_a, in_txn.operand_b);
                $display("       Expected: 0x%0h", expected);
                $display("       Got:      0x%0h", out_txn.result);
            end
        end
    endtask
    function void report();
        $display("");
        $display("============================================");
        $display("  SCOREBOARD SUMMARY");
        $display("  Total: %0d  Pass: %0d  Fail: %0d", total, pass_count, fail_count);
        if (fail_count == 0)
            $display("  *** TEST PASSED ***");
        else
            $display("  *** TEST FAILED ***");
        $display("============================================");
        $display("");
    endfunction
endclass
