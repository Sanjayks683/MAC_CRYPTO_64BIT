class mac_monitor;
    virtual mac_if vif;
    mailbox #(mac_transaction) mon_mbx;
    function new(virtual mac_if vif, mailbox #(mac_transaction) mbx);
        this.vif     = vif;
        this.mon_mbx = mbx;
    endfunction
    task run();
        mac_transaction txn;
        @(posedge vif.rst_n);
        forever begin
            @(posedge vif.clk);
            if (vif.valid) begin
                txn = new();
                txn.result    = vif.result;
                txn.overflow  = vif.overflow;
                txn.saturated = vif.saturated;
                txn.valid     = vif.valid;
                mon_mbx.put(txn);
            end
        end
    endtask
endclass
