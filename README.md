# UART-RX-TX-Asynchronous-Serial-Communication-Core
This project implements a **UART RX-TX core** using **Verilog HDL**, enabling reliable **asynchronous serial communication** without a shared clock between transmitter and receiver. The design targets realistic **SoC and peripheral communication** scenarios where clock distribution is impractical.

---

## Key Features
- Asynchronous UART communication
- Baud-rate–based timing
- UART Transmitter (TX) and Receiver (RX)
- Start bit, data bits (LSB-first), and stop bit support
- Center-bit sampling for reliable reception
- `tx_busy` mechanism to prevent data corruption
- Modular and synthesizable RTL design

---

## Design Overview
- **Baud Rate Generator**  
  Generates baud ticks from the system clock to define bit timing.

- **UART TX**  
  Serializes parallel data into a UART frame and controls transmission using `tx_busy`.

- **UART RX**  
  Detects the start bit asynchronously and samples data at the center of each bit for improved noise immunity and baud mismatch tolerance.

---

## Verification
- Simulated using **QuestaSim** and **Synopsys VCS**
- Verified for:
  - Correct TX/RX operation
  - Accurate baud timing
  - Back-to-back data transmission
  - Stable center-bit sampling

## Directory 
uart/
├── rtl/
│   ├── baud_rate_generator.v   # Baud rate tick generator
│   ├── uart_tx.v               # UART transmitter
│   ├── uart_rx.v               # UART receiver
│   └── uart_top.v              # Top-level UART integration
├── sim/
│   └── uart_tb.v               # Testbench
└── README.md                   # Project documentation


---

## Tools Used
- Verilog HDL
- QuestaSim
- Synopsys VCS
- Git & GitHub

---

## Future Enhancements
- Parity and framing error detection
- Configurable data length and stop bits
- APB-based UART control interface
- UVM-based verification environment


