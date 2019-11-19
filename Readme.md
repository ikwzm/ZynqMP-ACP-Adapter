ZynqMP ACP Adapter
==================

## Overview 

### Introduction

The PL masters can also snoop APU caches through the APU’s accelerator coherency port(ACP).
The ACP accesses can be used to (read or write) allocate into L2 cache. However, the ACP only supports aligned 64-byte and 16-byte accesses. All other accesses get a SLVERR response.

![Fig. ZynqMP PS-PL Interface](./doc/fig01.jpg "Fig.1 ZynqMP PS-PL Interface")

## Features

ZynqMP-ACP-Adapter is an adapter to connect AXI Master to ZynqMP Accelerator Coherency Port(ACP).

![Fig.2 Sample Design](./doc/fig02.png "Fig.2 Sample Design")

The adapter then splits any burst-length transaction into several 64-byte or 16-byte transactions.

![Fig.3 AXI Transaction to ACP Transactions](./doc/fig03.jpg "Fig.3 AXI Transaction to ACP Transactions")

ZynqMP-ACP-Adapter is written in synthesizable VHDL.

## Structure

### Read Adapter Structure

![Fig.4 Read Adapter Structure](./doc/fig04.jpg "Fig.4 Read Adapter Structure")

### Write Adapter Structure

![Fig.5 Write Adapter Structure](./doc/fig05.jpg "Fig.5 Write Adapter Structure")

![Fig.6 Write Data Path](./doc/fig06.jpg "Fig.6 Write Data Path")

## Timing

### Read Timing Example

![Fig.7 Read Timing Example](./doc/fig07.jpg "Fig.7 Read Timing Example")

### Write Timing Example

![Fig.8 Write Timing Example](./doc/fig08.jpg "Fig.8 Write Timing Example")

### Multi Transaction

![Fig.9 Multi Transaction(same id) Example](./doc/fig09.jpg "Fig.9 Multi Transaction(same id) Example")

![Fig.10 Multi Transaction(different id) Example](./doc/fig10.jpg "Fig.10 Multi Transaction(diffent id) Example")

## Measured waveform

### Measured waveform of read transaction

![Fig.12 Measured waveform of read transaction](./doc/fig12.png "Fig.12 Measured waveform of read transaction")


### Measured waveform of write transaction

![Fig.13 Measured waveform of write transaction](./doc/fig13.png "Fig.13 Measured waveform of write transaction")

## Licensing

Distributed under the BSD 2-Clause License.

