# Tic-Tac-Toe Project

- [Setting up Vivado Project in Github](./docs/GITHUB_PROJECT_SETUP.md)

## Getting Started

This repository is managed using a **TCL-based Vivado workflow**.  
Instead of committing Vivado-generated project files, this project can be recreated using a TCL script.

This approach:

- Keeps the repository clean
- Avoids committing tool-generated files
- Makes it easy to clone and rebuild the project on any machine

### Cloning and Rebuilding Project

#### 1. Clone the repository

```bash
git clone https://github.com/kr1s-r/FPGA-Tic-Tac-Toe.git
```

#### 2. Recreate the Vivado Project

- Open Vivado and open the Tcl console and do the following commands

```tcl
cd c:/<project-location>/PROJECT_NAME
source ./Tic-Tac-Toe-Project.tcl
```

#### 3. You might have to add all source files in Vivado Project Manager

- add design sources (`.sv`, `.vhd`)
- add simulation sources
- add constraints (`.xdc`)
- add any IP cores needed from IP catalog
- etc

Like the following:

<p align="center">
  <a href="./images/vivado_project_manager.png">
    <img src="./images/vivado_project_manager.png" alt="Vivado Project Manager" width="700">
  </a>
</p>

---

## 📡 UART Configuration

| Parameter        | Value                 |
| ---------------- | --------------------- |
| **Baud Rate**    | 115200 (configurable) |
| **Data Bits**    | 8                     |
| **Parity**       | None                  |
| **Stop Bits**    | 1                     |
| **Flow Control** | None                  |

---

## 🛠 Tools & Technologies

- **Hardware Description Language (HDL):** SystemVerilog
- **Simulation:** Xilinx Vivado Simulator
- **FPGA Tools:** Xilinx Vivado Design Suite (2025.1)
- **FPGA Board:** Digilent Basys3 Artix-7 FPGA board
- **Terminal Software (for UART):** TeraTerm (can use RealTerm or PuTTY as well)
