# RV-ZSH | A RISC-V Processor with Power Management and Branch Prediction

*A performance-optimized RISC-V processor with intelligent power management and adaptive branch prediction.*
> **Current Simulation Status:**
> The current `system_top.v` is a minimal, simulation-optimized version with a fixed instruction generator for robust testbench verification. The `enhanced_core` module remains unchanged. This setup is intended for simulation and verification only, not for full FPGA deployment.

## 🔩 Project Overview
This is a custom RISC-V processor implementation targeting the Z7-20 FPGA, featuring innovative microarchitectural enhancements for better performance.

## 📊 Current Status
[Updating with each commit.]
- ✅ Register File: Complete with performance monitoring.
- ✅ Register Test-bench File: Paired with register file for verification.
- ✅ Arithmetic Logic Unit: Complete.
- ✅ Arithmetic Logic Unit Test-bench File: Complete.
- ✅ Processor Core: Functional processor executing real RISC-V instructions.
- ✅ Core Test-bench File: Complete.
- ✅ Branch Predictor: Implemented, fully tested, and passing all testbenches.
- ✅ Branch Predictor Test-bench: Comprehensive, realistic scenarios covered with >75% prediction accuracy.
- ✅ Instruction Decoder: Enhanced, fully verified, 100% test pass rate.
- ✅ Instruction Decoder Test-bench: All instruction types and edge cases tested.
- ✅ Power Optimizer: Fully implemented, tested, and passing all testbenches (100% pass rate).
- ✅ Power Optimizer Test-bench: Comprehensive, covers all power management, DVFS, gating, and emergency scenarios.
- ✅ Workload Classifier: Fully implemented, AI-inspired workload monitoring.
- ✅ Workload Classifier Test-bench: Covers all workload types, adaptation, and learning scenarios.
- ✅ Clock Manager: Complete, with simulation-optimized version and testbench.
- ✅ Clock Manager Test-bench: Verifies frequency scaling, lock, and reset behavior.
- ✅ LED Display: Fully implemented, simulation-optimized, and tested.
- 🚧 Complete Core: Almost done.
- 📋 FPGA Implementation: Planned.
- 📋 Final Testing with Video: Planned.

## 🏗️ Architecture
[Will add more detail and a block diagram soon.]
- Modular, test-driven Verilog design.
- Adaptive branch prediction, AI-inspired workload classification, and power management integrated into the core pipeline.
- All modules verified with custom testbenches and simulation.
- **Simulation-Optimized Top:** The current top-level (`system_top.v`) is a minimal interface for simulation, with a fixed instruction generator. The processor core (`enhanced_core`) is unchanged for accurate verification.

## 🛠️ Development Environment
Z7-20 FPGA with Xilinx XC7Z020-1CLG400C on Vivado written in Verilog, verified using custom testbenches with comprehensive coverage. Visit the documents folder for testbench simulation results.

### 📁 Structure
```
/risc-v-processor-fpga/
├── build-project.tcl         # Vivado project build script
├── constraints/              # FPGA constraints (pin mapping, timing)
│   └── constraints.xdc
├── docs/                     # Documentation and simulation results
│   └── results/
│       ├── alu-simulation-results.md
│       ├── branch-predictor-simulation-results.md
│       ├── clock-manager-simulation-results.md
│       ├── core-simulation-results.md
│       ├── decoder-simulation-results.md
│       ├── enhanced-core-simulation-results.md
│       ├── enhanced-decoder-simulation-results.md
│       ├── power-optimizer-simulation-results.md
│       ├── register-simulation-results.md
│       └── workload_classifier-simulation-results.md
├── srcs/                     # All source files
│   ├── bd/                   # Block design (empty or for future use)
│   ├── ip/                   # Custom or third-party IP blocks
│   ├── rtl/                  # RTL (main Verilog modules)
│   │   ├── alu.v
│   │   ├── basic_instruction_decoder.v
│   │   ├── branch_predictor.v
│   │   ├── clock_manager.v
│   │   ├── core.v
│   │   ├── enhanced_core.v
│   │   ├── instruction_decoder.v
│   │   ├── led_display.v
│   │   ├── power_optimizer.v
│   │   ├── register.v
│   │   ├── system_top.v      # Top-level system (simulation-optimized)
│   │   └── workload_classifier.v
│   └── sim/                  # Testbenches for simulation
│       ├── alu_tb.v
│       ├── basic_instruction_decoder_tb.v
│       ├── branch_predictor_tb.v
│       ├── clock_manager_tb.v
│       ├── core_tb.v
│       ├── enhanced_core_tb.v
│       ├── instruction_decoder_tb.v
│       ├── power_optimizer_tb.v
│       ├── register_tb.v
│       ├── system_tb.v       # System-level testbench
│       └── workload_classifier_tb.v
```
### 📚 Features
- Adaptive Confidence Branch Predictor: Custom branch prediction algorithm with confidence tracking, ensemble prediction, and local/global history.
- Intelligent Power Management: Predictive power gating, dynamic voltage/frequency scaling, and emergency handling (fully functional).
- AI-Inspired Workload Classifier: Real-time workload classification, adaptive learning, and pattern recognition for optimal power management.
- Performance Monitoring: Real-time instruction, workload, and power analysis.
- Professional Implementation: Standard design practices and documentation.
- Clock Management: Simulation-optimized clock manager with frequency scaling and lock detection.
- LED Status Display: Real-time system status and mode display, fully tested.

## 🔬 Technical Highlights
[Will update with time.]
### Branch Predictor
- Two-level adaptive predictor with global and local history.
- Pattern table and confidence table for robust prediction.
- Ensemble logic combines multiple prediction sources.
- Real-time accuracy and performance monitoring.
- Achieved >75% accuracy on realistic and random branch patterns.
- 100% test pass rate on all testbench scenarios.
- [Simulation Results (Branch Predictor)](docs/results/branch-predictor-simulation-results.md)

### Instruction Decoder
- Fully RISC-V compliant, supports all RV32I instruction formats.
- Decodes opcode, register fields, immediate values, and control signals.
- Handles all edge cases and invalid instructions.
- 100% test pass rate on all testbench scenarios.
- [Simulation Results (Instruction Decoder)](docs/results/enhanced-decoder-simulation-results.md)

### Power Optimizer
- Fully implemented, tested, and verified (100% test pass rate).
- Implements predictive power optimization, DVFS, power gating, thermal management, and emergency handling.
- Adaptive learning and workload-aware power management.
- [Simulation Results (Power Optimizer)](docs/results/power-optimizer-simulation-results.md)

### Workload Classifier
- Fully implemented, AI-inspired workload monitoring and classification using real-time feature extraction, pattern recognition, and adaptive learning (inspired by clustering and ensemble methods).
- Real-time feature extraction, pattern recognition, and adaptive learning.
- Achieved >90% overall classification accuracy in comprehensive simulation.
- 100% test pass rate on all workload formats and adaptation scenarios.
- [Simulation Results (Workload Classifier)](docs/results/workload_classifier-simulation-results.md)

### Clock Manager
- Simulation-optimized clock manager with frequency scaling, lock detection, and reset handling.
- Fully verified with a dedicated testbench covering all frequency and reset scenarios.
- [Simulation Results (Clock Manager)](docs/results/clock-manager-simulation-results.md)

### LED Display
- Real-time system status and mode display for both simulation and hardware.
- Supports multiple display modes and status indicators.

### Register
- 32 registers, 32-bit each and RISC-V compliant.
- Real-time access tracking and power monitoring.
- Most-used register identification.

### Arithmetic Logic Unit
- Implements all RISC-V RV32I arithmetic and logic operations.
- Custom power consumption modeling (8-22 power units).
- Comprehensive performance monitoring.
- 100% test pass rate (40/40 tests).

### Processor Core
- Performance monitoring functional across processor.
- Power tracking integrated throughout datapath.
- 100% test coverage on all implemented modules.

## 📎 Getting Started
Prerequisites are AMD Vivado and a ZYNQ-7020 FPGA development board. Download the `build-project.tcl` file to recreate the project for implementation on your device.

---
## Contact
**Sadad Haidari** | Computer Engineering Student | [LinkedIn](https://linkedin.com/in/sadadh)

*Built with passion for computer architecture and digital design.*

---

