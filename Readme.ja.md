





# はじめに


## ZynqMP ACP とは


ZynqMP には Processing System(以下PS) と Programmable Logic(以下PL) を接続するインターフェースが幾つかあります(下図参照)。


![Fig.1 ZynqMP PS-PL Interface](./doc/fig01.jpg "Fig.1 ZynqMP PS-PL Interface")

Fig.1 ZynqMP PS-PL Interface

<br />



 Accelerator Coherency Port(以下ACP) はそのうちの一つで、以下の特徴を持っています。



*  Application Proccessing Unit(以下APU)のキャッシュとコヒーレンシを維持しつつ Memory Subsystemに対してリードライト出来ます。
*  ACP は 16-byte(Data Widthの128bit)単位、または アライメントされた64-byte(APUのキャッシュラインサイズ)単位でしかアクセス出来ません。それ以外でアクセスした場合、SLVERR が返ってきます。
*  ACP は APUの ACP I/F を介して直接 APU と接続しています。そのため AXI HPC portと異なりInner Share 領域にあるので、 boot.bin に小細工をする必要がありません。 ([『UltraZed 向け Debian GNU/Linux で AXI HPC port を使う (基礎編)』](https://qiita.com/ikwzm/items/82f98bfa76922073e610)参照)


## ZynqMP ACP アダプタとは


### ACP と AXI Master との仲介

ZynqMP ACP アダプタは、ACP の転送サイズに対応していない AXI マスターをZynqMP の ACP に接続するためのものです。具体的には AXI マスターと ZynqMP の ACP の間に入り、AXI マスターからのトランザクションを ACP のトランザクションサイズに分割します。


![Fig.2 Sample Design](./doc/fig02.png "Fig.2 Sample Design")

Fig.2 Sample Design

<br />

### 転送の分割

ACP は前節で説明したように 16-byte(Data Widthの128bit)単位、または アライメントされた64-byte(APUのキャッシュラインサイズ)単位でしかアクセス出来ません。したがって通常の DMA などの AXI マスターを接続するときは、AXI マスターのほうでトランザクションサイズを調整する必要があります。

例えば、AXI から転送開始アドレスが0xXX-XXXX-X024で転送サイズが183Byte のアクセスがあった場合、ZynqMP ACP アダプタは下図のように6つの ACPトランザクションに分割します。  


![Fig.3 AXI Transaction to ACP Transactions](./doc/fig03.jpg "Fig.3 AXI Transaction to ACP Transactions")

Fig.3 AXI Transaction to ACP Transactions

<br />

### ACP_AxCACHE Overlay


ZynqMP ACP アダプタは、AXI マスターが AXI_AxCache を生成しない場合、マスターの代わりに ACP_AxCache を生成します。 詳細については、パラメータ ```ARCACHE_OVERLAY``` または ```AWCACHE_OVERLAY``` を参照してください。

### ACP_AxProt Overlay

ZynqMP ACP アダプタは、AXI マスターが AXI_AxProt を生成しない場合、マスターの代わりに ACP_AxProt を生成します。 詳細については、パラメータ ```ARPROT_OVERLAY``` または ```AWPROT_OVERLAY``` を参照してください。

### ACP_AxUser Overlay

ZynqMP ACP アダプタは、マスターが AXI_AxUser を生成しない場合、マスターの代わりに ACP_AxUser を生成します。 詳細については、パラメータ ```ARPROT_TYPE``` または ```AWPROT_TYPE``` を参照してください。

# 使い方

### ダウンロード

ZyqnMP ACP アダプタは以下の URL で公開しています。

 * https://github.com/ikwzm/ZynqMP-ACP-Adapter

次のようにダウンロードしてください。

```console
shell$ wget https://github.com/ikwzm/ZynqMP-ACP-Adapter/archive/refs/tags/v0.8.tar.gz
shell$ tar xfz v0.8.tar.gz
shell$ cd ZynqMP-ACP-Adapter-0.8
```

### プロジェクトに IP リポジトリを追加

```
Vivado > Settigns > IP > Repository > add ZynqMP-ACP-Adapter-0.8/ip
```

### デザインに ZynqMP ACP アダプタを追加

```
Vivado > Open Block Design > Add IP > select ZYNQMP_ACP_ADAPTER
```

## パラメータの説明

### CORE

#### AXI_WIDTH

これらのパラメータは、AXI 側の様々な信号のビット幅を指定します。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AXI_ID_WDITH```     | AXI ID WIDTH               |   1-5 |    5    |
|```AXI_DATA_WIDTH```   | AXI DATA WIDTH             |  128  |  128    |
|```AXI_ADDR_WDITH```   | AXI ADDRRESS WIDTH         | 1-    |   64    |
|```AXI_AUSER_WDITH```  | AXI AxUSER WIDTH           | 1-128 |    2    |

##### ```AXI_ID_WDITH```

ACP ID のビット幅は 5 ビット固定です。   
```AXI_ID_WIDTH```(AXIマスター側のIDのビット幅)は1以上5以下でなければなりません。

##### ```AXI_DATA_WIDTH```

ACP の DATA のビット幅は 128 ビット固定です。  
```AXI_DATA_WIDTH```(AXIマスタ側のRDATA/WDATAのビット幅)は128である必要があります。

##### ```AXI_ADDR_WDITH```

ACP の ADDRESS のビット幅は 40 ビット固定です。   
```AXI_ADDR_WIDTH```(AXIマスタ側のRDATA/WDATAのビット幅)は1以上でなければなりません。

##### ```AXI_AUSER_WDITH```

ACP における AxUSER のビット幅は2ビット固定です。
ACP トランザクションは、システムにコヒーレント要求を引き起こす可能性があります。したがって、ACP へのトランザクション時に、内側と外側の共有可能属性を L2 に渡す必要があります。
共有可能な属性を渡すには、AxUSERを使用します。AxUSERのエンコーディングを以下の表に示します。

| AxUSER[1:0] | Attribute      |
|:------------|:---------------|
| "00"        | Non-Sharable   |
| "01"        | Inner-Sharable |
| "10"        | Outer-Sharable |
| "11         | Not Supported  |


AXI_AxUSER から ACP_AxUSER への変換は ```ARSHARE_TYPE``` または ```AWSHRE_TYPE``` に基づいて行われます。   
この変換に有効な ```AXI_AUSER_WDITH```（AXIマスター側のAxUSERのビット幅）は異なります。   
詳細は ```ARSHARE_TYPE``` または ```AWSHARE_TYPE``` を参照してください。

#### READ/WRITE ENABLE

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
| ```READ_ENABLE```     | ACP READ ADAPTER ENABLE    |  0-1  |    1    |
| ```WRITE_ENABLE```    | ACP WRITE ADAPTER ENABLE   |  0-1  |    1    |

### READ

#### READ CACHE

これらのパラメータは、ACP_ARCACHE 信号の生成を制御します。  
キャッシュ・コヒーレンシー転送を行うためには、ACP_ARCACHE は "1111" または "1110" を出力しなければなりません。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```ARCACHE_OVERLAY```  | ACP_ARCACHE OVERLAY MASK   |  0-15 |    0    |
|```ARCACHE_VALUE```    | ACP_ARCACHE OVERLAY VALUE  |  0-15 |   15    |


これらのパラメータによって、以下のようにエンコードされた値を ACP_ARCACHE に出力します。

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

```ARCACHE_OVERLAY``` が 0 の場合、AXI_ARCACHE 信号は ACP_ARCACHE に直接出力されます。   
```ARCACHE_OVERLAY``` が 15 の場合、AXI_ARCACHE 信号は使用されず、```ARCACHE_VALUE``` の値が出力されます。

#### READ PROT

これらのパラメータは、ACP_ARPROT 信号の生成を制御します。   
キャッシュ・コヒーレンシー転送を行うためには、ACP_ARCPROT は "010" を出力しなければなりません。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```ARPROT_OVERLAY```   | ACP_ARPROT OVERLAY MASK    |  0-7  |    0    |
|```ARPROT_VALUE```     | ACP_ARPROT OVERLAY VALUE   |  0-7  |    2    |

これらのパラメータによって、以下のようにエンコードされた値を ACP_ARPROT に出力します。

```VHDL
     constant prot_mask  :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(ARPROT_OVERLAY, 3));
     constant prot_value :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(ARPROT_VALUE  , 3));
    
     ACP_ARPROT(0) <= prot_value(0) when (prot_mask(0) = '1') else AXI_ARPROT(0);
     ACP_ARPROT(1) <= prot_value(1) when (prot_mask(1) = '1') else AXI_ARPROT(1);
     ACP_ARPROT(2) <= prot_value(2) when (prot_mask(2) = '1') else AXI_ARPROT(2);
```

```ARPROT_OVERLAY``` が 0 の場合、AXI_ARPROT 信号は ACP_ARPROT に直接出力されます。   
```ARPROT_OVERLAY``` が 7 の場合、AXI_ARPROT 信号は使用されず、```ARPROT_VALUE``` の値が出力されます。

#### READ SHARE

これらのパラメータは、ACP_ARUSER 信号の生成を制御します。   

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```ARSHARE_TYPE```     | ACP READ SHARE TYPE        |  0-6  |    0    |


これらのパラメータによって、以下のようにエンコードされた値を ACP_ARUSER に出力します。

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


#### READ REGS

これらのパラメータは、内部レジスタの有無を設定します。詳細はソース・コードを参照してください。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```RRESP_QUEUE_SIZE``` | READ RESPONSE QUEUE SIZE   |  1-8  |    2    |
|```RDATA_QUEUE_SIZE``` | READ DATA QUEUE SIZE       |  1-4  |    2    |
|```RDATA_INTAKE_REGS```| READ DATA INTAKE REGISTER  |  0-1  |    0    |

### WRITE

#### WRITE CACHE

これらのパラメータは、ACP_AWCACHE 信号の生成を制御します。  
キャッシュ・コヒーレンシー転送を行うためには、ACP_AWCACHE は "1111" または "1110" を出力しなければなりません。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AWCACHE_OVERLAY```  | ACP_AWCACHE OVERLAY MASK   |  0-15 |    0    |
|```AWCACHE_VALUE```    | ACP_AWCACHE OVERLAY VALUE  |  0-15 |   15    |

これらのパラメータによって、以下のようにエンコードされた値を ACP_AWCACHE に出力します。

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

```AWCACHE_OVERLAY``` が 0 の場合、AXI_AWCACHE 信号は ACP_AWCACHE に直接出力されます。   
```AWCACHE_OVERLAY``` が 15 の場合、AXI_AWCACHE 信号は使用されず、```AWCACHE_VALUE``` の値が出力されます。

#### WRITE PROT

これらのパラメータは、ACP_AWPROT 信号の生成を制御します。   
キャッシュ・コヒーレンシー転送を行うためには、ACP_AWCPROT は "010" を出力しなければなりません。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AWPROT_OVERLAY```   | ACP_AWPROT OVERLAY MASK    |  0-7  |    0    |
|```AWPROT_VALUE```     | ACP_AWPROT OVERLAY VALUE   |  0-7  |    2    |

これらのパラメータによって、以下のようにエンコードされた値を ACP_AWPROT に出力します。

```VHDL
     constant prot_mask  :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(AWPROT_OVERLAY, 3));
     constant prot_value :  std_logic_vector(2 downto 0) 
                         := std_logic_vector(to_unsigned(AWPROT_VALUE  , 3));
    
     ACP_AWPROT(0) <= prot_value(0) when (prot_mask(0) = '1') else AXI_AWPROT(0);
     ACP_AWPROT(1) <= prot_value(1) when (prot_mask(1) = '1') else AXI_AWPROT(1);
     ACP_AWPROT(2) <= prot_value(2) when (prot_mask(2) = '1') else AXI_AWPROT(2);
```

```AWPROT_OVERLAY``` が 0 の場合、AXI_AWPROT 信号は ACP_AWPROT に直接出力されます。   
```AWPROT_OVERLAY``` が 7 の場合、AXI_AWPROT 信号は使用されず、```AWPROT_VALUE``` の値が出力されます。

#### WRITE SHARE

これらのパラメータは、ACP_AWUSER 信号の生成を制御します。   

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```AWSHARE_TYPE```     | ACP WRITE SHARE TYPE       |  0-6  |    0    |

これらのパラメータによって、以下のようにエンコードされた値を ACP_AWUSER に出力します。

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

#### WRITE REGS

これらのパラメータは、内部レジスタの有無を設定します。詳細はソース・コードを参照してください。

| Name                  | Discription                | Range | Default |
|:----------------------|:---------------------------|------:|--------:|
|```WRESP_QUEUE_SIZE``` | WRITE RESPONSE QUEUE SIZE  |  1-8  |    2    |
|```WDATA_QUEUE_SIZE``` | WRITE DATA QUEUE SIZE      |  4-32 |   16    |
|```WDATA_OUTLET_REGS```| WRITE DATA OUTLET REGSITER |  0-8  |    5    |
|```WDATA_INTAKE_REGS```| WRITE DATA INTAKE REGSITER |  0-1  |    0    |


# ZynqMP ACP アダプタの構造



## リードアダプタの構造


ZynqMP ACP リードアダプタは AXI からのリードトランザクション要求を ACPに対して中継します。その際、ACP の制限事項であるトランザクションに分割します。リードトランザクションの中継はライトトランザクションの中継と異なり、比較的簡単に行えます。

下図に ZynqMP ACP リードアダプタの構造を示します。


![Fig.4 リードアダプタの構造](./doc/fig04.jpg "Fig.4 リードアダプタの構造")

Fig.4 リードアダプタの構造

<br />

FSM (Finite State Machine 有限状態機械) は、リードアダプタ全体の制御を行います。具体的には、AXI からのリードトランザクション要求信号(AXI_RVALID信号)を受け取り、AXI_ARADDR 信号のアドレス情報と AXI_ARLEN 信号のバースト長信号から ACP へのトランザクション単位に分割して ACP_ARADDR 信号と ACP_ARLEN 信号を生成して、ACP に対してリードトランザクションを要求します(ACP_ARVALID 信号を High にします)。

ACP へのリードトランザクション要求が受け付けられる(ACP_ARREADY 信号がHigh になる) と、その旨をレスポンスキューに通知します。レスポンスキューは ACP が受け付けたリードトランザクションの数をカウントして、リードデータパスに通知します。

リードデータパスは、レスポンスキューからトランザクションの数を受け取り、ACP からのリードデータ数(ACP_RLASTがHighになった数)を数えて、最後のデータの時にAXI_RLAST 信号を High にします。


## ライトアダプタの構造


ZynqMP ACP ライトアダプタは AXI からのライトトランザクション要求を ACPに対して中継します。その際、ACP の制限事項であるトランザクションに分割します。

下図に ZynqMP ACP ライトアダプタの構造を示します。


![Fig.5 ライトアダプタの構造](./doc/fig05.jpg "Fig.5 ライトアダプタの構造")

Fig.5 ライトアダプタの構造

<br />



ライトアダプタはリードアダプタに比べて少しだけ複雑です。何故なら、AXI の仕様上、AXI_WLEN信号によるバースト長だけでは正味のデータ転送量がわからないからです。(私見ですが、私はこれがAXI の最大の欠点だと思ってます。）というのも、AXI のライトデータチャネルには WSTRB 信号というのがあって、このWSTRB 信号は WDATA 信号と供に送られてきて、WDATA 信号のどのバイトレーンが有効かを示します。この WSTRB 信号を受け取って初めて正味のデータ転送量が判明します。

ACP は アライメントされた64-byte(APUのキャッシュラインサイズ)単位でアクセスする場合はそのトランザクション中の WSTRB はすべて High でなければなりません。そうでない場合は、64-byte単位でアクセスすることはできず、16-byte(1バースト長)単位でアクセスしなければなりません。

つまり、ACP のトランザクションが 64-Byte(4バースト)になるか16-Byte(1バースト)になるかは、AXI_WSTRB 信号を(最悪の場合)4バースト分ためてからでないと分からないのです。

これは、AXIからACPへのライトトランザクションのレイテンシー(遅延)が最悪４サイクル増加することを意味します。ライトアダプタを使う際は、この点に留意する必要があります。

下図にライトデータパスの構造を示します。


![Fig.6 ライトデータパスの構造](./doc/fig06.jpg "Fig.6 ライトデータパスの構造")

Fig.6 ライトデータパスの構造

<br />



ライトデータパスには、WDATA と WSTRB を格納するための FIFO の他に、WVALID信号とWLAST 信号とWSTRB=0xFFFFであることを示すフラグを格納するためのキューがあります。このキューは先頭の４ワード分の情報が同時に取り出せる構造になっていて、この４ワード分の情報をもとにライトトランザクションのバースト長を決定します。


# タイミング図



## リードタイミングの例


下図に転送開始アドレスが0xXX-XXXX-X024で転送サイズが183Byteの例(Fig.3 の例)でのリードタイミングを示します。


![Fig.7 リードタイミング例](./doc/fig07.jpg "Fig.7 リードタイミング例")

Fig.7 リードタイミング例

<br />


## ライトタイミングの例


下図に転送開始アドレスが0xXX-XXXX-X024で転送サイズが183Byteの例(Fig.3 の例)でのライトタイミングを示します。


![Fig.8 ライトタイミング例](./doc/fig08.jpg "Fig.8 ライトタイミング例")

Fig.8 ライトタイミング例

<br />


## マルチトランザクション


AXI プロトコルには AXI ID トランザクション識別子信号があります。AXI マスターはこの識別信号を使用して、順番に返される必要がある個別のトランザクションを識別できます。特定の AXI ID 値を持つすべてのトランザクションは順序を維持する必要があります。しかし異なる AXI ID 値を持つトランザクションの順序に制限はありません。これは単一の物理的なポートが複数の論理的なポートとして機能するためのものです。

ZynqMP ACP アダプタは、一応、マルチトランザクションに対応しています。同一の AXI ID を持つトランザクションが連続する場合は、前のトランザクションが完了する前に次のトランザクションを発行します。しかし、別々の AXI ID を持つトランザクションが連続する場合は、前のトランザクションが完了してから次のトランザクションを発行します。


![Fig.9 マルチトランザクション(同一ID)の例](./doc/fig09.jpg "Fig.9 マルチトランザクション(同一ID)の例")

Fig.9 マルチトランザクション(同一ID)の例

<br />


![Fig.10 マルチトランザクション(別ID)の例](./doc/fig10.jpg "Fig.10 マルチトランザクション(別ID)の例")

Fig.10 マルチトランザクション(別ID)の例

<br />



別々の AXI ID を持つトランザクションが連続する場合に前のトランザクションが完了を待ってから次のトランザクションを発行する理由は、次の図のように前のトランザクションの最中に次のトランザクションが割り込んでくる可能性があるからです。トランザクション毎に別々のバッファを持てばこのような場合に対処することが出来ます。しかし、トランザクション毎にバッファを持つのはリソース上の負担が大きいと判断して、その代わりにトランザクションの完了を待つ実装にしています。


![Fig.11 マルチトランザクション(別ID)で困ったことが起こる可能性](./doc/fig11.jpg "Fig.11 マルチトランザクション(別ID)で困ったことが起こる可能性")

Fig.11 マルチトランザクション(別ID)で困ったことが起こる可能性

<br />




# ZynqMP ACP の実測波形



## リードトランザクションの実測波形


リードトランザクション時のZynqMP ACP アダプタの AXI 側と ACP 側の波形を Integrated Logic Analyzer (ILA) で実測した結果を下図に示します。


![Fig.12 ZynqMP ACP のリードトランザクション実測波形](./doc/fig12.png "Fig.12 ZynqMP ACP のリードトランザクション実測波形")

Fig.12 ZynqMP ACP のリードトランザクション実測波形

<br />



この波形は、AXI 側からのAddr=0x00_7010_6400、バースト長=160ワードのリードトランザクションを ZynqMP ACP アダプタが ZynqMP の ACP に対して４ワード×40回のリードトランザクションに分割して発行しているところを計測したものです。（周波数は250MHzです。）

この波形より、ZynqMP ACP はリードトランザクション要求(ACP_ARVALID=1 and ACP_ARREADY=1) から 8クロック後に最初のリードデータが出力された後、ノーウェイトで残りのワードのリードデータが出力されていることがわかります。

AXI 側のリードトランザクションは172クロックで完了しています。160ワード分(2560Byte)のリードトランザクションが688nsec(4nsec×172clock)で完了していることから、転送レートはおよそ3.7GByte/sec であることがわかります。


## ライトトランザクションの実測波形


ライトトランザクション時のZynqMP ACP アダプタの AXI 側と ACP 側の波形を Integrated Logic Analyzer (ILA) で実測した結果を下図に示します。


![Fig.13 ZynqMP ACP のライトトランザクション実測波形](./doc/fig13.png "Fig.13 ZynqMP ACP のライトトランザクション実測波形")

Fig.13 ZynqMP ACP のライトトランザクション実測波形

<br />



この波形は、AXI 側からのAddr=0x00_7050_C800、バースト長=128ワードのライトトランザクションと Addr=0x00_7050_D000、バースト長256ワードのライトトランザクションを連続で行い、それらを ZynqMP ACP アダプタが ZynqMP の ACP に対して４ワード×96回(32回+64回)のライトトランザクションとに分割して発行しているところを計測したものです。（周波数は250MHzです。）

この波形で注目すべき点は、ZynqMP の ACP から出力されている ACP_WREADY 信号のパターンです。ACP_WREADY 信号は ZynqMP の ACP がライトデータを受け付けることが出来るときは1 に、受け付けられないときは 0 になります。この波形を見る限り、ACP_WREADY 信号は 4ワードのデータを受け取った後(ACP_WREADY=1になった後)、6クロックのウェイト(ACP_WREADY=0)が入っています。したがって、ライトトランザクションの転送レートは1.6GByte/sec にとどまっています。


# 参考


*  https://github.com/ikwzm/ZynqMP-ACP-Adapter
*  [『UltraZed 向け Debian GNU/Linux で AXI HPC port を使う (基礎編)』 @Qiita](https://qiita.com/ikwzm/items/82f98bfa76922073e610)
