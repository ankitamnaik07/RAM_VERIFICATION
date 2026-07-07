class ram_test;
  // 1. PROPERTIES (Virtual Interfaces & Environment)
  virtual ram_if drv_vif;
  virtual ram_if mon_vif;
  virtual ram_if ref_vif;

  ram_environment env;

  // 2. CONSTRUCTOR: Links top-level wires to test variables
  function new(virtual ram_if drv_vif,
               virtual ram_if mon_vif,
               virtual ram_if ref_vif);
    this.drv_vif = drv_vif;
    this.mon_vif = mon_vif;
    this.ref_vif = ref_vif;
  endfunction

  // 3. METHODS: Base test sequence run
  virtual task run();
    env = new(drv_vif, mon_vif, ref_vif); // Create the environment object
    env.build();                          // Build all testbench sub-components
    env.start();                          // Kick off simulation loops
  endtask
endclass


// --------------------------------------------------------------------
// TEST 1: Read-Only Scenario (Child Class)
// --------------------------------------------------------------------
class test1 extends ram_test;
  ram_transaction1 trans; // Custom transaction with Read constraints

  function new(virtual ram_if drv_if, virtual ram_if mon_if, virtual ram_if ref_if);
    super.new(drv_if, mon_if, ref_if); // Run parent setup logic
  endfunction

  virtual task run();
    $display("Test ID:1");
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();

    trans = new();
    env.gen.blueprint = trans; // Hand custom Read mold to the Generator

    env.start();
  endtask
endclass


// --------------------------------------------------------------------
// TEST 2: Write-Only Scenario (Child Class)
// --------------------------------------------------------------------
class test2 extends ram_test;
  ram_transaction2 trans;

  function new(virtual ram_if drv_if, virtual ram_if mon_if, virtual ram_if ref_if);
    super.new(drv_if, mon_if, ref_if);
  endfunction

  virtual task run();
    $display("Running Test ID: 2");
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();

    trans = new();
    env.gen.blueprint = trans;

    env.start();
  endtask
endclass


// --------------------------------------------------------------------
// TEST 3: Simultaneous Read/Write Scenario (Child Class)
// --------------------------------------------------------------------
class test3 extends ram_test;
  ram_transaction3 trans;

  function new(virtual ram_if drv_if, virtual ram_if mon_if, virtual ram_if ref_if);
    super.new(drv_if, mon_if, ref_if);
  endfunction

  virtual task run();
    $display("Running Test ID: 3");
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();

    trans = new();
    env.gen.blueprint = trans;

    env.start();
  endtask
endclass


// --------------------------------------------------------------------
// TEST 4: Fully Idle / Standby Scenario (Child Class)
// --------------------------------------------------------------------
class test4 extends ram_test;
  ram_transaction4 trans;

  function new(virtual ram_if drv_if, virtual ram_if mon_if, virtual ram_if ref_if);
    super.new(drv_if, mon_if, ref_if);
  endfunction

  virtual task run();
    $display("Running Test ID: 4");
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();

    trans = new();
    env.gen.blueprint = trans;

    env.start();
  endtask
endclass


// --------------------------------------------------------------------
// TEST_REGRESSION: Automated Master Test Sequence using Object Queue
// --------------------------------------------------------------------
class test_regression extends ram_test;
  // SystemVerilog Queue array container holding tests
  ram_test q[$];

  // Handles for individual targeted testcases
  ram_test  t0;
  test1     t1;
  test2     t2;
  test3     t3;
  test4     t4;

  function new(virtual ram_if drv_vif,
               virtual ram_if mon_vif,
               virtual ram_if ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  virtual task run();
    // Step A: Instantiate clean test objects for every distinct ruleset
    t0 = new(drv_vif, mon_vif, ref_vif);
    t1 = new(drv_vif, mon_vif, ref_vif);
    t2 = new(drv_vif, mon_vif, ref_vif);
    t3 = new(drv_vif, mon_vif, ref_vif);
    t4 = new(drv_vif, mon_vif, ref_vif);

    // Step B: Collect them sequentially inside the array list container
    q.push_back(t0);
    q.push_back(t1);
    q.push_back(t2);
    q.push_back(t3);
    q.push_back(t4);

    // Step C: Seamlessly loop and execute them in order
    foreach(q[i]) begin
      $display("\n[REGRESSION] Launching Test Sequence ID: %0d...", i);
      q[i].run(); // Dynamically executes the unique child .run() tasks
    end
  endtask
endclass
