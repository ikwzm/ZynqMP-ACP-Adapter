-----------------------------------------------------------------------------------
--!     @file    udpram.vhd
--!     @brief   Universal Dual Port RAM Entity.
--!     @version 2.7.0
--!     @date    2026/5/10
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2026 Ichiro Kawazome
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
-----------------------------------------------------------------------------------
--! @brief   Universal Dual Port RAM :
--!          1W1Rの Dual Port Memory.
--!        * ライトとリードで別々にビット幅を指定できる(Asymmetric).
--!        * リードクロックはオプション. ライトクロックと別クロックにすることも可能.
--!        * ３つのライトモード (READ-FIRST、WRITE-FIRST、NO-CHANGE)
-----------------------------------------------------------------------------------
entity  UDPRAM is
    generic (
        DATA_BITS   : --! @brief WORD DATA BITS :
                      --! データの１ワードのビット数を指定する.
                      integer := 32;
        ADDR_BITS   : --! @brief ADDRESS BITS :
                      --! アドレス信号(WADDR/RADDR)のビット数を指定する.
                      --! アドレスの単位はワード.
                      integer :=  4;
        WN          : --! @brief WRITE WORD COUNT :
                      --! ライトデータ(WDATA)のワード数を指定する.
                      --! ライトイネーブル信号(WE)のビット数でもある.
                      --! ライトデータ全体のビット数は WN*DATA_BITS になる.
                      integer :=  1;
        RN          : --! @brief READ  WORD COUNT :
                      --! リードデータ(RDATA)のワード数を指定する.
                      --! リードデータ全体のビット数は RN*DATA_BITS になる.
                      integer :=  1;
        READ_REGS   : --! @brief READ DATA REGISTERED OUTPUT :
                      --! リードデータ(RDATA)の出力モードを指定する.
                      --! * 0: RAM のリードデータをそのまま出力.
                      --! * 1: リードクロック(RCLK)によるレジスタ出力.
                      integer range 0 to 1 := 0;
        WRITE_MODE  : --! @brief READ-DURING-WRITE BEHAVIOR :
                      --! 書き込み時にライトアドレスとリードアドレスが同じ場合の
                      --! 挙動を示す.
                      --! * 0: READ-FIRST  (RAM上の古いデータを出力).
                      --! * 1: WRITE-FIRST (書き込んだ新しいデータを出力).
                      --! * 2: NO-CHANGE   (出力レジスタは更新されない).
                      integer range 0 to 2 := 0;
        ID          : --! @brief DPRAM IDENTIFIER :
                      --! どのモジュールで使われているかを示す識別番号.
                      integer := 0 
    );
    port (
        WCLK        : --! @brief WRITE CLOCK :
                      --! ライトクロック信号
                      in  std_logic;
        WE          : --! @brief WRITE ENABLE :
                      --! ライトイネーブル信号
                      in  std_logic_vector(WN          -1 downto 0);
        WADDR       : --! @brief WRITE ADDRESS :
                      --! ライトアドレス信号
                      --! ライトするワードの位置を指定する.
                      in  std_logic_vector(ADDR_BITS   -1 downto 0);
        WDATA       : --! @brief WRITE DATA :
                      --! ライトデータ信号
                      in  std_logic_vector(WN*DATA_BITS-1 downto 0);
        RCLK        : --! @brief READ CLOCK :
                      --! リードクロック信号
                      --! READ_REGS=1 の場合のみ有効.
                      --! READ_REGS=0 の場合は無視される.
                      in  std_logic := '0';
        RE          : --! @brief READ ENABLE :
                      --! リードイネーブル信号
                      --! READ_REGS=1 の場合のみ有効. 
                      --! 対応するレジスタにRAMから読んだデータをセットする.
                      --! READ_REGS=0 の場合は無視される.
                      in  std_logic_vector(RN          -1 downto 0) := (others => '1');
        RADDR       : --! @brief READ ADDRESS :
                      --! リードアドレス信号
                      --! リードするワードの位置を指定する.
                      in  std_logic_vector(   ADDR_BITS-1 downto 0);
        RDATA       : --! @brief READ DATA :
                      --! リードデータ信号
                      out std_logic_vector(RN*DATA_BITS-1 downto 0)
    );
end     UDPRAM;
