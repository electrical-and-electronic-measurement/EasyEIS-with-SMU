# Electrochemical Impedance Spectroscopy (EIS)

Typically, Electrochemical Impedance Spectroscopy (EIS) measurements are performed using a single sine
excitation, which is repeated at several different frequencies. (_single sine method_).

Most commonly, EIS is measured using a “single-sine” method where individual frequencies are measured sequentially.  One disadvantage of single-sine EIS is the time it takes to acquire a full spectrum

Broadband approches (such as _multisine method_) allow for shorter measurement time and are a better choice for online measurement and monitoring applications. (1)(2)

## How EIS is Done

Single-Sine EIS measurements involve applying a sinusoidal perturbation (voltage or current) and measuring the response (current or voltage respectively). The measurement is complete when it is deemed to be satisfactory, or some time limit is reached.

This decision requires a mathematically sound criterion for a satisfactory measurement. Gamry’s Single-Sine technique terminates the measurement at each frequency when its signal to noise ratio exceeds a target value (2)


## References

1. Gamry Instruments, Application Note Basics of Electrochemical Impedance Spectroscopy].  Available online [https://www.gamry.com/assets/Application-Notes/Basics-of-EIS.pdf](https://www.gamry.com/assets/Application-Notes/Basics-of-EIS.pdf), 2010

2. Gamry Instruments, Application Note, “OptiEIS™: A Multisine Implementation,” Available online : [https://www.gamry.com/applicationnotes/EIS/optieis-a-multisine-implementation/](https://www.gamry.com/applicationnotes/EIS/optieis-a-multisine-implementation/), 2020.


The measurement of battery impedance is crucial for
online monitoring of State of Charge (SoC) and State of
Health (SoH) [1]. Such monitoring is required in numerous
applications, including electric vehicles, electronic
systems, and stationary energy storage [2].
 [3]. However,  [4]. As an example, in [5]
multisine signals are employed for EIS characterization of
biological materials. Furthermore, in [6] multisine signals
are used for detecting and modeling nonlinearities in EIS
measurement systems for Li-Ion batteries. Other possible
broadband excitations include binary and ternary
sequences, which can be also applied to system
identification [7][8].
In this paper, we present a low-complexity system for
fast, broadband EIS on Li-Ion batteries. The system is
based on a Howland current pump circuit for the excitation
and a general-purpose data acquisition board (DAQ)
providing the readout functionality. The basic version of
the Howland current pump is used, even though several
enhanced versions of the Howland current pump circuits
are published in the literature [9]. Furthermore, a shunt
resistor is employed for current readout, although several
more refined readout methods are commonly applied, such
as balancing AC bridge circuits. This is to keep the
hardware complexity of the circuit to a minimum, since the
proposed system measures both voltage and current, thus
it can compensate for non-ideal behavior through signal
processing. Also, the use of non-sinusoidal signals may
result in additional constraints, more easily satisfied by
simple electronic systems. 