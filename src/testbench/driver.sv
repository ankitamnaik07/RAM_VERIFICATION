`include "defines.svh"

class ram_driver;

  ram_transaction drv_trans;          // Handle to hold the active transaction packet
  mailbox #(ram_transaction) mbx_gd;  // Mailbox coming FROM the Generator
  mailbox #(ram_transaction) mbx_dr;  // Mailbox going TO the Reference Model
  virtual ram_if.DRV vif;             // Virtual interface pointer with DRV modport

  covergroup drv_cg;
    WRITE:   coverpoint drv_trans.write_enb { bins wrt[] = {0, 1}; }
    READ:    coverpoint drv_trans.read_enb  { bins rd[]  = {0, 1}; }
    DATA_IN: coverpoint drv_trans.data_in   { bins data  = {[0:255]}; }
    ADDRESS: coverpoint drv_trans.address  { bins address = {[0:31]}; }

    WRXRD: cross WRITE, READ {
      ignore_bins skip = binsof(WRITE) intersect {1} && binsof(READ) intersect {1};
    }
  endgroup

  function new(mailbox #(ram_transaction) mbx_gd,
               mailbox #(ram_transaction) mbx_dr,
               virtual ram_if.DRV vif);
    this.mbx_gd = mbx_gd;
    this.mbx_dr = mbx_dr;
    this.vif    = vif;
    drv_cg      = new(); // Instantiate coverage group
  endfunction

  task start();
    repeat(3) @(vif.drv_cb);

    for(int i = 0; i < `no_of_trans; i++) begin
      drv_trans = new();
      mbx_gd.get(drv_trans); // Fetch random transaction from Generator

      if(vif.drv_cb.reset == 0) begin
        @(vif.drv_cb);
        vif.drv_cb.write_enb <= 0;
        vif.drv_cb.read_enb  <= 0;
        vif.drv_cb.data_in   <= 8'bz; // High impedance float
        vif.drv_cb.address   <= 0;

        mbx_dr.put(drv_trans); // Keep the pipeline moving by passing it forward
        @(vif.drv_cb);
        $display("[DRIVER RESET] Holding pins idle at time %0t", $time);
      end

      else begin
        @(vif.drv_cb);
        // Drive transaction variables onto physical interface pins
        vif.drv_cb.write_enb <= drv_trans.write_enb;
        vif.drv_cb.read_enb  <= drv_trans.read_enb;
        vif.drv_cb.data_in   <= drv_trans.data_in;
        vif.drv_cb.address   <= drv_trans.address;

        @(vif.drv_cb); // Wait for the design to capture the data
        $display("[DRIVER DRIVING] Data: %0d to Address: %0d", drv_trans.data_in, drv_trans.address);

        vif.drv_cb.write_enb <= 0; // Clear write flag immediately so we don't double-write
        mbx_dr.put(drv_trans);     // Send packet to Reference Model

        drv_cg.sample();
        $display("[COVERAGE] Input Coverage = %0d%%", drv_cg.get_coverage());
      end
    end
  endtask

endclass
