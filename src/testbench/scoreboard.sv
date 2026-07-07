`include "defines.svh"

class ram_scoreboard;

  // 1. PROPERTIES
  // Handles to hold incoming transactions
  ram_transaction ref2sb_trans;
  ram_transaction mon2sb_trans;

  // Mailboxes to receive data packages from the Reference Model and Monitor
  mailbox #(ram_transaction) mbx_rs;
  mailbox #(ram_transaction) mbx_ms;

  // Associative arrays (memories) to temporarily store data for comparison
  bit [7:0] ref_mem [bit [31:0]];
  bit [7:0] mon_mem [bit [31:0]];

  // Counters for tracking test results
  int PASS;
  int FAIL;

  // 2. CONSTRUCTOR (Connects the mailboxes)
  function new(mailbox #(ram_transaction) mbx_rs, mailbox #(ram_transaction) mbx_ms);
    this.mbx_rs = mbx_rs;
    this.mbx_ms = mbx_ms;
  endfunction

  // 3. METHODS
  // Main task to fetch transactions out of the mailboxes
  task start();
    for(int i = 0; i < `no_of_trans; i++) begin
      ref2sb_trans = new();
      mon2sb_trans = new();

      // Retrieve expected data from Reference Model mailbox
      mbx_rs.get(ref2sb_trans);
      ref_mem[ref2sb_trans.address] = ref2sb_trans.data_out;
      $display("[SB REF] Address: %0d, Data: %0d at time %0t", ref2sb_trans.address, ref2sb_trans.data_out, $time);

      // Retrieve actual data from Monitor mailbox
      mbx_ms.get(mon2sb_trans);
      mon_mem[mon2sb_trans.address] = mon2sb_trans.data_out;
      $display("[SB MON] Address: %0d, Data: %0d at time %0t", mon2sb_trans.address, mon2sb_trans.data_out, $time);

      // Compare the two results
      compare_report();
    end
  endtask

  // Task to check if actual data matches expected data
  task compare_report();
    if(ref_mem[ref2sb_trans.address] == mon_mem[mon2sb_trans.address]) begin
      $display("PASS Ref Data: %0d == Mon Data: %0d", ref_mem[ref2sb_trans.address], mon_mem[mon2sb_trans.address]);
     PASS++;
    end
    else begin
      $display("FAIL Ref Data: %0d != Mon Data: %0d", ref_mem[ref2sb_trans.address], mon_mem[mon2sb_trans.address]);
     FAIL++;
    end
          $display("=======================================================================");
  endtask

endclass
