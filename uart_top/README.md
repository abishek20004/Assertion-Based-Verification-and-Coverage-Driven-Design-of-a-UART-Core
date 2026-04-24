# Integrated UART System: Design and Verification

## 📌 Project Overview
This module represents the **System Integration** phase of the project. By combining the Transmitter (TX) and Receiver (RX) into a single `uart_top` peripheral, the project moves from unit-level bit timing to **System-Level Data Integrity**. 

---

## ⚙️ 1. Integrated RTL Architecture (`uart_top.v`)

The `uart_top` module serves as a structural wrapper that manages the interconnection between the two primary sub-modules.

### **Block Diagram**


### **Functional Working: TX & RX Together**
In this integrated architecture, the TX and RX work in a **Full-Duplex capable** environment:
1.  **Shared Resources:** Both modules operate on a synchronized 50MHz clock and a common active-low reset (`rst_n`).
2.  **The Serial Loopback:** The `uart_tx_pin` is externally or internally tied to the `uart_rx_pin`. This creates a closed-loop communication system where the transmitter's serial bitstream becomes the receiver's input.
3.  **Synchronization:** The system ensures that while the TX is busy serializing a byte, the RX is simultaneously monitoring the line to detect the falling edge of the Start bit.

### **Module Variations**
* **UART Transmitter (TX):** Operates as the master of the serial line, generating the start, data, and stop bits based on the `tx_start` trigger.
* **UART Receiver (RX) - Direct Sampling:** > **Design Note:** Unlike the standalone RX module found elsewhere in this repo, this integrated version utilizes a **Simplified Direct Sampling** approach. It removes the complex Mid-Bit Sampling logic to demonstrate a leaner RTL footprint, relying on fixed bit-period counters to capture data.

---

## 🧪 2. Verification Environment (`tb_uart_top.sv`)

The verification suite for the integrated system is designed to validate **End-to-End Data flow**.

### **How the Testbench Works:**
1.  **Stimulus Generation:** The testbench uses `std::randomize` to generate 100 unique data packets.
2.  **Mailbox Scoreboarding:** Before a byte is sent to the `tx_data` input, it is placed in a **SystemVerilog Mailbox**. This acts as our "golden reference."
3.  **Transmission & Reception:** The TB pulses `tx_start`. The data travels through the TX, across the `serial_line`, and into the RX.
4.  **Automated Comparison:** Upon the `rx_done` pulse, the testbench retrieves the original byte from the Mailbox and compares it with the `rx_data_out`. If they match, a "Success" message is logged.

---

## 📊 3. Final System Verification Report

The metrics below represent the performance of the **Integrated System** as a whole, demonstrating the high efficiency of loopback-based testing.

| Metric | Integrated System Result | Status |
| :--- | :---: | :---: |
| **Statement Coverage** | **96.50%** | ✅ Target Met |
| **Assertion Pass Rate** | **100% (100/100 Packets)** | ✅ Passed |
| **Functional Coverage** | **87.50%** | 📈 High |

---

## 🏁 Summary

### **Reasoning for System Performance:**
* **Why 87.50%?** By tying the TX and RX together, the testbench naturally exercises the interaction between both Finite State Machines (FSMs). This "Loopback" method automatically triggers the **Full-Duplex** coverage bins, which are impossible to hit when testing modules in isolation.
* **Remaining 12.5% Gap:** The current random stimulus did not hit the specific "Toggle" bin (e.g., alternating `0xAA` and `0x55` patterns back-to-back), which would require targeted constrained-random stimulus to close.

---
