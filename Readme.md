ZynqMP ACP Adapter
==================

## Overview 

### Introduction

The PL masters can also snoop APU caches through the APU’s accelerator coherency port(ACP).
The ACP accesses can be used to (read or write) allocate into L2 cache. However, the ACP only supports aligned 64-byte and 16-byte accesses. All other accesses get a SLVERR response.

![Fig. ZynqMP PS-PL Interface](./doc/fig01.jpg "Fig.1 ZynqMP PS-PL Interface")

## Features

### Intermediation between ACP and AXI Master

The ZynqMP-ACP-Adapter is an adapter to connect AXI Master to ZynqMP Accelerator Coherency Port(ACP).

![Fig.2 Sample Design](./doc/fig02.png "Fig.2 Sample Design")

### Split Transaction

The ACP supports only aligned 64-byte and 16-byte accesses.    
The ZynqMP-ACP-Adapter splits a transaction of any burst length from the AXI Master into multiple 64-byte or 16-byte transactions.

![Fig.3 AXI Transaction to ACP Transactions](./doc/fig03.jpg "Fig.3 AXI Transaction to ACP Transactions")

### ACP_AxCACHE Overlay

The ZynqMP-ACP-Adapter will generate ACP_AxCache signals in place of the master if the master does not.    
See parameter ```ARCACHE_OVERLAY``` or ```AWCACHE_OVERLAY``` for details.

### ACP_AxProt Overlay

The ZynqMP-ACP-Adapter will generate ACP_AxProt signals in place of the master if the master does not.    
See parameter ```ARPROT_OVERLAY``` or ```AWPROT_OVERLAY``` for details.

### ACP_AxUser Overlay

The ZynqMP-ACP-Adapter will generate ACP_AxUser signals in place of the master if the master does not.    
See parameter ```ARSHARE_TYPE``` or ```AWSHARE_TYPE``` for details.

### VHDL Only

The ZynqMP-ACP-Adapter is written in synthesizable VHDL.

## Usage

### Download

```console
shell$ wget https://github.com/ikwzm/ZynqMP-ACP-Adapter/archive/refs/tags/v0.8.tar.gz
shell$ tar xfz v0.8.tar.gz
shell$ cd ZynqMP-ACP-Adapter-0.8
```

### Add IP Repository to Your Project

```
Vivado > Settigns > IP > Repository > add ZynqMP-ACP-Adapter-0.8/ip
```

### Add IP to Your Design

```
Vivado > Open Block Design > Add IP > select ZYNQMP_ACP_ADAPTER
```

### Parameters

#### CORE

##### AXI_WIDTH

These parameters specify the bit widths of various signals on the AXI side.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AXI_ID_WDITH```     | AXI ID WIDTH               |   1-5 |    5    |
|```AXI_DATA_WIDTH```   | AXI DATA WIDTH             |  128  |  128    |
|```AXI_ADDR_WDITH```   | AXI ADDRRESS WIDTH         | 1-    |   64    |
|```AXI_AUSER_WDITH```  | AXI AxUSER WIDTH           | 1-128 |    2    |

###### ```AXI_ID_WDITH```

The bit width of the ACP ID is fixed at 5 bits.    
```AXI_ID_WIDTH```(bit width of the ID on the AXI Master side) must be between 1 and 5.

###### ```AXI_DATA_WIDTH```

The bit width of DATA in ACP is fixed at 128 bits.   
```AXI_DATA_WIDTH```(bit width of RDATA/WDATA on AXI Master side) must be 128.

###### ```AXI_ADDR_WDITH```

The bit width of ADDRESS in ACP is fixed at 40 bits.   
```AXI_ADDR_WIDTH```(bit width of RDATA/WDATA on AXI Master side) must be greater than or equal to 1.

###### ```AXI_AUSER_WDITH```

The bit width of AxUSER in ACP is fixed at 2 bits.
ACP transactions can cause coherent requests to the system. Therefore, the ACP request must pass the inner and outer shareable attributes to the L2.
To pass the shareable attributes, use AxUSER; the encoding of AxUSER is shown in the following table.

| AxUSER[1:0] | Attribute      |
|:------------|:---------------|
| "00"        | Non-Sharable   |
| "01"        | Inner-Sharable |
| "10"        | Outer-Sharable |
| "11         | Not Supported  |


The conversion from AXI_AxUSER to ACP_AxUSER is based on ```ARSHARE_TYPE``` or ```AWSHRE_TYPE```.    
The valid ```AXI_AUSER_WDITH```(bit width of the AxUSER on the AXI Master side) for this conversion is different.    
See ```ARSHARE_TYPE``` or ```AWSHARE_TYPE``` for details.


##### READ/WRITE ENABLE

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
| ```READ_ENABLE```     | ACP READ ADAPTER ENABLE    |  0-1  |    1    |
| ```WRITE_ENABLE```    | ACP WRITE ADAPTER ENABLE   |  0-1  |    1    |

#### READ

##### READ CACHE

These parameters control the generation of the ACP_ARCACHE signal.   
To use ACP for cache coherency transfers, ACP_ARCACHE should output “1111” or “1110”.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```ARCACHE_OVERLAY```  | ACP_ARCACHE OVERLAY MASK   |  0-15 |    0    |
|```ARCACHE_VALUE```    | ACP_ARCACHE OVERLAY VALUE  |  0-15 |   15    |

These parameters are output with ACP_ARCACHE encoded as follows.

```VHDL
     constant cache_mask  :  std_logic_vector(3 downto 0) 
                          := std_logic_vector(to_unsigned(ARCACHE_OVERLAY, 4));
     constant cache_value :  std_logic_vector(3 downto 0) 
                          := std_logic_vector(to_unsigned(ARCACHE_VALUE  , 4));
    
     ACP_ARCACHE(0) <= cache_value(0) when (cache_mask(0) = '1') else AXI_ARCACHE(0);
     ACP_ARCACHE(1) <= cache_value(1) when (cache_mask(1) = '1') else AXI_ARCACHE(1);
     ACP_ARCACHE(2) <= cache_value(2) when (cache_mask(2) = '1') else AXI_ARCACHE(2);
     ACP_ARCACHE(3) <= cache_value(3) when (cache_mask(3) = '1') else AXI_ARCACHE(3);
```

If ```ARCACHE_OVERLAY``` is 0, the AXI_ARCACHE signal is output directly to ACP_ARCACHE.    
If ```ARCACHE_OVERLAY``` is 15, the AXI_ARCACHE signal is not used and the value of ```ARCACHE_VALUE``` is output.

##### READ PROT

These parameters control the generation of the ACP_ARPROT signal.   
To use ACP for cache coherency transfers, ACP_ARPROT should output “010”.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```ARPROT_OVERLAY```   | ACP_ARPROT OVERLAY MASK    |  0-7  |    0    |
|```ARPROT_VALUE```     | ACP_ARPROT OVERLAY VALUE   |  0-7  |    2    |

These parameters are output with ACP_ARPROT encoded as follows.

```VHDL
     constant prot_mask  :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(ARPROT_OVERLAY, 3));
     constant prot_value :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(ARPROT_VALUE  , 3));
    
     ACP_ARPROT(0) <= prot_value(0) when (prot_mask(0) = '1') else AXI_ARPROT(0);
     ACP_ARPROT(1) <= prot_value(1) when (prot_mask(1) = '1') else AXI_ARPROT(1);
     ACP_ARPROT(2) <= prot_value(2) when (prot_mask(2) = '1') else AXI_ARPROT(2);
```

If ```ARPROT_OVERLAY``` is 0, the AXI_ARPROT signal is output directly to ACP_ARPROT.    
If ```ARPROT_OVERLAY``` is 7, the AXI_ARPROT signal is not used and the value of ```ARPROT_VALUE``` is output.

##### READ SHARE

These parameters control the generation of the ACP_ARUSER signal.   

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```ARSHARE_TYPE```     | ACP READ SHARE TYPE        |  0-6  |    0    |

These parameters are output with ACP_ARUSER encoded as follows.

|```ARSHARE_TYPE```| AXI_ARUSER[1] | AXI_ARUSER[0] | ACP_ARUSER[1:0] | Discription     |
|:----------------:|:-------------:|:-------------:|:---------------:|:----------------|
|        0         |       x       |       x       |      "00"       | Non-Sharable    |
|        1         |       x       |       x       |      "01"       | Inner-Sharable  |
|        2         |       x       |       x       |      "10"       | Outer-Sharable  |
|        3         |       0       |       0       |      "00"       | Non-Sharable    |
|        3         |       0       |       1       |      "01"       | Inner-Sharable  |
|        3         |       1       |       x       |      "10"       | Outer-Sharable  |
|        4         |       x       |       0       |      "00"       | Non-Sharable    |
|        4         |       x       |       1       |      "01"       | Inner-Sharable  |
|        5         |       x       |       0       |      "00"       | Non-Sharable    |
|        5         |       x       |       1       |      "10"       | Outer-Sharable  |
|        6         |       x       |       0       |      "01"       | Inner-Sharable  |
|        6         |       x       |       1       |      "10"       | Outer-Sharable  |


##### READ REGS

These parameters set the internal register availability.     
See source code for details.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```RRESP_QUEUE_SIZE``` | READ RESPONSE QUEUE SIZE   |  1-8  |    2    |
|```RDATA_QUEUE_SIZE``` | READ DATA QUEUE SIZE       |  1-4  |    2    |
|```RDATA_INTAKE_REGS```| READ DATA INTAKE REGISTER  |  0-1  |    0    |

#### WRITE

##### WRITE CACHE

These parameters control the generation of the ACP_AWCACHE signal.   
To use ACP for cache coherency transfers, ACP_AWCACHE should output “1111” or “1110”.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AWCACHE_OVERLAY```  | ACP_AWCACHE OVERLAY MASK   |  0-15 |    0    |
|```AWCACHE_VALUE```    | ACP_AWCACHE OVERLAY VALUE  |  0-15 |   15    |

These parameters are output with ACP_AWCACHE encoded as follows.

```VHDL
     constant cache_mask  :  std_logic_vector(3 downto 0) 
                          := std_logic_vector(to_unsigned(AWCACHE_OVERLAY, 4));
     constant cache_value :  std_logic_vector(3 downto 0) 
                          := std_logic_vector(to_unsigned(AWCACHE_VALUE  , 4));
    
     ACP_AWCACHE(0) <= cache_value(0) when (cache_mask(0) = '1') else AXI_AWCACHE(0);
     ACP_AWCACHE(1) <= cache_value(1) when (cache_mask(1) = '1') else AXI_AWCACHE(1);
     ACP_AWCACHE(2) <= cache_value(2) when (cache_mask(2) = '1') else AXI_AWCACHE(2);
     ACP_AWCACHE(3) <= cache_value(3) when (cache_mask(3) = '1') else AXI_AWCACHE(3);
```

If ```AWCACHE_OVERLAY``` is 0, the AXI_AWCACHE signal is output directly to ACP_AWCACHE.    
If ```AWCACHE_OVERLAY``` is 15, the AXI_AWCACHE signal is not used and the value of ```AWCACHE_VALUE``` is output.

##### WRITE PROT

These parameters control the generation of the ACP_AWPROT signal.   
To use ACP for cache coherency transfers, ACP_AWPROT should output “010”.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AWPROT_OVERLAY```   | ACP_AWPROT OVERLAY MASK    |  0-7  |    0    |
|```AWPROT_VALUE```     | ACP_AWPROT OVERLAY VALUE   |  0-7  |    2    |

These parameters are output with ACP_AWPROT encoded as follows.

```VHDL
     constant prot_mask  :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(AWPROT_OVERLAY, 3));
     constant prot_value :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(AWPROT_VALUE  , 3));
    
     ACP_AWPROT(0) <= prot_value(0) when (prot_mask(0) = '1') else AXI_AWPROT(0);
     ACP_AWPROT(1) <= prot_value(1) when (prot_mask(1) = '1') else AXI_AWPROT(1);
     ACP_AWPROT(2) <= prot_value(2) when (prot_mask(2) = '1') else AXI_AWPROT(2);
```

If ```AWPROT_OVERLAY``` is 0, the AXI_AWPROT signal is output directly to ACP_AWPROT.    
If ```AWPROT_OVERLAY``` is 7, the AXI_AWPROT signal is not used and the value of ```AWPROT_VALUE``` is output.

##### WRITE SHARE

These parameters control the generation of the ACP_AWUSER signal.   

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AWSHARE_TYPE```     | ACP WRITE SHARE TYPE       |  0-6  |    0    |

These parameters are output with ACP_AWUSER encoded as follows.

|```AWSHARE_TYPE```| AXI_AWUSER[1] | AXI_AWUSER[0] | ACP_AWUSER[1:0] | Discription     |
|:----------------:|:-------------:|:-------------:|:---------------:|:----------------|
|        0         |       x       |       x       |      "00"       | Non-Sharable    |
|        1         |       x       |       x       |      "01"       | Inner-Sharable  |
|        2         |       x       |       x       |      "10"       | Outer-Sharable  |
|        3         |       0       |       0       |      "00"       | Non-Sharable    |
|        3         |       0       |       1       |      "01"       | Inner-Sharable  |
|        3         |       1       |       x       |      "10"       | Outer-Sharable  |
|        4         |       x       |       0       |      "00"       | Non-Sharable    |
|        4         |       x       |       1       |      "01"       | Inner-Sharable  |
|        5         |       x       |       0       |      "00"       | Non-Sharable    |
|        5         |       x       |       1       |      "10"       | Outer-Sharable  |
|        6         |       x       |       0       |      "01"       | Inner-Sharable  |
|        6         |       x       |       1       |      "10"       | Outer-Sharable  |

##### WRITE REGS

These parameters set the internal register availability.     
See source code for details.

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```WRESP_QUEUE_SIZE``` | WRITE RESPONSE QUEUE SIZE  |  1-8  |    2    |
|```WDATA_QUEUE_SIZE``` | WRITE DATA QUEUE SIZE      |  4-32 |   16    |
|```WDATA_OUTLET_REGS```| WRITE DATA OUTLET REGSITER |  0-8  |    5    |
|```WDATA_INTAKE_REGS```| WRITE DATA INTAKE REGSITER |  0-1  |    0    |

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

