# Assertion-Based Verification and Coverage-Driven Design of a UART Core

## 📌 Project Overview
This project presents a robust **Functional Verification** suite for a UART (Universal Asynchronous Receiver-Transmitter) IP core. Moving beyond traditional directed testing, this repository demonstrates a professional **Metric-Driven Verification (MDV)** flow using SystemVerilog. The primary objective was to validate design integrity through **96%+ Code Coverage** and **Assertion-Based Verification (ABV)**.

---

## ⚙️ 1. RTL Design Architecture
The system is developed through a modular approach, starting with individual components and culminating in a fully integrated communication system.

### UART Transmitter (TX)
- **Parallel-to-Serial Conversion:** Converts 8-bit input data into a serial bitstream.
- **Parity Generation:** Computes even parity for error detection.
- **Handshaking:** Provides `tx_busy` and `tx_done` signals for real-time status monitoring.

### UART Receiver (RX)
- **Mid-Bit Sampling:** A critical feature that samples incoming serial data at the center of the bit period ($1.5 \times \text{Bit Period}$ after start bit) to maximize noise immunity and minimize synchronization errors.
- **Serial-to-Parallel Conversion:** Reconstructs the 8-bit data and validates parity before asserting `rx_done`.

### Integrated System Architecture
The `uart_top` module integrates the TX and RX into a unified communication peripheral.
- **Full-Duplex Support:** Allows simultaneous transmission and reception over a shared clock domain.
- **Loopback Testing Logic:** Features an internal data path to route `tx_serial` directly to `rx_serial` for self-diagnostics and system-level validation.
- **Unified Interface:** Provides a single point of control for the entire UART system, simulating a real-world SoC peripheral.

---

## 🧪 2. Verification Methodology
The verification environment is built in **SystemVerilog**, utilizing advanced verification pillars:

### A. Constrained Randomization
- Utilizes a `uart_packet` class to generate 100+ randomized data packets.
- Automatically explores corner cases that manual directed tests might miss.

### B. Assertion-Based Verification (ABV)
- **Concurrent Assertions (SVA):** Monitors the protocol in real-time.
- **Data Integrity Check:** Specifically includes the `assert_data_match` property to verify that the byte transmitted by the TX is identical to the byte reconstructed by the RX.
- **Protocol Checks:** Verified that `rx_done` and `tx_done` signals pulse for exactly one clock cycle and that `tx_busy` logic remains consistent during transmission.

### C. Coverage-Driven Design
- **Code Coverage:** Statement and Branch coverage tracked to ensure every logical path in the RTL is exercised.
- **Functional Coverage:** Defined **Covergroups** with specific bins (Zeros, Ones, Alternating bits) to ensure the generated stimulus covers the full data spectrum.

---

---

## 📊 3. Final Verification Reports (Comparative Analysis)
Based on the simulation results from **QuestaSim**, the following table compares the performance across the standalone modules versus the integrated system.

| Metric | UART Transmitter (TX) | UART Receiver (RX) | Integrated System |
| :--- | :---: | :---: | :---: |
| **Statement Coverage** | **97.14%** | **96.00%** | **96.50% (Overall)** |
| **Assertion Pass Rate** | **100%** | **100 Passes** | **100% Pass** |
| **Functional Coverage** | **50.00%** | **25.00%** | **87.50%** |

### **Coverage Gap Analysis**
* **UART Transmitter (50.00%):** The lower coverage in standalone mode is due to the limited stimulus space. While data transmission was verified, the testbench did not exercise back-to-back "toggle" patterns (e.g., 0xAA to 0x55) or varying baud rate configurations, which are required to hit 100% of the defined functional bins.
* **UART Receiver (25.00%):** Standalone RX testing focused primarily on successful data reconstruction. It lacked coverage for error-handling scenarios—such as parity errors, framing errors, and noise-induced glitches—which represent a large portion of the functional coverage plan.
* **Integrated System (87.50%):** Coverage improved significantly during integration. By tying the TX and RX together, the testbench naturally exercised **Full-Duplex traffic** and **Internal Loopback paths**. This interaction allowed the stimulus to hit complex bins (like simultaneous TX/RX activity) that standalone unit tests simply cannot capture.

---
---

## 🛠️ 4. Tools & Technologies
- **Verilog HDL:** RTL Design
- **SystemVerilog:** Verification & Assertions
- **QuestaSim:** Simulation & Coverage Analysis

---

## 👨‍💻 Abishek S
- **Email:** xia2020.abisheks@gmail.com
- **LinkedIn:** [linkedin.com/in/abishek-s-848564258](https://www.linkedin.com/in/abishek-s-848564258)
