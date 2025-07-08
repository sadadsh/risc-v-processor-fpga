# RVZEN | A RISC-V Processor with Power Management and Branch Prediction

*A performance-optimized RISC-V processor with intelligent power management and adaptive branch prediction.*

## 🔩 Project Overview
This is a custom RISC-V processor implementation targeting the Z7-20 FPGA, featuring innovative microarchitectural enhancements for better performance.

## 📊 Current Status
[Coming soon.]
- ✅ Register File: Complete with performance monitoring.
- ✅ Register Test-bench File: Paired with register file for verification.
- ✅ Arithmetic Logic Unit: Complete.
- ✅ Arithmetic Logic Unit Test-bench File: Complete.
- ✅ Processor Core: Functional processor executing real RISC-V instructions.
- ✅ Core Test-bench File: Complete.
- 🚧 Branch Predictor: Working on it.
- 📋 Power Manager: Design phase.
- 📋 Complete Core: Planned.

## 🏗️ Architecture
[Coming soon.]

## 🛠️ Development Environment
Z7-20 FPGA with Xilinx XC7Z020-1CLG400C on Vivado written in Verilog, verified using custom testbenches with comprehensive coverage. Visit the documents folder for testbench simulation results.
### 📁 Structure
[Coming soon.]
### 📚 Features
[In development.]
- Adaptive Confidence Branch Predictor: Custom branch prediction algorithm with confidence tracking.
- Intelligent Power Management: Predictive power gating and dynamic voltage scaling.
- Performance Monitoring: Real-time instruction and power analysis.
- Professional Implementation: Standard design practices and documentation.

## 🔬 Technical Highlights
[Will update with time.]
### Register
- 32 registers, 32-bit each and RISC-V compliant.
- Real-time access tracking and power monitoring.
- Most-used register identification.
### Arithmetic Logic Unit
- Implemented all RISC-V RV32I arithmetic and logic operations.
- Added custom power consumption modeling (8-22 power units).
- Included comprehensive performance monitoring.
- Achieved 100% test pass rate (40/40 tests).
- Support ADD, SUB, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA.

*Innovation Features: Real-time operation frequency tracking, power estimation per operation, most-used operation identification, and overall verification for processes.*
### Processor Core
- All RISC-V R-instructions work.
- Performance monitoring functional across processor.
- Power tracking integrated throughout datapath.
- 100% test coverage on all implemented modules.

## 📎 Getting Started
Prerequisites are AMD Vivado and a ZYNQ-7020 FPGA development board, download the `build-project.tcl` file to recreate the project for implementation on your device.

---
## Contact
**Sadad Haidari** | Computer Engineering Student | [LinkedIn](https://linkedin.com/in/sadadh)

*Built with passion for computer architecture and digital design.*

---

