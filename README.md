# Matlab Modelling
---
Present are two different modelling projects conducted in Matlab to perform complex calculations and graphically display the data

### Transmission Line Sag
The Matlab script `TransmissionLineSagModel.m` is a calculation set that models the amount that a transmission line will sag based on its thermal properties, conductivity, running current, size and the ambient temperature over a period of a year. This model is conducted for both *ACSR 560 7* and *ACSR 560 19* steel wires of various lengths. The model is able to draw conclusions on the safety of the transmission lines to ensure that they will not sag past acceptable and safe levels.

### Energy Savings Model
The Matlab script `EnergySavingsModel/MEA_Savings.m` is a large calculation set that models the projected savings from the construction of an entropy wheel fan in the building Ellis Hall on the Queen's University campus. The calculations draw real humidity and entering and exiting tempearature values over the course of a year as an input. The thermal enthalpy projections are calaulated, as if an enthalpy wheel was present and used to draw conclusions on potential savings based on the energy that is saved by not needing to heat that air. A final recommendation is then drawn, based on the cost of the enthalpy wheel and the savings from using less energy, computed as a quote for each potential energy source.