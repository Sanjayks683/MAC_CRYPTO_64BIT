class mac_driver;
    virtual mac_if vif;
    mailbox #(mac_transaction) drv_mbx;
    mailbox #(mac_transaction) scb_mbx;
    function new(virtual mac_if vif, mailbox #(mac_transaction) drv, mailbox #(mac_transaction) scb);
        this.vif     = vif;
        this.drv_mbx = drv;
        this.scb_mbx = scb;
    endfunction
    task reset();
        $display("[%0t] DRV: Waiting for reset", $time);
        @(posedge vif.rst_n);
        @(posedge vif.clk);
        $display("[%0t] DRV: Reset done", $time);
    endtask
    task run();
        mac_transaction txn;
        reset();
        forever begin
            drv_mbx.get(txn);
            @(posedge vif.clk);
            vif.operand_a <= txn.operand_a;
            vif.operand_b <= txn.operand_b;
            vif.mode      <= txn.mode;
            vif.mac_en    <= txn.mac_en;
            vif.clear_acc <= txn.clear_acc;
            vif.stall     <= txn.stall;
            vif.flush     <= txn.flush;
            vif.modulus   <= txn.modulus;
            scb_mbx.put(txn.copy());
        end
    endtask
endclass
