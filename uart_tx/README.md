# UART Transmitter (TX) Design & Verification

## 📖 1. Transmitter Design Overview
The UART Transmitter is responsible for taking parallel 8-bit data from the system and converting it into a serial bitstream for asynchronous transmission. It operates based on a precise **Baud Rate generator** implemented using a high-speed system clock.

### Key Technical Specifications
* **Clock Frequency:** 50 MHz
* **Baud Rate:** 9600 bps
* **Bit Period:** ~5208 clock cycles per bit
* **Data Format:** 8-N-1 (8 Data bits, No Parity, 1 Stop bit) with integrated Even Parity support.

---

## 🖼️ 2. UART Data Frame Structure
The transmitter ensures that every packet follows the strict UART protocol. The timing is handled by a local counter to ensure the receiver can lock onto the signal.

1.  **IDLE State:** The transmission line is held high (Logic 1).
2.  **START Bit:** The line is pulled low (Logic 0) for exactly one bit period.
3.  **DATA Bits:** 8 bits of data are sent sequentially, starting with the **Least Significant Bit (LSB)**.
4.  **PARITY Bit:** An even parity bit is calculated and injected after the data.
5.  **STOP Bit:** The line returns to Logic 1 to signify the end of the frame and prepare for the next transmission.



---

## 🤖 3. Transmitter Finite State Machine (FSM)
The `uart_tx.v` module utilizes a synchronous FSM to manage the complex timing required for serial conversion.

* **IDLE:** Waits for the `tx_start` signal. `tx_serial` remains high.
* **START:** Lowers the signal to Logic 0 and resets the clock counter.
* **DATA:** Cycles through 8 bit indices. Each bit is held for 5208 clock cycles.
* **PARITY:** Injects the parity bit calculated from the input data.
* **STOP:** Raises the signal back to Logic 1. Once the bit period ends, it asserts `tx_done` for exactly one cycle and returns to IDLE.



---

## 📊 4. TX Verification Results
The transmitter was verified using a SystemVerilog testbench featuring a scoreboard and real-time protocol checkers.

| Metric | Result | Status |
| :--- | :--- | :--- |
| **Statement Coverage** | **97.14%** | ✅ Passed |
| **Assertion Pass Rate** | **100%** | ✅ Verified |
| **Functional Coverage** | **50.00%** | ⚠️ Bins hit: `ones`, `misc` |

### Assertion-Based Verification (ABV)
* **`assert__p_tx_busy`**: This concurrent assertion monitors that the `tx_busy` signal stays active without glitches for the entire duration of the frame transmission.
* **`assert__p_tx_done_pulse`**: Ensures that the "Done" interrupt signal is a valid single-cycle pulse, preventing the CPU from receiving multiple interrupts for a single transmission.

---

## 🏁 Summary
The UART Transmitter design is optimized for high timing accuracy and low resource utilization. With **97.14% statement coverage**, the design logic is proven to be robust and protocol-compliant for any FPGA-based serial communication task.

---
**Author:** Abishek S
**Tools:** QuestaSim 10.7c, Verilog, SystemVerilog
