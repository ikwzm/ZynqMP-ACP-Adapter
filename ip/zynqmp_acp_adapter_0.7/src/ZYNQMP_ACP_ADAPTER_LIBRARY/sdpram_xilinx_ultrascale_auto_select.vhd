-----------------------------------------------------------------------------------
--!     @file    sdpram_xilinx_ultrascale_auto_select.vhd
--!     @brief   Synchronous Dual Port RAM Model for Xilinx UltraScale FPGA.
--!     @version 1.8.0
--!     @date    2019/3/28
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library unisim;
architecture XILINX_ULTRASCALE_AUTO_SELECT of SDPRAM is
    -------------------------------------------------------------------------------
    -- 各種設定用レコードタイプの宣言
    -------------------------------------------------------------------------------
    type        RAM_INFO_TYPE   is record
                AddrBits        : integer;  -- アドレスのビット幅
                WriteEnaWidth   : integer;  -- 書き込み側のイネーブル信号のビット幅を２のべき乗で示した値
                WriteDataWidth  : integer;  -- 書き込み側のデータのビット幅を２のべき乗で示した値
                ReadDataWidth   : integer;  -- 読み出し側のデータのビット幅を２のべき乗で示した値
    end record;
    -------------------------------------------------------------------------------
    -- 使用するメモリの種類を選択するための関数
    -------------------------------------------------------------------------------
    function    SELECT_RAM_TYPE return RAM_INFO_TYPE is
        variable info  : RAM_INFO_TYPE;
    begin
        ---------------------------------------------------------------------------
        -- D=  1bit Q=  1bit DEPTH<=32word(  4byte,  32bit) RAM32X1D*  1
        -- D=  2bit Q=  2bit DEPTH<=32word(  8byte,  64bit) RAM32X1D*  2
        -- D=  4bit Q=  4bit DEPTH<=32word( 16byte, 128bit) RAM32X1D*  4
        -- D=  8bit Q=  8bit DEPTH<=32word( 32byte, 256bit) RAM32X1D*  8
        -- D= 16bit Q= 16bit DEPTH<=32word( 64byte, 512bit) RAM32X1D* 16
        -- D= 32bit Q= 32bit DEPTH<=32word(128byte,1024bit) RAM32X1D* 32
        ---------------------------------------------------------------------------
        if (DEPTH - WWIDTH <= 5 and RWIDTH = WWIDTH) then
            info.AddrBits       := 5;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- D=  1bit Q=  1bit DEPTH<=64word(  8byte,  64bit) RAM64X1D*  1
        -- D=  2bit Q=  2bit DEPTH<=64word( 16byte, 128bit) RAM64X1D*  2
        -- D=  4bit Q=  4bit DEPTH<=64word( 32byte, 256bit) RAM64X1D*  4
        -- D=  8bit Q=  8bit DEPTH<=64word( 64byte, 512bit) RAM64X1D*  8
        -- D= 16bit Q= 16bit DEPTH<=64word(128byte,1024bit) RAM64X1D* 16
        -- D= 32bit Q= 32bit DEPTH<=64word(256byte,2048bit) RAM64X1D* 32
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 6 and RWIDTH = WWIDTH) then
            info.AddrBits       := 6;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- D=  1bit Q=  1bit DEPTH<=128word( 16byte, 128bit) RAM128X1D*  1
        -- D=  2bit Q=  2bit DEPTH<=128word( 32byte, 256bit) RAM128X1D*  2
        -- D=  4bit Q=  4bit DEPTH<=128word( 64byte, 512bit) RAM128X1D*  4
        -- D=  8bit Q=  8bit DEPTH<=128word(128byte,1024bit) RAM128X1D*  8
        -- D= 16bit Q= 16bit DEPTH<=128word(256byte,2048bit) RAM128X1D* 16
        -- D= 32bit Q= 32bit DEPTH<=128word(512byte,4096bit) RAM128X1D* 32
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 7 and RWIDTH = WWIDTH) then
            info.AddrBits       := 7;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- D=  1bit Q=  1bit DEPTH<=256word( 32byte, 256bit) RAM256X1D*  1
        -- D=  2bit Q=  2bit DEPTH<=256word( 64byte, 512bit) RAM256X1D*  2
        -- D=  4bit Q=  4bit DEPTH<=256word(128byte,1024bit) RAM256X1D*  4
        -- D=  8bit Q=  8bit DEPTH<=256word(256byte,2048bit) RAM256X1D*  8
        -- D= 16bit Q= 16bit DEPTH<=256word(512byte,4096bit) RAM256X1D* 16
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 8 and RWIDTH = WWIDTH) then
            info.AddrBits       := 8;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- D= 64bit WE<= 8bit Q= 64bit DEPTH<=512word( 4Kbyte, 32Kbit) RAMB32E1* 1
        -- D=128bit WE<=16bit Q=128bit DEPTH<=512word( 8Kbyte, 64kbit) RAMB32E1* 2
        -- D=256bit WE<=32bit Q=256bit DEPTH<=512word(16Kbyte,128kbit) RAMB32E1* 4
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <=  9 and WWIDTH >= 6 and WWIDTH - WEBIT >= 3 and RWIDTH = WWIDTH) then 
            info.AddrBits       := 15;
            info.WriteEnaWidth  := 3;
            info.WriteDataWidth := 6;
            info.ReadDataWidth  := 6;
        ---------------------------------------------------------------------------
        -- D= 32bit WE<=1bit Q= 32bit DEPTH<=512word( 2Kbyte, 16Kbit) RAMB16_S36_S36* 1
        -- D= 64bit WE<=2bit Q= 64bit DEPTH<=512word( 4Kbyte, 32kbit) RAMB16_S36_S36* 2
        -- D=128bit WE<=4bit Q=128bit DEPTH<=512word( 8Kbyte, 64kbit) RAMB16_S36_S36* 4
        -- D=256bit WE<=8bit Q=256bit DEPTH<=512word(16Kbyte,128kbit) RAMB16_S36_S36* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <=  9 and WWIDTH - WEBIT >= 5 and RWIDTH = WWIDTH) then 
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 5;
            info.ReadDataWidth  := 5;
        --------------------------------------------------------------------------
        -- D= 16bit WE<=1bit Q= 16bit DEPTH<= 1Kword( 2Kbyte, 16Kbit) RAMB16_S18_S18* 1
        -- D= 32bit WE<=2bit Q= 32bit DEPTH<= 1Kword( 4Kbyte, 32Kbit) RAMB16_S18_S18* 2
        -- D= 64bit WE<=4bit Q= 64bit DEPTH<= 1Kword( 8Kbyte, 64kbit) RAMB16_S18_S18* 4
        -- D=128bit WE<=8bit Q=128bit DEPTH<= 1Kword(16Kbyte,128kbit) RAMB16_S18_S18* 8
        --------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 10 and WWIDTH - WEBIT >= 4 and RWIDTH = WWIDTH) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 4;
            info.ReadDataWidth  := 4;
        --------------------------------------------------------------------------
        -- D=  8bit WE<=1bit Q=  8bit DEPTH<= 2Kword( 2Kbyte, 16Kbit) RAMB16_S9_S9  * 1
        -- D= 16bit WE<=2bit Q= 16bit DEPTH<= 2Kword( 4Kbyte, 32Kbit) RAMB16_S9_S9  * 2
        -- D= 32bit WE<=4bit Q= 32bit DEPTH<= 2Kword( 8Kbyte, 64Kbit) RAMB16_S9_S9  * 4
        -- D= 64bit WE<=8bit Q= 64bit DEPTH<= 2Kword(16Kbyte,128kbit) RAMB16_S9_S9  * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 11 and WWIDTH - WEBIT >= 3 and RWIDTH = WWIDTH) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 3;
            info.ReadDataWidth  := 3;
        --------------------------------------------------------------------------
        -- D=  4bit WE<=1bit Q=  4bit DEPTH<= 4Kword( 2Kbyte, 16Kbit) RAMB16_S4_S4  * 1
        -- D=  8bit WE<=2bit Q=  8bit DEPTH<= 4Kword( 4Kbyte, 32Kbit) RAMB16_S4_S4  * 2
        -- D= 16bit WE<=4bit Q= 16bit DEPTH<= 4Kword( 8Kbyte, 64Kbit) RAMB16_S4_S4  * 4
        -- D= 32bit WE<=8bit Q= 32bit DEPTH<= 4Kword(16Kbyte,128Kbit) RAMB16_S4_S4  * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 12 and WWIDTH - WEBIT >= 2 and RWIDTH = WWIDTH) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 2;
            info.ReadDataWidth  := 2;
        --------------------------------------------------------------------------
        -- D=  2bit WE<=1bit Q=  2bit DEPTH<= 8Kword( 2Kbyte, 16Kbit) RAMB16_S2_S2  * 1
        -- D=  4bit WE<=2bit Q=  4bit DEPTH<= 8Kword( 4Kbyte, 32Kbit) RAMB16_S2_S2  * 2
        -- D=  8bit WE<=4bit Q=  8bit DEPTH<= 8Kword( 8Kbyte, 64Kbit) RAMB16_S2_S2  * 4
        -- D= 16bit WE<=8bit Q= 16bit DEPTH<= 8Kword(16Kbyte,128Kbit) RAMB16_S2_S2  * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 13 and WWIDTH - WEBIT >= 1 and RWIDTH = WWIDTH) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 1;
            info.ReadDataWidth  := 1;
        --------------------------------------------------------------------------
        -- D=  1bit WE<=1bit Q=  1bit DEPTH<=16Kword( 2Kbyte, 16Kbit) RAMB16_S1_S1  * 1
        -- D=  2bit WE<=2bit Q=  2bit DEPTH<=16Kword( 4Kbyte, 32Kbit) RAMB16_S1_S1  * 2
        -- D=  4bit WE<=4bit Q=  4bit DEPTH<=16Kword( 8Kbyte, 64Kbit) RAMB16_S1_S1  * 4
        -- D=  8bit WE<=8bit Q=  8bit DEPTH<=16Kword( 4Kbyte,128Kbit) RAMB16_S1_S1  * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 14 and WWIDTH - WEBIT >= 0 and RWIDTH = WWIDTH) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- D= 16bit WE<=1bit Q= 32bit DEPTH<= 1Kword( 2Kbyte, 16Kbit) RAMB16_S36_S18* 1
        -- D= 32bit WE<=2bit Q= 64bit DEPTH<= 1Kword( 4Kbyte, 32Kbit) RAMB16_S36_S18* 2
        -- D= 64bit WE<=4bit Q=128bit DEPTH<= 1Kword( 8Kbyte, 64kbit) RAMB16_S36_S18* 4
        -- D=128bit WE<=8bit Q=256bit DEPTH<= 1Kword(16Kbyte,128kbit) RAMB16_S36_S18* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 10 and WWIDTH - WEBIT >= 4 and RWIDTH = WWIDTH+1) then 
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 4;
            info.ReadDataWidth  := 5;
        ---------------------------------------------------------------------------
        -- D=  8bit WE<=1bit Q= 16bit DEPTH<= 2Kword( 2Kbyte, 16Kbit) RAMB16_S18_S9 * 1
        -- D= 16bit WE<=2bit Q= 32bit DEPTH<= 2Kword( 4Kbyte, 32Kbit) RAMB16_S18_S9 * 2
        -- D= 32bit WE<=4bit Q= 64bit DEPTH<= 2Kword( 8Kbyte, 64Kbit) RAMB16_S18_S9 * 4
        -- D= 64bit WE<=8bit Q=128bit DEPTH<= 2Kword(16Kbyte,128kbit) RAMB16_S18_S9 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 11 and WWIDTH - WEBIT >= 3 and RWIDTH = WWIDTH+1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 3;
            info.ReadDataWidth  := 4;
        ---------------------------------------------------------------------------
        -- D=  4bit WE<=1bit Q=  8bit DEPTH<= 4Kword( 2Kbyte, 16Kbit) RAMB16_S4_S9 * 1
        -- D=  8bit WE<=2bit Q= 16bit DEPTH<= 4Kword( 4Kbyte, 32Kbit) RAMB16_S4_S9 * 2
        -- D= 16bit WE<=4bit Q= 32bit DEPTH<= 4Kword( 8Kbyte, 64Kbit) RAMB16_S4_S9 * 4
        -- D= 32bit WE<=8bit Q= 64bit DEPTH<= 4Kword(16Kbyte,128Kbit) RAMB16_S4_S9 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 12 and WWIDTH - WEBIT >= 2 and RWIDTH = WWIDTH+1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 2;
            info.ReadDataWidth  := 3;
        ---------------------------------------------------------------------------
        -- D=  2bit WE<=1bit Q=  4bit DEPTH<= 8Kword( 2Kbyte, 16Kbit) RAMB16_S2_S4 * 1
        -- D=  4bit WE<=2bit Q=  8bit DEPTH<= 8Kword( 4Kbyte, 32Kbit) RAMB16_S2_S4 * 2
        -- D=  8bit WE<=4bit Q= 16bit DEPTH<= 8Kword( 8Kbyte, 64Kbit) RAMB16_S2_S4 * 4
        -- D= 16bit WE<=8bit Q= 32bit DEPTH<= 8Kword(16Kbyte,128Kbit) RAMB16_S2_S4 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 13 and WWIDTH - WEBIT >= 1 and RWIDTH = WWIDTH+1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 1;
            info.ReadDataWidth  := 2;
        ---------------------------------------------------------------------------
        -- D=  1bit WE<=1bit Q=  2bit DEPTH<=16Kword( 2Kbyte, 16Kbit) RAMB16_S1_S2 * 1
        -- D=  2bit WE<=2bit Q=  4bit DEPTH<=16Kword( 4Kbyte, 32Kbit) RAMB16_S1_S2 * 2
        -- D=  4bit WE<=4bit Q=  8bit DEPTH<=16Kword( 8Kbyte, 64Kbit) RAMB16_S1_S2 * 4
        -- D=  8bit WE<=8bit Q= 16bit DEPTH<=16Kword(16Kbyte,128Kbit) RAMB16_S1_S2 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 14 and WWIDTH - WEBIT >= 0 and RWIDTH = WWIDTH+1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 1;
        ---------------------------------------------------------------------------
        -- D=  8bit WE<=1bit Q= 32bit DEPTH<= 2Kword( 2Kbyte, 16Kbit) RAMB16_S9_S36 * 1
        -- D= 16bit WE<=2bit Q= 64bit DEPTH<= 2Kword( 4Kbyte, 32Kbit) RAMB16_S9_S36 * 2
        -- D= 32bit WE<=4bit Q=128bit DEPTH<= 2Kword( 8Kbyte, 64Kbit) RAMB16_S9_S36 * 4
        -- D= 64bit WE<=8bit Q=256bit DEPTH<= 2Kword(16Kbyte,128kbit) RAMB16_S9_S36 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 11 and WWIDTH - WEBIT >= 3 and RWIDTH = WWIDTH+2) then 
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 3;
            info.ReadDataWidth  := 5;
        ---------------------------------------------------------------------------
        -- D=  4bit WE<=1bit Q= 16bit DEPTH<= 4Kword( 2Kbyte, 16Kbit) RAMB16_S4_S18 * 1
        -- D=  8bit WE<=2bit Q= 32bit DEPTH<= 4Kword( 4Kbyte, 32Kbit) RAMB16_S4_S18 * 2
        -- D= 16bit WE<=4bit Q= 64bit DEPTH<= 4Kword( 8Kbyte, 64Kbit) RAMB16_S4_S18 * 4
        -- D= 32bit WE<=8bit Q=128bit DEPTH<= 4Kword(16Kbyte,128Kbit) RAMB16_S4_S18 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 12 and WWIDTH - WEBIT >= 2 and RWIDTH = WWIDTH+2) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 2;
            info.ReadDataWidth  := 4;
        ---------------------------------------------------------------------------
        -- D=  2bit WE<=1bit Q=  8bit DEPTH<= 8Kword( 2Kbyte, 16Kbit) RAMB16_S2_S9 * 1
        -- D=  4bit WE<=2bit Q= 16bit DEPTH<= 8Kword( 4Kbyte, 32Kbit) RAMB16_S2_S9 * 2
        -- D=  8bit WE<=4bit Q= 32bit DEPTH<= 8Kword( 8Kbyte, 64Kbit) RAMB16_S2_S9 * 4
        -- D= 16bit WE<=8bit Q= 64bit DEPTH<= 8Kword(16Kbyte,128Kbit) RAMB16_S2_S9 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 13 and WWIDTH - WEBIT >= 1 and RWIDTH = WWIDTH+2) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 1;
            info.ReadDataWidth  := 3;
        ---------------------------------------------------------------------------
        -- D=  1bit WE<=1bit Q=  4bit DEPTH<=16Kword( 2Kbyte, 16Kbit) RAMB16_S1_S4 * 1
        -- D=  2bit WE<=2bit Q=  8bit DEPTH<=16Kword( 4Kbyte, 32Kbit) RAMB16_S1_S4 * 2
        -- D=  4bit WE<=4bit Q= 16bit DEPTH<=16Kword( 8Kbyte, 64Kbit) RAMB16_S1_S4 * 4
        -- D=  8bit WE<=8bit Q= 32bit DEPTH<=16Kword(16Kbyte,128Kbit) RAMB16_S1_S4 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 14 and WWIDTH - WEBIT >= 0 and RWIDTH = WWIDTH+2) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 2;
        ---------------------------------------------------------------------------
        -- D= 32bit WE=1bit Q= 16bit DEPTH<=512word( 2Kbyte, 16Kbit) RAMB16_S18_S36* 1
        -- D= 64bit WE=1bit Q= 32bit DEPTH<=512word( 4Kbyte, 32kbit) RAMB16_S18_S36* 2
        -- D=128bit WE=1bit Q= 64bit DEPTH<=512word( 8Kbyte, 64kbit) RAMB16_S18_S36* 4
        -- D=256bit WE=1bit Q=128bit DEPTH<=512word(16Kbyte,128kbit) RAMB16_S18_S36* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <=  9 and WWIDTH >= 5 and WEBIT = 0 and RWIDTH = WWIDTH-1) then 
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 5;
            info.ReadDataWidth  := 4;
        ---------------------------------------------------------------------------
        -- D= 16bit WE=1bit Q=  8bit DEPTH<= 1Kword( 2Kbyte, 16Kbit) RAMB16_S9_S18* 1
        -- D= 32bit WE=1bit Q= 16bit DEPTH<= 1Kword( 4Kbyte, 32kbit) RAMB16_S9_S18* 2
        -- D= 64bit WE=1bit Q= 32bit DEPTH<= 1Kword( 8Kbyte, 64kbit) RAMB16_S9_S18* 4
        -- D=128bit WE=1bit Q= 64bit DEPTH<= 1Kword(16Kbyte,128kbit) RAMB16_S9_S18* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 10 and WWIDTH >= 4 and WEBIT = 0 and RWIDTH = WWIDTH-1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 4;
            info.ReadDataWidth  := 3;
        ---------------------------------------------------------------------------
        -- D=  8bit WE=1bit Q=  4bit DEPTH<= 2Kword( 2Kbyte, 16Kbit) RAMB16_S4_S9 * 1
        -- D= 16bit WE=1bit Q=  8bit DEPTH<= 2Kword( 4Kbyte, 32kbit) RAMB16_S4_S9 * 2
        -- D= 32bit WE=1bit Q= 16bit DEPTH<= 2Kword( 8Kbyte, 64kbit) RAMB16_S4_S9 * 4
        -- D= 64bit WE=1bit Q= 32bit DEPTH<= 2Kword(16Kbyte,128kbit) RAMB16_S4_S9 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 11 and WWIDTH >= 3 and WEBIT = 0 and RWIDTH = WWIDTH-1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 3;
            info.ReadDataWidth  := 2;
        ---------------------------------------------------------------------------
        -- D=  4bit WE=1bit Q=  2bit DEPTH<= 4Kword( 2Kbyte, 16Kbit) RAMB16_S2_S4 * 1
        -- D=  8bit WE=1bit Q=  4bit DEPTH<= 4Kword( 4Kbyte, 32kbit) RAMB16_S2_S4 * 2
        -- D= 16bit WE=1bit Q=  8bit DEPTH<= 4Kword( 8Kbyte, 64kbit) RAMB16_S2_S4 * 4
        -- D= 32bit WE=1bit Q= 16bit DEPTH<= 4Kword(16Kbyte,128kbit) RAMB16_S2_S4 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 12 and WWIDTH >= 2 and WEBIT = 0 and RWIDTH = WWIDTH-1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 2;
            info.ReadDataWidth  := 1;
        ---------------------------------------------------------------------------
        -- D=  2bit WE=1bit Q=  1bit DEPTH<= 8Kword( 2Kbyte, 16Kbit) RAMB16_S1_S2 * 1
        -- D=  4bit WE=1bit Q=  2bit DEPTH<= 8Kword( 4Kbyte, 32kbit) RAMB16_S1_S2 * 2
        -- D=  8bit WE=1bit Q=  4bit DEPTH<= 8Kword( 8Kbyte, 64kbit) RAMB16_S1_S2 * 4
        -- D= 16bit WE=1bit Q=  8bit DEPTH<= 8Kword(16Kbyte,128kbit) RAMB16_S1_S2 * 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 13 and WWIDTH >= 1 and WEBIT = 0 and RWIDTH = WWIDTH-1) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 1;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- D= 32bit WE=1bit Q=  8bit DEPTH<=512word( 2Kbyte, 16Kbit) RAMB16_S9_S36* 1
        -- D= 64bit WE=1bit Q= 16bit DEPTH<=512word( 4Kbyte, 32kbit) RAMB16_S9_S36* 2
        -- D=128bit WE=1bit Q= 32bit DEPTH<=512word( 8Kbyte, 64kbit) RAMB16_S9_S36* 4
        -- D=256bit WE=1bit Q= 64bit DEPTH<=512word(16Kbyte,128kbit) RAMB16_S9_S36* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <=  9 and WWIDTH >= 5 and WEBIT = 0 and RWIDTH = WWIDTH-2) then 
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 5;
            info.ReadDataWidth  := 3;
        ---------------------------------------------------------------------------
        -- D= 16bit WE=1bit Q=  4bit DEPTH<= 1Kword( 2Kbyte, 16Kbit) RAMB16_S4_S18* 1
        -- D= 32bit WE=1bit Q=  8bit DEPTH<= 1Kword( 4Kbyte, 32kbit) RAMB16_S4_S18* 2
        -- D= 64bit WE=1bit Q= 16bit DEPTH<= 1Kword( 8Kbyte, 64kbit) RAMB16_S4_S18* 4
        -- D=128bit WE=1bit Q= 32bit DEPTH<= 1Kword(16Kbyte,128kbit) RAMB16_S4_S18* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 10 and WWIDTH >= 4 and WEBIT = 0 and RWIDTH = WWIDTH-2) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 4;
            info.ReadDataWidth  := 2;
        ---------------------------------------------------------------------------
        -- D=  8bit WE=1bit Q=  2bit DEPTH<= 2Kword( 2Kbyte, 16Kbit) RAMB16_S2_S9* 1
        -- D= 16bit WE=1bit Q=  4bit DEPTH<= 2Kword( 4Kbyte, 32kbit) RAMB16_S2_S9* 2
        -- D= 32bit WE=1bit Q=  8bit DEPTH<= 2Kword( 8Kbyte, 64kbit) RAMB16_S2_S9* 4
        -- D= 64bit WE=1bit Q= 16bit DEPTH<= 2Kword(16Kbyte,128kbit) RAMB16_S2_S9* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 11 and WWIDTH >= 3 and WEBIT = 0 and RWIDTH = WWIDTH-2) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 3;
            info.ReadDataWidth  := 1;
        ---------------------------------------------------------------------------
        -- D=  4bit WE=1bit Q=  1bit DEPTH<= 4Kword( 2Kbyte, 16Kbit) RAMB16_S1_S4* 1
        -- D=  8bit WE=1bit Q=  2bit DEPTH<= 4Kword( 4Kbyte, 32kbit) RAMB16_S1_S4* 2
        -- D= 16bit WE=1bit Q=  4bit DEPTH<= 4Kword( 8Kbyte, 64kbit) RAMB16_S1_S4* 4
        -- D= 32bit WE=1bit Q=  8bit DEPTH<= 4Kword(16Kbyte,128kbit) RAMB16_S1_S4* 8
        ---------------------------------------------------------------------------
        elsif (DEPTH - WWIDTH <= 12 and WWIDTH >= 2 and WEBIT = 0 and RWIDTH = WWIDTH-2) then
            info.AddrBits       := 14;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 2;
            info.ReadDataWidth  := 0;
        ---------------------------------------------------------------------------
        -- 未サポート
        ---------------------------------------------------------------------------
        else
            info.AddrBits       := 0;
            info.WriteEnaWidth  := 0;
            info.WriteDataWidth := 0;
            info.ReadDataWidth  := 0;
            --pragma translate_off
            assert (false) report "SDPRAM:unsuported parameter" severity FAILURE;
            --pragma translate_on
        end if;
        return info;
    end function;

    function    MAX(A,B:integer) return integer is begin
        if (A>B) then return A;
        else          return B;
        end if;
    end function;

    -------------------------------------------------------------------------------
    -- 使用するメモリの各種情報を示す定数の定義
    -------------------------------------------------------------------------------
    constant    RAM_INFO        : RAM_INFO_TYPE := SELECT_RAM_TYPE;
    constant    RAM_ADDR_BITS   : integer       := RAM_INFO.AddrBits;
    constant    RAM_WE_WIDTH    : integer       := RAM_INFO.WriteEnaWidth;
    constant    RAM_WD_WIDTH    : integer       := RAM_INFO.WriteDataWidth;
    constant    RAM_RD_WIDTH    : integer       := RAM_INFO.ReadDataWidth;
    constant    RAM_WA_BITS     : integer       := RAM_ADDR_BITS-RAM_WD_WIDTH;
    constant    RAM_RA_BITS     : integer       := RAM_ADDR_BITS-RAM_RD_WIDTH;
    constant    RAM_WE_BITS     : integer       := 2**RAM_WE_WIDTH;
    constant    RAM_WD_BITS     : integer       := 2**RAM_WD_WIDTH;
    constant    RAM_RD_BITS     : integer       := 2**RAM_RD_WIDTH;
    constant    RAM_WP_BITS     : integer       := (RAM_WD_BITS+7)/8;
    constant    RAM_RP_BITS     : integer       := (RAM_RD_BITS+7)/8;
    constant    RAM_NUM         : integer       := 2**(WWIDTH-RAM_WD_WIDTH);

    -------------------------------------------------------------------------------
    -- 内部信号
    -------------------------------------------------------------------------------
    signal      wptr            : std_logic_vector(RAM_WA_BITS-1 downto 0);
    signal      rptr            : std_logic_vector(RAM_RA_BITS-1 downto 0);
    signal      s1              : std_logic;
    signal      s0              : std_logic;
    signal      dummy           : std_logic_vector(2**RWIDTH-1   downto 0);
    signal      odata           : std_logic_vector(2**RWIDTH-1   downto 0);
    signal      idata           : std_logic_vector(2**WWIDTH-1   downto 0);
    signal      wena            : std_logic_vector(RAM_NUM*RAM_WE_BITS-1 downto 0);
    signal      wpin            : std_logic_vector(RAM_WP_BITS-1 downto 0);
    signal      rpin            : std_logic_vector(RAM_RP_BITS-1 downto 0);

    -------------------------------------------------------------------------------
    -- WWIDTH < RWIDTHの場合の出力データの並び変えを行なう関数の定義
    -------------------------------------------------------------------------------
    function    SWAP_R(D:std_logic_vector;RAM_NUM,WWIDTH,RWIDTH:integer) return std_logic_vector is
        variable O           : std_logic_vector(2**RWIDTH-1 downto 0);
        constant RAM_WD_BITS : integer := (2**(WWIDTH))/RAM_NUM;
        constant RAM_RD_BITS : integer := (2**(RWIDTH))/RAM_NUM;
    begin
        if (RWIDTH > WWIDTH) then
            for i in 0 to 2**(RWIDTH-WWIDTH)-1 loop
                for n in 0 to RAM_NUM-1 loop
                    O((2**WWIDTH)*i+RAM_WD_BITS*(n+1)-1 downto (2**WWIDTH)*i+RAM_WD_BITS*n) := 
                    D(RAM_RD_BITS*n+RAM_WD_BITS*(i+1)-1 downto RAM_RD_BITS*n+RAM_WD_BITS*i);
                end loop;
            end loop;
        else
            O := D;
        end if;
        return O;
    end function;

    -------------------------------------------------------------------------------
    -- WWIDTH > RWIDTHの場合の入力データの並び変えを行なう関数の定義
    -------------------------------------------------------------------------------
    function    SWAP_W(D:std_logic_vector;RAM_NUM,WWIDTH,RWIDTH:integer) return std_logic_vector is
        variable O           : std_logic_vector(2**WWIDTH-1 downto 0);
        constant RAM_WD_BITS : integer := (2**(WWIDTH))/RAM_NUM;
        constant RAM_RD_BITS : integer := (2**(RWIDTH))/RAM_NUM;
    begin
        if (WWIDTH > RWIDTH) then
            for n in 0 to RAM_NUM-1 loop
                for i in 0 to 2**(WWIDTH-RWIDTH)-1 loop
                    O(RAM_WD_BITS*n+RAM_RD_BITS*(i+1)-1 downto RAM_WD_BITS*n+RAM_RD_BITS*i) :=
                    D((2**RWIDTH)*i+RAM_RD_BITS*(n+1)-1 downto (2**RWIDTH)*i+RAM_RD_BITS*n); 
                end loop;
            end loop;
        else
            O := D;
        end if;
        return O;
    end function;

    -------------------------------------------------------------------------------
    -- 各種メモリのコンポーネント宣言
    -------------------------------------------------------------------------------
    component   RAMB16_S36_S36
        generic (
		SIM_COLLISION_CHECK : string := "ALL"
                );
	port
	(
		DOA   : out std_logic_vector(31 downto 0);
		DOB   : out std_logic_vector(31 downto 0);
		DOPA  : out std_logic_vector( 3 downto 0);
		DOPB  : out std_logic_vector( 3 downto 0);
		ADDRA : in  std_logic_vector( 8 downto 0);
		ADDRB : in  std_logic_vector( 8 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector(31 downto 0);
		DIB   : in  std_logic_vector(31 downto 0);
		DIPA  : in  std_logic_vector( 3 downto 0);
		DIPB  : in  std_logic_vector( 3 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component   RAMB16_S18_S18
        generic (
		SIM_COLLISION_CHECK : string := "ALL"
                );
	port
	(
		DOA   : out std_logic_vector(15 downto 0);
		DOB   : out std_logic_vector(15 downto 0);
		DOPA  : out std_logic_vector( 1 downto 0);
		DOPB  : out std_logic_vector( 1 downto 0);
		ADDRA : in  std_logic_vector( 9 downto 0);
		ADDRB : in  std_logic_vector( 9 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector(15 downto 0);
		DIB   : in  std_logic_vector(15 downto 0);
		DIPA  : in  std_logic_vector( 1 downto 0);
		DIPB  : in  std_logic_vector( 1 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component   RAMB16_S9_S9
        generic (
		SIM_COLLISION_CHECK : string := "ALL"
                );
	port
	(
		DOA   : out std_logic_vector( 7 downto 0);
		DOB   : out std_logic_vector( 7 downto 0);
		DOPA  : out std_logic_vector( 0 downto 0);
		DOPB  : out std_logic_vector( 0 downto 0);
		ADDRA : in  std_logic_vector(10 downto 0);
		ADDRB : in  std_logic_vector(10 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 7 downto 0);
		DIB   : in  std_logic_vector( 7 downto 0);
		DIPA  : in  std_logic_vector( 0 downto 0);
		DIPB  : in  std_logic_vector( 0 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component   RAMB16_S4_S4
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector(3 downto 0);
		DOB   : out std_logic_vector(3 downto 0);
		ADDRA : in std_logic_vector(11 downto 0);
		ADDRB : in std_logic_vector(11 downto 0);
		CLKA  : in std_ulogic;
		CLKB  : in std_ulogic;
		DIA   : in std_logic_vector(3 downto 0);
		DIB   : in std_logic_vector(3 downto 0);
		ENA   : in std_ulogic;
		ENB   : in std_ulogic;
		SSRA  : in std_ulogic;
		SSRB  : in std_ulogic;
		WEA   : in std_ulogic;
		WEB   : in std_ulogic
	);
    end component;

    component   RAMB16_S2_S2
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector(1 downto 0);
		DOB   : out std_logic_vector(1 downto 0);
		ADDRA : in std_logic_vector(12 downto 0);
		ADDRB : in std_logic_vector(12 downto 0);
		CLKA  : in std_ulogic;
		CLKB  : in std_ulogic;
		DIA   : in std_logic_vector(1 downto 0);
		DIB   : in std_logic_vector(1 downto 0);
		ENA   : in std_ulogic;
		ENB   : in std_ulogic;
		SSRA  : in std_ulogic;
		SSRB  : in std_ulogic;
		WEA   : in std_ulogic;
		WEB   : in std_ulogic
	);
    end component;

    component   RAMB16_S1_S1
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector(0 downto 0);
		DOB   : out std_logic_vector(0 downto 0);
		ADDRA : in std_logic_vector(13 downto 0);
		ADDRB : in std_logic_vector(13 downto 0);
		CLKA  : in std_ulogic;
		CLKB  : in std_ulogic;
		DIA   : in std_logic_vector(0 downto 0);
		DIB   : in std_logic_vector(0 downto 0);
		ENA   : in std_ulogic;
		ENB   : in std_ulogic;
		SSRA  : in std_ulogic;
		SSRB  : in std_ulogic;
		WEA   : in std_ulogic;
		WEB   : in std_ulogic
	);
    end component;

    component RAMB16_S18_S36
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector(15 downto 0);
		DOB   : out std_logic_vector(31 downto 0);
		DOPA  : out std_logic_vector( 1 downto 0);
		DOPB  : out std_logic_vector( 3 downto 0);
		ADDRA : in  std_logic_vector( 9 downto 0);
		ADDRB : in  std_logic_vector( 8 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector(15 downto 0);
		DIB   : in  std_logic_vector(31 downto 0);
		DIPA  : in  std_logic_vector( 1 downto 0);
		DIPB  : in  std_logic_vector( 3 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S9_S18
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 7 downto 0);
		DOB   : out std_logic_vector(15 downto 0);
		DOPA  : out std_logic_vector( 0 downto 0);
		DOPB  : out std_logic_vector( 1 downto 0);
		ADDRA : in  std_logic_vector(10 downto 0);
		ADDRB : in  std_logic_vector( 9 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 7 downto 0);
		DIB   : in  std_logic_vector(15 downto 0);
		DIPA  : in  std_logic_vector( 0 downto 0);
		DIPB  : in  std_logic_vector( 1 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S4_S9
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 3 downto 0);
		DOB   : out std_logic_vector( 7 downto 0);
		DOPB  : out std_logic_vector( 0 downto 0);
		ADDRA : in  std_logic_vector(11 downto 0);
		ADDRB : in  std_logic_vector(10 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 3 downto 0);
		DIB   : in  std_logic_vector( 7 downto 0);
		DIPB  : in  std_logic_vector( 0 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S2_S4
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 1 downto 0);
		DOB   : out std_logic_vector( 3 downto 0);
		ADDRA : in  std_logic_vector(12 downto 0);
		ADDRB : in  std_logic_vector(11 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 1 downto 0);
		DIB   : in  std_logic_vector( 3 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S1_S2
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 0 downto 0);
		DOB   : out std_logic_vector( 1 downto 0);
		ADDRA : in  std_logic_vector(13 downto 0);
		ADDRB : in  std_logic_vector(12 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 0 downto 0);
		DIB   : in  std_logic_vector( 1 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S9_S36
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 7 downto 0);
		DOB   : out std_logic_vector(31 downto 0);
		DOPA  : out std_logic_vector( 0 downto 0);
		DOPB  : out std_logic_vector( 3 downto 0);
		ADDRA : in  std_logic_vector(10 downto 0);
		ADDRB : in  std_logic_vector( 8 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 7 downto 0);
		DIB   : in  std_logic_vector(31 downto 0);
		DIPA  : in  std_logic_vector( 0 downto 0);
		DIPB  : in  std_logic_vector( 3 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S4_S18
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 3 downto 0);
		DOB   : out std_logic_vector(15 downto 0);
		DOPB  : out std_logic_vector( 1 downto 0);
		ADDRA : in  std_logic_vector(11 downto 0);
		ADDRB : in  std_logic_vector( 9 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 3 downto 0);
		DIB   : in  std_logic_vector(15 downto 0);
		DIPB  : in  std_logic_vector( 1 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S2_S9
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 1 downto 0);
		DOB   : out std_logic_vector( 7 downto 0);
		DOPB  : out std_logic_vector( 0 downto 0);
		ADDRA : in  std_logic_vector(12 downto 0);
		ADDRB : in  std_logic_vector(10 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 1 downto 0);
		DIB   : in  std_logic_vector( 7 downto 0);
		DIPB  : in  std_logic_vector( 0 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component RAMB16_S1_S4
	generic
	(
		SIM_COLLISION_CHECK : string := "ALL"
	);
	port
	(
		DOA   : out std_logic_vector( 0 downto 0);
		DOB   : out std_logic_vector( 3 downto 0);
		ADDRA : in  std_logic_vector(13 downto 0);
		ADDRB : in  std_logic_vector(11 downto 0);
		CLKA  : in  std_ulogic;
		CLKB  : in  std_ulogic;
		DIA   : in  std_logic_vector( 0 downto 0);
		DIB   : in  std_logic_vector( 3 downto 0);
		ENA   : in  std_ulogic;
		ENB   : in  std_ulogic;
		SSRA  : in  std_ulogic;
		SSRB  : in  std_ulogic;
		WEA   : in  std_ulogic;
		WEB   : in  std_ulogic
	);
    end component;

    component   RAM32X1D
	port
	(
		DPO   : out std_ulogic;
		SPO   : out std_ulogic;
		A0    : in std_ulogic;
		A1    : in std_ulogic;
		A2    : in std_ulogic;
		A3    : in std_ulogic;
		A4    : in std_ulogic;
		D     : in std_ulogic;
		DPRA0 : in std_ulogic;
		DPRA1 : in std_ulogic;
		DPRA2 : in std_ulogic;
		DPRA3 : in std_ulogic;
		DPRA4 : in std_ulogic;
		WCLK  : in std_ulogic;
		WE    : in std_ulogic
	);
    end component;

    component   RAM64X1D
	port
	(
		DPO   : out std_ulogic;
		SPO   : out std_ulogic;
		A0    : in std_ulogic;
		A1    : in std_ulogic;
		A2    : in std_ulogic;
		A3    : in std_ulogic;
		A4    : in std_ulogic;
		A5    : in std_ulogic;
		D     : in std_ulogic;
		DPRA0 : in std_ulogic;
		DPRA1 : in std_ulogic;
		DPRA2 : in std_ulogic;
		DPRA3 : in std_ulogic;
		DPRA4 : in std_ulogic;
		DPRA5 : in std_ulogic;
		WCLK  : in std_ulogic;
		WE    : in std_ulogic
	);
    end component;

    component   RAM128X1D
	port
	(
		DPO   : out std_ulogic;
		SPO   : out std_ulogic;
		A     : in std_logic_vector(6 downto 0);
		D     : in std_ulogic;
		DPRA  : in std_logic_vector(6 downto 0);
		WCLK  : in std_ulogic;
		WE    : in std_ulogic
	);
    end component;

    component   RAM256X1D
	port
	(
		DPO   : out std_ulogic;
		SPO   : out std_ulogic;
		A     : in std_logic_vector(7 downto 0);
		D     : in std_ulogic;
		DPRA  : in std_logic_vector(7 downto 0);
		WCLK  : in std_ulogic;
		WE    : in std_ulogic
	);
    end component;

    component RAMB36E1
         generic (
             RAM_MODE            : string := "TDP";
             SIM_COLLISION_CHECK : string := "ALL";
             SIM_DEVICE          : string := "7SERIES";
             READ_WIDTH_A        : integer := 0;
             WRITE_WIDTH_B       : integer := 0
         );
         port (
             DOADO         : out std_logic_vector(31 downto 0);
             DOBDO         : out std_logic_vector(31 downto 0);
             ADDRARDADDR   : in std_logic_vector(15 downto 0);
             ADDRBWRADDR   : in std_logic_vector(15 downto 0);
             CASCADEINA    : in std_ulogic;
             CASCADEINB    : in std_ulogic;
             CLKARDCLK     : in std_ulogic;
             CLKBWRCLK     : in std_ulogic;
             DIADI         : in std_logic_vector(31 downto 0);
             DIBDI         : in std_logic_vector(31 downto 0);
             DIPADIP       : in std_logic_vector(3 downto 0);
             DIPBDIP       : in std_logic_vector(3 downto 0);
             ENARDEN       : in std_ulogic;
             ENBWREN       : in std_ulogic;
             INJECTDBITERR : in std_ulogic;
             INJECTSBITERR : in std_ulogic;
             REGCEAREGCE   : in std_ulogic;
             REGCEB        : in std_ulogic;
             RSTRAMARSTRAM : in std_ulogic;
             RSTRAMB       : in std_ulogic;
             RSTREGARSTREG : in std_ulogic;
             RSTREGB       : in std_ulogic;
             WEA           : in std_logic_vector(3 downto 0);
             WEBWE         : in std_logic_vector(7 downto 0)
         );
    end component;
begin
    -------------------------------------------------------------------------------
    -- アドレス信号の生成
    -------------------------------------------------------------------------------
    process (WADDR) 
        variable a : std_logic_vector(DEPTH-WWIDTH-1 downto 0);
    begin
        a := WADDR;
        for i in wptr'range loop
            if (i > a'high) then
                wptr(i) <= '1';
            else
                wptr(i) <= a(i);
            end if;
        end loop;
    end process;

    process (RADDR) 
        variable a : std_logic_vector(DEPTH-RWIDTH-1 downto 0);
    begin
        a := RADDR;
        for i in rptr'range loop
            if (i > a'high) then
                rptr(i) <= '1';
            else
                rptr(i) <= a(i);
            end if;
        end loop;
    end process;

    -------------------------------------------------------------------------------
    -- ダミー用入力信号の初期化(不定入力を抑制するため)
    -------------------------------------------------------------------------------
    dummy <= (others => '0');
    s1    <= '1';
    s0    <= '0';
    rpin  <= (others => '0');
    wpin  <= (others => '0');

    -------------------------------------------------------------------------------
    -- wena
    -------------------------------------------------------------------------------
    process (WE) begin
        for i in wena'range loop
            if (WE(i/(2**((WWIDTH-RAM_WD_WIDTH+RAM_WE_WIDTH)-WEBIT))) = '1') then
                wena(i) <= '1';
            else
                wena(i) <= '0';
            end if;
        end loop;
    end process;

    -------------------------------------------------------------------------------
    -- RAMB32E1 を使う場合
    -------------------------------------------------------------------------------
    GEN_B32K_W64_R64: if (RAM_ADDR_BITS = 15 and RAM_WD_BITS = 64 and RAM_RD_BITS = 64) generate
        B: for i in 0 to RAM_NUM-1 generate
            alias   do  :  std_logic_vector(RAM_RD_BITS-1 downto 0) is RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i);
            alias   di  :  std_logic_vector(RAM_WD_BITS-1 downto 0) is WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i);
            alias   wb  :  std_logic_vector(RAM_WE_BITS-1 downto 0) is wena (RAM_WE_BITS*(i+1)-1 downto RAM_WE_BITS*i);
            signal  ra  :  std_logic_vector(15 downto 0);
            signal  wa  :  std_logic_vector(15 downto 0);
        begin
            ra <= "0" & rptr & "000000";
            wa <= "0" & wptr & "000000";
            RAM: RAMB36E1
                generic map (
                    RAM_MODE            => "SDP",
                    SIM_COLLISION_CHECK => "NONE",
                    READ_WIDTH_A        => 72,
                    WRITE_WIDTH_B       => 72
                )
                port map (
                    DOADO         => do(31 downto  0),
                    DOBDO         => do(63 downto 32),
                    ADDRARDADDR   => ra,
                    ADDRBWRADDR   => wa,
                    CASCADEINA    => '0',
                    CASCADEINB    => '0',
                    CLKARDCLK     => RCLK,
                    CLKBWRCLK     => WCLK,
                    DIADI         => di(31 downto  0),
                    DIBDI         => di(63 downto 32),
                    DIPADIP       => "0000",
                    DIPBDIP       => "0000",
                    ENARDEN       => '1',
                    ENBWREN       => '1',
                    INJECTDBITERR => '0',
                    INJECTSBITERR => '0',
                    REGCEAREGCE   => '0',
                    REGCEB        => '0',
                    RSTRAMARSTRAM => '0',
                    RSTRAMB       => '0',
                    RSTREGARSTREG => '0',
                    RSTREGB       => '0',
                    WEA           => "0000",
                    WEBWE         => wb
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S36_S36を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W32_R32: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 32 and RAM_RD_BITS = 32) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S36_S36
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPA   => wpin,
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S18_S18を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W16_R16: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 16 and RAM_RD_BITS = 16) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S18_S18
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPA   => wpin,
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S9_S9を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W08_R08: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 8 and RAM_RD_BITS = 8) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S9_S9
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPA   => wpin,
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S4_S4を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W04_R04: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 4 and RAM_RD_BITS = 4) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S4_S4
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S2_S2を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W02_R02: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 2 and RAM_RD_BITS = 2) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S2_S2
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S1_S1を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W01_R01: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 1 and RAM_RD_BITS = 1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S1_S1
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S18_S36を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W16_R32: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 16 and RAM_RD_BITS = 32) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S18_S36
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPA   => wpin,
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S9_S18を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W08_R16: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  8 and RAM_RD_BITS = 16) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S9_S18
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPA   => wpin,
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S4_S9を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W04_R08: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  4 and RAM_RD_BITS =  8) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S4_S9
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S2_S4を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W02_R04: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  2 and RAM_RD_BITS =  4) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S2_S4
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S1_S2を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W01_R02: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  1 and RAM_RD_BITS =  2) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S1_S2
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S9_S36を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W08_R32: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  8 and RAM_RD_BITS = 32) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S9_S36
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPA   => wpin,
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S4_S18を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W04_R16: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  4 and RAM_RD_BITS = 16) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S4_S18
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S2_S9を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W02_R08: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  2 and RAM_RD_BITS =  8) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S2_S9
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOPB   => open,
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIPB   => rpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S1_S4を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W01_R04: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  1 and RAM_RD_BITS =  4) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S1_S4
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => open,
                    DOB    => odata(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ADDRA  => wptr,
                    ADDRB  => rptr,
                    CLKA   => WCLK,
                    CLKB   => RCLK,
                    DIA    => WDATA(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIB    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => wena(i),
                    WEB    => s0
                );
        end generate;
        RDATA <= SWAP_R(odata,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S18_S36を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W32_R16: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 32 and RAM_RD_BITS = 16) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S18_S36
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIPA   => rpin,
                    DIPB   => wpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S9_S18を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W16_R08: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 16 and RAM_RD_BITS =  8) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S9_S18
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIPA   => rpin,
                    DIPB   => wpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S4_S9を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W08_R04: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  8 and RAM_RD_BITS =  4) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S4_S9
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    DOPB   => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIPB   => wpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S2_S4を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W04_R02: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  4 and RAM_RD_BITS =  2) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S2_S4
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S1_S2を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W02_R01: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  2 and RAM_RD_BITS =  1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S1_S2
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S9_S36を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W32_R08: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 32 and RAM_RD_BITS =  8) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S9_S36
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    DOPA   => open,
                    DOPB   => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIPA   => rpin,
                    DIPB   => wpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    GEN_B16K_W16_R04: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS = 16 and RAM_RD_BITS =  4) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S4_S18
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    DOPB   => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIPB   => wpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S2_S9を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W08_R02: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  8 and RAM_RD_BITS =  2) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S2_S9
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    DOPB   => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    DIPB   => wpin,
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAMB16_S1_S4を使う場合
    -------------------------------------------------------------------------------
    GEN_B16K_W04_R01: if (RAM_ADDR_BITS = 14 and RAM_WD_BITS =  4 and RAM_RD_BITS =  1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAMB16_S1_S4
                generic map (
                    SIM_COLLISION_CHECK => "NONE"
                )
                port map (
                    DOA    => RDATA(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DOB    => open,
                    ADDRA  => rptr,
                    ADDRB  => wptr,
                    CLKA   => RCLK,
                    CLKB   => WCLK,
                    DIA    => dummy(RAM_RD_BITS*(i+1)-1 downto RAM_RD_BITS*i),
                    DIB    => idata(RAM_WD_BITS*(i+1)-1 downto RAM_WD_BITS*i),
                    ENA    => s1,
                    ENB    => s1,
                    SSRA   => s0,
                    SSRB   => s0,
                    WEA    => s0,
                    WEB    => wena(i)
                );
        end generate;
        idata <= SWAP_W(WDATA,RAM_NUM,WWIDTH,RWIDTH);
    end generate;

    -------------------------------------------------------------------------------
    -- RAM32X1Dを使う場合
    -------------------------------------------------------------------------------
    GEN_B32_W01_R01: if (RAM_ADDR_BITS = 5 and RAM_WD_BITS = 1 and RAM_RD_BITS = 1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAM32X1D
                port map (
                    SPO    => open,
                    DPO    => odata(i),
                    A0     => wptr (0),
                    A1     => wptr (1),
                    A2     => wptr (2),
                    A3     => wptr (3),
                    A4     => wptr (4),
                    DPRA0  => rptr (0),
                    DPRA1  => rptr (1),
                    DPRA2  => rptr (2),
                    DPRA3  => rptr (3),
                    DPRA4  => rptr (4),
                    WCLK   => WCLK,
                    D      => WDATA(i),
                    WE     => wena (i)
                );
        end generate;
        process (RCLK) begin
            if (RCLK'event and RCLK = '1') then
                RDATA <= odata;
            end if;
        end process;
    end generate;

    -------------------------------------------------------------------------------
    -- RAM64X1Dを使う場合
    -------------------------------------------------------------------------------
    GEN_B64_W01_R01: if (RAM_ADDR_BITS = 6 and RAM_WD_BITS = 1 and RAM_RD_BITS = 1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAM64X1D
                port map (
                    SPO    => open,
                    DPO    => odata(i),
                    A0     => wptr (0),
                    A1     => wptr (1),
                    A2     => wptr (2),
                    A3     => wptr (3),
                    A4     => wptr (4),
                    A5     => wptr (5),
                    DPRA0  => rptr (0),
                    DPRA1  => rptr (1),
                    DPRA2  => rptr (2),
                    DPRA3  => rptr (3),
                    DPRA4  => rptr (4),
                    DPRA5  => rptr (5),
                    WCLK   => WCLK,
                    D      => WDATA(i),
                    WE     => wena (i)
                );
        end generate;
        process (RCLK) begin
            if (RCLK'event and RCLK = '1') then
                RDATA <= odata;
            end if;
        end process;
    end generate;

    -------------------------------------------------------------------------------
    -- RAM128X1Dを使う場合
    -------------------------------------------------------------------------------
    GEN_B128_W01_R01: if (RAM_ADDR_BITS = 7 and RAM_WD_BITS = 1 and RAM_RD_BITS = 1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAM128X1D
                port map (
                    SPO    => open,
                    DPO    => odata(i),
                    A      => wptr    ,
                    DPRA   => rptr    ,
                    WCLK   => WCLK,
                    D      => WDATA(i),
                    WE     => wena (i)
                );
        end generate;
        process (RCLK) begin
            if (RCLK'event and RCLK = '1') then
                RDATA <= odata;
            end if;
        end process;
    end generate;

    -------------------------------------------------------------------------------
    -- RAM256X1Dを使う場合
    -------------------------------------------------------------------------------
    GEN_B256_W01_R01: if (RAM_ADDR_BITS = 8 and RAM_WD_BITS = 1 and RAM_RD_BITS = 1) generate
        B: for i in 0 to RAM_NUM-1 generate
            RAM: RAM256X1D
                port map (
                    SPO    => open,
                    DPO    => odata(i),
                    A      => wptr    ,
                    DPRA   => rptr    ,
                    WCLK   => WCLK,
                    D      => WDATA(i),
                    WE     => wena (i)
                );
        end generate;
        process (RCLK) begin
            if (RCLK'event and RCLK = '1') then
                RDATA <= odata;
            end if;
        end process;
    end generate;

end XILINX_ULTRASCALE_AUTO_SELECT;
