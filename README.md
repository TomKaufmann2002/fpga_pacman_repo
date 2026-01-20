# FPGA Pac-Man (DE10-Standard)


## Project Description
SystemVerilog RTL implementation of a Pac-Man–style game on the DE10-Standard FPGA, using PS/2 keyboard input and VGA output. Includes custom game logic and pixel-level rendering; debugged using ModelSim & Signal Tap and implemented on the DE10-Standard board.


## This version includes:

- Tile-based VGA graphics engine  

- Pac-Man and ghost motion logic  

- PS/2 keyboard input  

- Scoreboard and UI modules  

- Modular RTL architecture  


## Demonstration:

Click the image below to watch a YouTube demo showcasing the game.

[![Project demonstration](https://img.youtube.com/vi/fAgSB6om3eE/maxresdefault.jpg)](https://www.youtube.com/watch?v=fAgSB6om3eE)

## Simulation (ModelSim)

Waveform example used to debug the ghost chase direction request logic (`req_dir`) based on target position, current position, and legal movement directions:

<img width="1469" height="297" alt="Screenshot 2026-01-20 020655" src="https://github.com/user-attachments/assets/d0dc57df-b1fb-4142-95f0-fbff3ae76464" />


Created by **Tom Kaufmann & Yotam Efroni**
