`include "defines.svh"

class ram_monitor;

  ram_transaction mon_trans;          // Handle to hold the captured data packet
  mailbox #(ram_transaction) mbx_ms;  // Mailbox to send data to the Scoreboard
  virtual ram_if.MON vif;             // Virtual interface pointer to look at the pins

  covergroup mon_cg;
    DATA_OUT: coverpoint mon_trans.data_out {
      bins dout = {[0:255]}; // Tracks if we saw all possible 8-bit output values
    }
  endgroup

  function new(virtual ram_if.MON vif, mailbox #(ram_transaction) mbx_ms);
    this.vif    = vif;
    this.mbx_ms = mbx_ms;
    mon_cg      = new(); // Allocate memory for the coverage collector
  endfunction

  task start();
    repeat(4) @(vif.mon_cb);

    for(int i = 0; i < `no_of_trans; i++) begin
      mon_trans = new(); // Create a fresh packet to hold the captured values

      @(vif.mon_cb);
      mon_trans.data_out = vif.mon_cb.data_out; // Capture output data from physical pin
      mon_trans.address  = vif.mon_cb.address;  // Capture address from physical pin

      $display("[MONITOR] Captured Data_out = %0d at Address = %0d", mon_trans.data_out, mon_trans.address);

      mbx_ms.put(mon_trans);

      mon_cg.sample();
      $display("[COVERAGE] Current Output Coverage = %0d%%", mon_cg.get_coverage());
      @(vif.mon_cb);
    end
  endtask

endclass
