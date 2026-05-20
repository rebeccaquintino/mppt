# MPPT P&O Generator with PV Emulator

This project implements a **Perturb and Observe (P&O) Maximum Power Point Tracking (MPPT)** controller integrated with a Photovoltaic (PV) array emulator, developed for the FPGA course at UFSC.

## 📐 Technical Specifications

- **Target Device**: Cyclone IV EP4CE115F29C7 (Intel/Altera DE2-115 Board)
- **Clock Frequency**: 50 MHz (Main clock) / 5 Hz (MPPT sampling rate) 
- **MPPT Algorithm**: Perturb & Observe (P&O)
- **PV Emulation**: Includes dynamic I-V curve modeling with adjustable solar irradiance and load resistance 
- **Peripherals Used**: 
  - `KEY` buttons for irradiance control 
  - `SW` switches for load resistance and reset 
  - `HEX` 7-segment displays for Duty Cycle and Power monitoring 
  - `LEDR` bar graph for Duty Cycle visual feedback 

## 📦 Project Structure

- **`doc/`**: Reference materials, datasheets, and the final project presentation.
- **`hdl/`**: VHDL source files (`mppt.vhd`, `pv.vhd`, and `mppt_top.vhd`). 

## 🙋‍♀️ Authors

Developed by **Rebecca Quintino Do Ó** and **Marina Dualibi** As part of the *EEL410269 Lógica Programável FPGA para Eletrônica de Potência* course – UFSC  
[GitHub Repository](https://github.com/seu-usuario/seu-repositorio)
