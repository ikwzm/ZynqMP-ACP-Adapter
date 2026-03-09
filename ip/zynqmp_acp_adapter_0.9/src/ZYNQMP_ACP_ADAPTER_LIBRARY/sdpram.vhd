-----------------------------------------------------------------------------------
--!     @file    sdpram.vhd
--!     @brief   Synchronous Dual Port RAM Entity.
--!     @version 1.0.0
--!     @date    2012/8/11
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012 Ichiro Kawazome
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
--! @brief   SDPRAM :
--!          1W1Rの同期メモリ.
--!        * ライトとリードでは別クロック.
--!        * ライトとリードで別々にビット幅を指定できる.
-----------------------------------------------------------------------------------
entity  SDPRAM is
    generic (
        DEPTH   : --! @brief SDPRAM DEPTH :
                  --! メモリの深さ(ビット単位)を2のべき乗値で指定する.
                  --! 例 DEPTH=10 => 2**10=1024bit
                  integer := 10;
        RWIDTH  : --! @brief SDPRAM READ DATA PORT WIDTH :
                  --! リードデータ(RDATA)の幅(ビット数)を2のべき乗値で指定する.
                  --! 例 RWIDTH=5 => 2**5=32bit
                  integer := 5;   
        WWIDTH  : --! @brief SDPRAM WRITE DATA PORT WIDTH :
                  --! ライトデータ(WDATA)の幅(ビット数)を2のべき乗値で指定する.
                  integer := 6;   
        WEBIT   : --! @brief SDPRAM WRITE ENABLE WIDTH :
                  --! ライトイネーブル信号(WE)の幅(ビット数)を2のべき乗値で指定する.
                  --! 例 WEBIT=0 => 2**0=1bit
                  --!    WEBIT=2 => 2**2=4bit
                  integer := 0;
        ID      : --! @brief SDPRAM IDENTIFIER :
                  --! どのモジュールで使われているかを示す識別番号.
                  integer := 0 
    );
    port (
        WCLK    : --! @brief WRITE CLOCK :
                  --! ライトクロック信号
                  in  std_logic;
        WE      : --! @brief WRITE ENABLE :
                  --! ライトイネーブル信号
                  in  std_logic_vector(2**WEBIT-1 downto 0);
        WADDR   : --! @brief WRITE ADDRESS :
                  --! ライトアドレス信号
                  in  std_logic_vector(DEPTH-1 downto WWIDTH);
        WDATA   : --! @brief WRITE DATA :
                  --! ライトデータ信号
                  in  std_logic_vector(2**WWIDTH-1 downto 0);
        RCLK    : --! @brief READ CLOCK :
                  --! リードクロック信号
                  in  std_logic;
        RADDR   : --! @brief READ ADDRESS :
                  --! リードアドレス信号
                  in  std_logic_vector(DEPTH-1 downto RWIDTH);
        RDATA   : --! @brief READ DATA :
                  --! リードデータ信号
                  out std_logic_vector(2**RWIDTH-1 downto 0)
    );
end     SDPRAM;
