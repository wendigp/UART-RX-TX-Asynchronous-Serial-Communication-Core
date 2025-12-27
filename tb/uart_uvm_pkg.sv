package uart_uvm_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  //==================================================
  // TRANSACTIONS
  //==================================================
  `include "tx_agent/tx_txn.sv"
  `include "rx_agent/rx_txn.sv"

  //==================================================
  // CONFIGURATION CLASSES
  //==================================================
  `include "config/tx_config.sv"
  `include "config/rx_config.sv"
  `include "config/env_config.sv"

  //==================================================
  // TX DRIVER / MONITOR / SEQUENCER
  //==================================================
  `include "tx_agent/tx_driver.sv"
  `include "tx_agent/tx_monitor.sv"
  `include "tx_agent/tx_sequencer.sv"

  //==================================================
  // RX MONITOR (RX AGENT IS PASSIVE)
  //==================================================
  `include "rx_agent/rx_monitor.sv"

  //==================================================
  // AGENTS
  //==================================================
  `include "tx_agent/tx_agent.sv"
  `include "rx_agent/rx_agent.sv"

  //==================================================
  // SEQUENCES
  //==================================================
  `include "tx_agent/tx_sequence.sv"

  //==================================================
  // VIRTUAL SEQUENCER & VIRTUAL SEQUENCES
  //==================================================
  `include "virtual_seq/virtual_sequencer.sv"
  `include "virtual_seq/virtual_sequence.sv"

  //==================================================
  // SCOREBOARD
  //==================================================
  `include "scoreboard/scoreboard.sv"

  //==================================================
  // ENVIRONMENT
  //==================================================
  `include "env/env.sv"

  //==================================================
  // TESTS
  //==================================================
  `include "uart_test/uart_test.sv"

endpackage

