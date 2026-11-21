# NanoRISC-V-C2: 2-Stage RV32I Processor Core

`NanoRISC-V-C2` is a fully standard-compliant, vendor-independent 2-stage pipelined 32-bit RISC-V (RV32I) processor core written in pure Verilog HDL.

---

## 1. Microarchitecture Overview

```
+------------------------------------+       +--------------------------------------------------------+
|       STAGE 1: FETCH (IF)          |       |     STAGE 2: DECODE / EXECUTE / MEMORY / WRITEBACK     |
|                                    |       |                                                        |
|   +----+        +--------------+   |       |   +--------------+      +---------+      +-----------+ |
|   | PC | -----> |  Instruction | =====[IF/ID]=>| Control Unit | ---> |   ALU   | ---> | Data Mem  | |
|   +----+        |    Memory    |   |  REG  |   +--------------+      +---------+      +-----------+ |
|     ^           +--------------+   |       |          |                   ^                 |       |
|     |                              |       |          v                   |                 v       |
|     |                              |       |   +--------------+           |            +----------+ |
|     |                              |       |   | Register File| ----------+----------> | WB MUX   | |
|     |                              |       |   +--------------+                        +----------+ |
|     |                              |       |          |                                     |       |
|     +====== Flush & Target PC =====+=======+==========+=====================================+       |
+------------------------------------+       +--------------------------------------------------------+
```

### 2-Stage Pipeline Specification
1. **Stage 1: Instruction Fetch (IF)**
   - Computes sequential PC (`pc + 4`) or redirects to `target_pc` upon branch/jump.
   - Accesses asynchronous 32-bit Instruction Memory.
   - Latches `(pc, instruction)` into the `if_id_reg` pipeline register.
2. **Stage 2: Instruction Decode, Execute, Memory, and Writeback (ID/EX/MEM/WB)**
   - Decodes RV32I opcodes, funct3, funct7.
   - Sign-extends immediate operands (I, S, B, U, J).
   - Reads dual register operands with internal zero-cycle bypass.
   - Computes ALU result (Arithmetic, Logical, Shifts, Comparisons).
   - Evaluates branch conditions (BEQ, BNE, BLT, BGE, BLTU, BGEU).
   - Handles byte, halfword, and word memory loads and stores (LB, LH, LW, LBU, LHU, SB, SH, SW).
   - Flushes the speculative instruction in Stage 1 with a 1-cycle NOP bubble (`32'h00000013`) on taken branches and jumps.
   - Commits writeback to Register File at posedge clock.

---

## 2. Directory Structure & Files

| Hardware Module | Description | Dedicated Testbench | Waveform File |
| :--- | :--- | :--- | :--- |
| `pc.v` | 32-bit Program Counter register | `pc_tb.v` | `pc.vcd` |
| `instruction_memory.v` | Word-addressable instruction memory (ROM) | `instruction_memory_tb.v` | `instruction_memory.vcd` |
| `if_id_reg.v` | Fetch-to-Execute pipeline register with bubble flush | `if_id_reg_tb.v` | `if_id_reg.vcd` |
| `imm_gen.v` | Sign-extending immediate generator for I/S/B/U/J | `imm_gen_tb.v` | `imm_gen.vcd` |
| `register_file.v` | 32x32-bit register file (x0=0) with write-through forwarding | `register_file_tb.v` | `register_file.vcd` |
| `alu.v` | 32-bit ALU for all RV32I arithmetic/logic/shifts | `alu_tb.v` | `alu.vcd` |
| `control_unit.v` | Main opcode decoder & branch resolution unit | `control_unit_tb.v` | `control_unit.vcd` |
| `data_memory.v` | Byte-addressable RAM (SB/SH/SW, LB/LH/LW/LBU/LHU) | `data_memory_tb.v` | `data_memory.vcd` |
| `nanoriscv_c2.v` | Top-level 2-stage pipelined processor core | `nanoriscv_c2_tb.v` | `nanoriscv_c2.vcd` |

---

## 3. Running Simulations with Icarus Verilog & GTKWave

### Run All Testbenches in One Command:
```cmd
run_sim.bat
```

### Or Run Individual Modules Manually:

#### 1. Program Counter:
```bash
iverilog -o pc_sim pc.v pc_tb.v
vvp pc_sim
gtkwave pc.vcd
```

#### 2. Instruction Memory:
```bash
iverilog -o imem_sim instruction_memory.v instruction_memory_tb.v
vvp imem_sim
gtkwave instruction_memory.vcd
```

#### 3. Pipeline Register:
```bash
iverilog -o if_id_sim if_id_reg.v if_id_reg_tb.v
vvp if_id_sim
gtkwave if_id_reg.vcd
```

#### 4. Immediate Generator:
```bash
iverilog -o imm_sim imm_gen.v imm_gen_tb.v
vvp imm_sim
gtkwave imm_gen.vcd
```

#### 5. Register File:
```bash
iverilog -o rf_sim register_file.v register_file_tb.v
vvp rf_sim
gtkwave register_file.vcd
```

#### 6. ALU:
```bash
iverilog -o alu_sim alu.v alu_tb.v
vvp alu_sim
gtkwave alu.vcd
```

#### 7. Control Unit:
```bash
iverilog -o cu_sim control_unit.v control_unit_tb.v
vvp cu_sim
gtkwave control_unit.vcd
```

#### 8. Data Memory:
```bash
iverilog -o dmem_sim data_memory.v data_memory_tb.v
vvp dmem_sim
gtkwave data_memory.vcd
```

#### 9. Full Top-Level Core:
```bash
iverilog -o core_sim pc.v instruction_memory.v if_id_reg.v imm_gen.v register_file.v alu.v control_unit.v data_memory.v nanoriscv_c2.v nanoriscv_c2_tb.v
vvp core_sim
gtkwave nanoriscv_c2.vcd
```
