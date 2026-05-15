-----------------------------------------------------------------------------------
--!     @file    udpram_model.vhd
--!     @brief   Universal Dual Port RAM Architecture (Simple Model)
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
-----------------------------------------------------------------------------------
--! @brief   UDPRAM(Universal Dual Port RAM) のアーキテクチャ本体
--!        * VHDL の構文のみで記述.
--!        * 他のパッケージやモジュールに依存しない.
--!          ieee.std_logic_1164 と ieee.numeric_std のみ使用.
--!        * 最近の FPGA 用論理合成ツールでは、このような記述だけで十分な場合が多い.
--!          その反面、論理合成ツールによっては思わぬ結果を得ることがある.
--!          実用に際しては、使用する論理合成ツールの合成結果を確認すること.
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture MODEL of UDPRAM is
    -------------------------------------------------------------------------------
    -- max : 整数の最大値を求める関数.
    -------------------------------------------------------------------------------
    function  max(A,B: integer) return integer is
    begin
        if (A >= B) then
            return A;
        else
            return B;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- calc_width : 指定された数を表現するのに必要なビット数を計算する関数.
    -------------------------------------------------------------------------------
    function calc_width(NUM:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**value < NUM) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    -------------------------------------------------------------------------------
    -- to_unsigned : std_logic_vector を unsigned に変換する関数.
    -------------------------------------------------------------------------------
    function  to_unsigned(VEC: std_logic_vector) return unsigned is
        alias     i_vec  :  std_logic_vector(VEC'length-1 downto 0) is VEC;
        variable  u_vec  :  unsigned        (VEC'length-1 downto 0);
    begin
        for i in u_vec'range loop
            if i_vec(i) = '1' then
                u_vec(i) := '1';
            else
                u_vec(i) := '0';
            end if;
        end loop;
        return u_vec;
    end function;
    -------------------------------------------------------------------------------
    -- slice : VEC から 指定された位置の指定されたビット数の配列を取り出す関数.
    -------------------------------------------------------------------------------
    function  slice(VEC: std_logic_vector;BITS,POS: integer) return std_logic_vector is
        alias     i_vec  :  std_logic_vector(VEC'length-1 downto 0) is VEC;
        variable  o_vec  :  std_logic_vector(BITS-1 downto 0);
    begin
        for i in o_vec'range loop
            if (i+POS >= i_vec'low ) and
               (i+POS <= i_vec'high) then
                o_vec(i) := i_vec(i+POS);
            else
                o_vec(i) := '0';
            end if;
        end loop;
        return o_vec;
    end function;
    -------------------------------------------------------------------------------
    -- NUM_WORDS  : DPRAM のデータのワード数(WN と RN の大きいほう).
    -------------------------------------------------------------------------------
    constant  NUM_WORDS     :  integer := max(WN,RN);
    -------------------------------------------------------------------------------
    -- WORD_WIDTH : NUM_WORDS を表現するビット数. 
    -------------------------------------------------------------------------------
    constant  WORD_WIDTH    :  integer := calc_width(NUM_WORDS);
    -------------------------------------------------------------------------------
    -- w_ena   : 書き込み時の書き込みイネーブル信号
    -------------------------------------------------------------------------------
    signal    w_ena         :  std_logic_vector(NUM_WORDS-1 downto 0);
    -------------------------------------------------------------------------------
    -- w_data  : RAM に書き込むデータ
    -- r_data  : RAM から読み出したデータ
    -- r_ce    : RDATA を レジスタ出力する際の Clock Enable 信号.
    -------------------------------------------------------------------------------
    signal    w_data        :  std_logic_vector(NUM_WORDS*DATA_BITS-1 downto 0);
    signal    r_data        :  std_logic_vector(NUM_WORDS*DATA_BITS-1 downto 0);
    signal    r_ce          :  std_logic_vector(NUM_WORDS          -1 downto 0);
    -------------------------------------------------------------------------------
    -- o_data  : 出力するデータ
    -- o_ce    : RDATA を レジスタ出力する際の Clock Enable 信号.
    -------------------------------------------------------------------------------
    signal    o_data        :  std_logic_vector(RN       *DATA_BITS-1 downto 0);
    signal    o_ce          :  std_logic_vector(RN                 -1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- w_data   : 書き込み時の RAM のデータ
    -- w_ena    : 書き込み時の 書き込みイネーブル信号
    -------------------------------------------------------------------------------
    -- WN = NUM_WORDS の場合
    -------------------------------------------------------------------------------
    WN_EQ_NUM_WORDS: if (WN = NUM_WORDS) generate
        w_data <= WDATA;
        w_ena  <= WE;
    end generate;
    -------------------------------------------------------------------------------
    -- WN < NUM_WORDS の場合
    -------------------------------------------------------------------------------
    WN_LT_NUM_WORDS: if (WN < NUM_WORDS) generate
        constant  WE_NONE   :  std_logic_vector(WN-1 downto 0) := (others => '0');
        constant  WN_WIDTH  :  integer := calc_width(WN);
        constant  POS_WIDTH :  integer := calc_width(NUM_WORDS/WN);
        signal    w_pos     :  std_logic_vector(POS_WIDTH-1 downto 0);
    begin
        w_pos <= slice(WADDR, POS_WIDTH, WN_WIDTH);
        process (WDATA) begin
            for i in 0 to NUM_WORDS/WN-1 loop
                w_data((i+1)*WN*DATA_BITS-1 downto i*WN*DATA_BITS) <= WDATA;
            end loop;
        end process;
        process (WE, w_pos) begin
            for i in 0 to NUM_WORDS/WN-1 loop
                if (i = to_integer(to_unsigned(w_pos))) then
                    w_ena((i+1)*WN-1 downto i*WN) <= WE;
                else
                    w_ena((i+1)*WN-1 downto i*WN) <= WE_NONE;
                end if;
            end loop;
        end process;
    end generate;
    -------------------------------------------------------------------------------
    -- RAM : 
    -------------------------------------------------------------------------------
    RAM: block
        ---------------------------------------------------------------------------
        -- WORD_TYPE   : １ワードのデータを示す型.
        -- WORD_VECTOR : ワードの配列を示す型.
        ---------------------------------------------------------------------------
        subtype   WORD_TYPE     is std_logic_vector(DATA_BITS-1 downto 0);
        type      WORD_VECTOR   is array(integer range <>) of WORD_TYPE;
        ---------------------------------------------------------------------------
        -- INDEX_MIN   : RAM のインデックスの最小値.
        -- INDEX_MAX   : RAM のインデックスの最大値.
        -- INDEX_TYPE  : RAM のインデックスを表す形(整数).
        ---------------------------------------------------------------------------
        constant  INDEX_MIN     :  integer := 0;
        constant  INDEX_MAX     :  integer := 2**(ADDR_BITS-WORD_WIDTH)-1;
        subtype   INDEX_TYPE    is integer range INDEX_MIN to INDEX_MAX;
        ---------------------------------------------------------------------------
        -- addr_to_index : ADDR から index を得る関数.
        ---------------------------------------------------------------------------
        function  addr_to_index(ADDR: std_logic_vector) return INDEX_TYPE is
            constant  BITS      :  integer := ADDR_BITS-WORD_WIDTH;
            constant  POS       :  integer := WORD_WIDTH;
            variable  index     :  std_logic_vector(BITS downto 0);
        begin
            if (BITS > 0) then
                index(BITS-1 downto 0) := slice(ADDR, BITS, POS);
                return to_integer(to_unsigned(index(BITS-1 downto 0)));
            else
                return 0;
            end if;
        end function;
        ---------------------------------------------------------------------------
        -- 各種信号
        ---------------------------------------------------------------------------
        signal    r_index       :  INDEX_TYPE;
        signal    w_index       :  INDEX_TYPE;
        signal    same_index    :  boolean;
    begin
        ---------------------------------------------------------------------------
        -- w_index : 書き込み時の RAM のインデックス
        ---------------------------------------------------------------------------
        w_index <= addr_to_index(WADDR);
        ---------------------------------------------------------------------------
        -- r_index : 読み出し時の RAM のインデックス
        ---------------------------------------------------------------------------
        r_index <= addr_to_index(RADDR);
        ---------------------------------------------------------------------------
        -- same_index : 書き込み時のインデックス値と読み込み時のインデックスの値が同じ.
        ---------------------------------------------------------------------------
        same_index <= (w_index = r_index);
        ---------------------------------------------------------------------------
        -- WORD : 各ワード毎の RAM の記述
        ---------------------------------------------------------------------------
        WORD: for pos in 0 to NUM_WORDS-1 generate
            signal    ram       :  WORD_VECTOR(INDEX_MIN to INDEX_MAX);
            signal    w_word    :  WORD_TYPE;
            signal    r_word    :  WORD_TYPE;
        begin
            -----------------------------------------------------------------------
            -- w_word  : 書き込み時のワード
            -----------------------------------------------------------------------
            w_word <= w_data((pos+1)*DATA_BITS-1 downto pos*DATA_BITS);
            -----------------------------------------------------------------------
            -- RAM への書き込み
            -----------------------------------------------------------------------
            process (WCLK) begin
                if (WCLK'event and WCLK = '1') then
                    if (w_ena(pos) = '1') then
                        ram(w_index) <= w_word;
                    end if;
                end if;
            end process;
            -----------------------------------------------------------------------
            -- r_word  : RAM から読み出したワード
            -----------------------------------------------------------------------
            r_word <= ram(r_index);
            -----------------------------------------------------------------------
            -- r_data  : READ-FIRST か NO-CHANGE Mode 時の読み出した RAM のデータ
            -----------------------------------------------------------------------
            READ_FIRST:  if (WRITE_MODE /= 1) generate
                r_data((pos+1)*DATA_BITS-1 downto pos*DATA_BITS) <= r_word;
            end generate;
            -----------------------------------------------------------------------
            -- r_data  : WRITE-FIRST Mode 時の読み出した RAM のデータ
            -----------------------------------------------------------------------
            WRITE_FIRST: if (WRITE_MODE  = 1) generate
                process(w_ena, same_index, w_word, r_word) begin
                    if (w_ena(pos) = '1' and same_index = TRUE) then
                        r_data((pos+1)*DATA_BITS-1 downto pos*DATA_BITS) <= w_word;
                    else
                        r_data((pos+1)*DATA_BITS-1 downto pos*DATA_BITS) <= r_word;
                    end if;
                end process;
            end generate;
            -----------------------------------------------------------------------
            -- r_ce    : RDATA を レジスタ出力する際の Clock Enable 信号.
            -----------------------------------------------------------------------
            r_ce(pos) <= '0' when (READ_REGS = 1 and WRITE_MODE = 2) and 
                                  (w_ena(pos) = '1' and same_index = TRUE) else '1';
        end generate;
    end block;
    -------------------------------------------------------------------------------
    -- o_data   : 出力するデータ.
    -- o_ce     : RDATA を レジスタ出力する際の Clock Enable 信号.
    -------------------------------------------------------------------------------
    -- RN = NUM_WORDS の場合
    -------------------------------------------------------------------------------
    RN_EQ_NUM_WORDS: if (RN = NUM_WORDS) generate
        o_data <= r_data;
        o_ce   <= r_ce;
    end generate;
    -------------------------------------------------------------------------------
    -- RN < NUM_WORDS の場合
    -------------------------------------------------------------------------------
    RN_LT_NUM_WORDS: if (RN < NUM_WORDS) generate
        constant  RN_WIDTH      :  integer := calc_width(RN);
        constant  POS_WIDTH     :  integer := calc_width(NUM_WORDS/RN);
        signal    r_pos         :  std_logic_vector(POS_WIDTH-1 downto 0);
        function  select_r(D,A: std_logic_vector; LEN:integer) return std_logic_vector is
            alias     addr      :  std_logic_vector(A'length-1 downto 0) is A;
            alias     data      :  std_logic_vector(D'length-1 downto 0) is D;
            variable  lo_data   :  std_logic_vector(data'length/2-1 downto 0);
            variable  hi_data   :  std_logic_vector(data'length/2-1 downto 0);
            variable  lo_result :  std_logic_vector(LEN-1 downto 0);
            variable  hi_result :  std_logic_vector(LEN-1 downto 0);
        begin
            lo_data := data(data'length/2-1 downto 0);
            hi_data := data(data'length-1   downto data'length/2);
            if (addr'length > 1) then
                lo_result := select_r(lo_data, addr(addr'high-1 downto 0), LEN);
                hi_result := select_r(hi_data, addr(addr'high-1 downto 0), LEN);
            else
                lo_result := lo_data;
                hi_result := hi_data;
            end if;
            if (addr(addr'high) = '1') then
                return hi_result;
            else
                return lo_result;
            end if;
        end function;
    begin
        r_pos  <= slice(RADDR, POS_WIDTH, RN_WIDTH);
        o_data <= select_r(r_data, r_pos, RN*DATA_BITS);
        o_ce   <= select_r(r_ce  , r_pos, RN);
    end generate;
    -------------------------------------------------------------------------------
    -- RDATA   : Through Output
    -------------------------------------------------------------------------------
    READ_REGS_F: if (READ_REGS = 0) generate
        RDATA <= o_data;
    end generate;
    -------------------------------------------------------------------------------
    -- RDATA   : Register Output
    -------------------------------------------------------------------------------
    READ_REGS_T: if (READ_REGS = 1) generate
        process (RCLK) begin
            if (RCLK'event and RCLK = '1') then
                for pos in 0 to RN-1 loop
                    if (RE(pos) = '1' and o_ce(pos) = '1') then
                        RDATA((pos+1)*DATA_BITS-1 downto pos*DATA_BITS) <=
                            o_data((pos+1)*DATA_BITS-1 downto pos*DATA_BITS);
                    end if;
                end loop;
            end if;
        end process;
    end generate;
end MODEL;
