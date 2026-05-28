# MC-MTC Artifacts

This repository contains the artifacts for the MC-MTC evaluation based on 5G-LENA (ns-3 NR).

## Overview

These artifacts provide:

- MC-MTC simulation scenarios (ns-3 scratch programs)
- Execution scripts for parameter sweeps
- Post-processing utilities
- Scripts to reproduce the reported CSV results

The artifacts are designed to be reproducible starting from a clean 5G-LENA installation.

---

## 1. Base Environment

The simulations were developed using:

- ns-3-dev with 5G-LENA (NR module)
- C++17
- Python 3.x
- Linux/macOS environment

Recommended base repository:

https://gitlab.com/cttc-lena/ns-3-dev.git

(Use a recent stable commit of ns-3-dev with NR enabled.)

---

## 2. Setup Instructions

### Step 1 — Clone ns-3 with NR

git clone https://gitlab.com/cttc-lena/ns-3-dev.git ns3
cd ns3

### Step 2 — Copy Artifact Files

Copy the contents of this repository into the ns-3 root directory:

- `scratch/`
- `run_sweeps.sh`
- `simulationResults_CG.sh`
- `utils.py`
- `test.py`



### Step 3 — Configure and Build

./ns3 configure --enable-examples
./ns3 build

## 3. Running Simulations

To execute the parameter sweep:

bash run_sweeps.sh

To reproduce CSV results:

bash simulationResults_CG.sh

## 4. Output

Simulation outputs are written to:

- Generated trace files
- CSV summary (`results_mcmtc_security.csv`)

---

## 5. Notes

- This artifact includes only scenario and scripting components.
- Core 5G-LENA / ns-3 source code is not modified.
- Ensure NR module is enabled during configuration.

---

## 6. Reproducibility

All simulations are deterministic under identical random seeds.

If any issue arises during reproduction, verify:

- ns-3 version compatibility
- Compiler supports C++17
- Required Python version is installed

