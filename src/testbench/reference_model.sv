class ram_reference_model;

  // 1. PROPERTIES
  ram_transaction ref_trans;          // Handle to hold our working data packet
  mailbox #(ram_transaction) mbx_dr;  // Mailbox coming FROM the Driver
  mailbox #(ram_transaction) mbx_rs;  // Mailbox going TO the Scoreboard
  virtual ram_if.REF_SB vif;          // Virtual interface pointer for clock sync

  // The Golden Memory: Software array mimicking our RAM hardware storage
  bit [7:0] MEM [bit [31:0]];

  // 2. CONSTRUCTOR (Setup connections)
  function new(mailbox #(ram_transaction) mbx_dr,
               mailbox #(ram_transaction) mbx_rs,
               virtual ram_if.REF_SB vif);
    this.mbx_dr = mbx_dr;
    this.mbx_rs = mbx_rs;
    this.vif    = vif;
  endfunction

  // 3. MAIN TASK (Predicting behavior)
  task start();
    for(int i = 0; i < `no_of_trans; i++) begin
      ref_trans = new(); // Fresh packet container

      // Step A: Get the stimulus packet that the Driver sent to the RAM
      mbx_dr.get(ref_trans);

      // Step B: Synchronize with the clocking block edge
      @(vif.ref_cb);

      // --- WRITE OPERATION ---
      if(ref_trans.write_enb) begin
        MEM[ref_trans.address] = ref_trans.data_in; // Store data in software memory
        $display("[REF MODEL WRITE] Saved Data: %0d at Address: %0d", ref_trans.data_in, ref_trans.address);
      end

      // --- READ OPERATION ---
      if(ref_trans.read_enb) begin
        ref_trans.data_out = MEM[ref_trans.address]; // Predict what output should be
        $display("[REF MODEL READ] Predicted Data_out: %0d from Address: %0d", ref_trans.data_out, ref_trans.address);
      end

      // Step C: Send this predicted packet to the Scoreboard to be used as the answer key
      mbx_rs.put(ref_trans);
    end
  endtask

endclass
