# Enhanced RISC-V Processor with Adaptive Optimizations

A 32-bit RISC-V processor implementation featuring adaptive branch prediction and intelligent power management, designed for the Xilinx ZYNQ-7000 FPGA platform.

## Overview

This project implements a complete RISC-V RV32I processor with two notable enhancements beyond standard academic implementations:

**Branch Predictor** - An ensemble prediction algorithm that combines global and local history with dynamic confidence tracking. The predictor learns patterns in real-time and achieves ~95% accuracy in simulation.

**Power Optimizer** - A workload-aware power manager that classifies instruction patterns and dynamically adjusts voltage, frequency, and component power gating. Testing shows ~40% power reduction compared to baseline operation.

## Architecture

The processor uses a 5-stage pipeline (Fetch, Decode, Execute, Memory, Writeback) with the following major components:

- **32-Bit Arithmetic Logic Unit (ALU):** Full RV32I instruction support with integrated power monitoring.
- **32×32-Bit Register File:** General-purpose register file with access tracking and usage statistics.
- **Instruction Decoder:** Decodes all RV32I instructions and generates control signals for the pipeline.
- **Branch Predictor:** Two-level adaptive algorithm with global and local history, branch-type specialization, and confidence weighting.
- **Workload Classifier:** Real-time analysis of instruction streams to classify workload types (compute, memory, control, mixed, etc.).
- **Power Optimizer:** Dynamically manages DVFS (dynamic voltage and frequency scaling), power gating, and thermal throttling based on workload and system constraints.
- **Clock Manager:** Supports multiple frequency levels for power scaling and adapts to power/thermal conditions.
- **Top Module:** Integrates all subsystems, manages I/O, and coordinates demo/FPGA-specific features.
- **LED Display Controller:** Drives the hardware demo interface, providing real-time feedback on processor state and optimizations.
- **Testbenches:** For all major modules, enabling thorough verification and validation.

The design targets the Xilinx XC7Z020-1CLG400C FPGA and includes comprehensive verification testbenches.

## Performance Results

Simulation results from comprehensive testing:

| Metric | Value | Notes |
|--------|--------|-------|
| Branch Prediction Accuracy | ~95% | 96 correct out of 101 predictions |
| Workload Classification | ~95% | Across mixed instruction patterns |
| Power Reduction | ~40% | With workload-adaptive optimization |
| Test Coverage | 100% | All 100+ test checks passed |

The branch predictor demonstrates learning behavior, improving from initial poor performance to 95% accuracy as it adapts to instruction patterns. I didn't implement aggressive hazard mitigation or deep pipelining, therefore the IPC is on the lower side for a RISC-V implementation (around 0.2).

## Interactive Hardware Demo

The system includes an interactive demonstration mode for FPGA deployment. See [DEMO.md](DEMO.md) for complete details on the hardware interface, LED indicators, and demonstration phases.

The demo showcases real-time branch predictor learning, power management adaptation, and workload classification across different instruction sequences.

## Implementation Details

### File Structure
```
risc-v-processor-fpga/
├── build-project.tcl                   # Vivado project generation script
├── DEMO.md                             # Demo datasheet
├── constraints/zybo_z7_20.xdc          # FPGA pin assignments and timing
├── docs/results/                       # Simulation results and analysis
├── srcs/rtl/                           # Verilog source modules
│   ├── enhanced_core.v                 # Main processor with optimizations
│   ├── branch_predictor.v              # Adaptive prediction algorithm  
│   ├── power_optimizer.v               # Workload-aware power management
│   ├── workload_classifier.v           # Instruction pattern analysis
│   ├── instruction_decoder.v           # RISC-V instruction decoder
│   ├── alu.v                           # Arithmetic logic unit
│   └── [additional core modules]
└── srcs/sim/                           # Detailed verification testbenches
    ├── enhanced_core_tb.v              # System-level testing
    ├── branch_predictor_tb.v           # Prediction algorithm verification
    └── [component testbenches]
```

### Development Environment
- **Target FPGA:** Xilinx Zynq-7000 XC7Z020-1CLG400C (Zybo Z7-20)
- **Development Tools:** AMD Vivado 2025.x with Verilog HDL
- **Verification:** Custom testbenches with comprehensive coverage
- **Build Automation:** TCL script for complete project recreation

### Algorithms

The branch predictor implements a two-level adaptive scheme with separate global and local history tables, as well as branch specialization. Confidence tracking enables ensemble prediction where multiple predictors contribute based on their reliability for specific patterns. It maintains a global register for capturing patterns, a pattern table that uses saturating counters to predict taken and not-taken, and a 4-bit confidence value that updates based on prediction correctness. On each branch resolution, the predictor goes to update the global and local histories, adjusts the pattern and confidence tables, and tracks accuracies at the same time. This allows teh predictor to be able to learn both the short-term and long-term patterns.

The power optimizer extracts features from instruction streams (compute intensity, memory access patterns, control flow) and classifies workloads in real-time using predictive adaptation with buffers and trends. Power states are adjusted based on classification results and external constraints like thermal readings and power budgets. DVFS (dynamic voltage and frequency scaling) is scaled according to the given workload classification, performance mode, and thermal/power constraints. Power gating will also disable units from the enhanced core (such as the arithmetic logic unit, register, branch predictor, etc.) when idle or under lighter workloads. Thermal throttling is engaged when temperature or power goes past thresholds (including logic for recovering from this state).

## Verification and Testing

The design includes extensive verification through custom testbenches that exercise all major functionality:

- **Component-level Testing** for the arithmetic logic unit, register file, predictors, and other specialized units
- **Integration Testing** with realistic instruction sequences and mixed workloads  
- **Stress Testing** for power management under various thermal and budget constraints
- **Performance Regression Testing** to validate optimization effectiveness

All testbenches achieve 100% pass rates with comprehensive coverage of normal operation, edge cases, and error conditions. Simulation results are documented in the `docs/results/` directory.

## Getting Started

### Prerequisites
- AMD Vivado 2025.x or later
- Xilinx Zynq-7000 development board (Zybo Z7-20 recommended)

### Building the Project
```bash
# Clone repository
git clone [sadadsh/risc-v-processor-fpga]
cd risc-v-processor-fpga

# Generate Vivado project
vivado -mode tcl
source build-project.tcl

# Run simulations (optional, make chosen file top level beforehand)
launch_simulation chosen_tb.v

# Make sure system_top.v is top level module before programming the FPGA.

# Synthesize -> Implement -> Generate Bitstream -> Hardware Manager -> Program
```

The `build-project.tcl` script automatically creates the complete Vivado project structure, imports all source files, applies constraints, and configures simulation and synthesis settings.

## Project Scope

This processor demonstrates computer architecture concepts including adaptive prediction algorithms, power-aware design, and workload characterization. The implementation goes incorporates research-level optimizations with measurable performance improvements.

The design emphasizes practical engineering considerations like verification methodology, build automation, and hardware demonstration capabilities suitable for FPGA deployment.

---

**Author:** Sadad Haidari | Computer Engineering Student | The George Washington University  
**Contact:** [LinkedIn](https://linkedin.com/in/sadadh)