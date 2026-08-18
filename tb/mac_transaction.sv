class mac_transaction;
    rand bit [63:0]  operand_a;
    rand bit [63:0]  operand_b;
    rand bit [1:0]   mode;
    rand bit         mac_en;
    rand bit         clear_acc;
    rand bit         stall;
    rand bit         flush;
    rand bit [127:0] modulus;
    bit [127:0] result;
    bit         overflow;
    bit         saturated;
    bit         valid;
    constraint c_default {
        mac_en    == 1'b1;
        stall     == 1'b0;
        flush     == 1'b0;
        clear_acc == 1'b0;
    }
    constraint c_modulus {
        (mode == 2'b11) -> (modulus > 0 && modulus < {128{1'b1}});
        (mode != 2'b11) -> (modulus == {128{1'b1}});
    }
    function void display(string tag = "TXN");
        $display("[%0t] %s: a=0x%0h b=0x%0h mode=%0b en=%0b clr=%0b | result=0x%0h ovf=%0b sat=%0b valid=%0b",
                 $time, tag, operand_a, operand_b, mode, mac_en, clear_acc,
                 result, overflow, saturated, valid);
    endfunction
    function mac_transaction copy();
        mac_transaction c = new();
        c.operand_a = this.operand_a;
        c.operand_b = this.operand_b;
        c.mode      = this.mode;
        c.mac_en    = this.mac_en;
        c.clear_acc = this.clear_acc;
        c.stall     = this.stall;
        c.flush     = this.flush;
        c.modulus   = this.modulus;
        return c;
    endfunction
endclass
