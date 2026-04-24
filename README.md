# Assertion-Based Verification and Coverage-Driven Design of a UART Core

## 📌 Project Overview
This project presents a robust **Functional Verification** suite for a UART (Universal Asynchronous Receiver-Transmitter) IP core. Moving beyond traditional directed testing, this repository demonstrates a professional **Metric-Driven Verification (MDV)** flow using SystemVerilog. The primary objective was to validate design integrity through **96%+ Code Coverage** and **Assertion-Based Verification (ABV)**.

---

## ⚙️ 1. RTL Design Architecture
The UART system consists of two primary modules, both implemented using a Finite State Machine (FSM) to ensure predictable hardware behavior.

### UART Transmitter (TX)
- **Parallel-to-Serial Conversion:** Converts 8-bit input data into a serial bitstream.
- **Parity Generation:** Computes even parity for error detection.
- **Handshaking:** Provides `tx_busy` and `tx_done` signals for real-time status monitoring.

### UART Receiver (RX)
- **Mid-Bit Sampling:** A critical feature that samples incoming serial data at the center of the bit period ($1.5 \times \text{Bit Period}$ after start bit) to maximize noise immunity and minimize synchronization errors.
- **Serial-to-Parallel Conversion:** Reconstructs the 8-bit data and validates parity before asserting `rx_done`.



---

## 🧪 2. Verification Methodology
The verification environment is built in **SystemVerilog**, utilizing advanced verification pillars:

### A. Constrained Randomization
- Utilizes a `uart_packet` class to generate 100+ randomized data packets.
- Automatically explores corner cases that manual directed tests might miss.

### B. Assertion-Based Verification (ABV)
- **Concurrent Assertions (SVA):** Monitors the protocol in real-time.
- **Protocol Checks:** Verified that `rx_done` and `tx_done` signals pulse for exactly one clock cycle and that `tx_busy` logic remains consistent during transmission.

### C. Coverage-Driven Design
- **Code Coverage:** Statement and Branch coverage tracked to ensure every logical path in the RTL is exercised.
- **Functional Coverage:** Defined **Covergroups** with specific bins (Zeros, Ones, Alternating bits) to ensure the generated stimulus covers the full data spectrum.



---

## 📊 3. Final Verification Reports
Based on the simulation results from **QuestaSim 10.7c**:

| Metric | UART Transmitter (TX) | UART Receiver (RX) |
| :--- | :--- | :--- |
| **Statement Coverage** | **97.14%** | **96.00%** |
| **Assertion Pass Rate** | **100%** | **100 Passes** |
| **Functional Coverage** | **50.00%** | **25.00%** |

> **Note:** Functional coverage reflects the diversity of random stimulus. Coverage holes identified (e.g., 0xAA, 0x00) provide clear targets for future directed testing to reach 100% closure.

---
## 🛠️ 4. Tools & Technologies
- Verilog HDL  
- SystemVerilog HDL  
- QuestaSim   

---

## 👨‍💻 Abishek S
- xia2020.abisheks@gmail.com
- www.linkedin.com/in/abishek-s-848564258
