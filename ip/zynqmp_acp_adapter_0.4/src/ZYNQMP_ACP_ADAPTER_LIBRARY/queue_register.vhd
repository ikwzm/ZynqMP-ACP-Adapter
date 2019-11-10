-----------------------------------------------------------------------------------
--!     @file    queue_register.vhd
--!     @brief   QUEUE REGISTER MODULE :
--!              フリップフロップベースの比較的浅いキュー.
--!     @version 1.5.0
--!     @date    2013/4/2
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
--! @brief   QUEUE REGISTER
--!          フリップフロップベースの比較的浅いキュー.
--!        * フリップフロップを使っているのでキューの段数が大きいと
--!          それなりに回路規模が大きくなることに注意.
-----------------------------------------------------------------------------------
entity  QUEUE_REGISTER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数
    -------------------------------------------------------------------------------
    generic (
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさをワード数で指定する.
                      integer := 1;
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(I_DATA/O_DATA/Q_DATA)のビット幅を指定する.
                      integer :=  32;
        LOWPOWER    : --! @brief LOW POWER MODE :
                      --! キューのレジスタに不必要なロードを行わないことにより、
                      --! レジスタが不必要にトグルすることを防いで消費電力を
                      --! 下げるようにする.
                      --! ただし、回路が若干増える.
                      integer range 0 to 1 := 1
    );
    port (
    -------------------------------------------------------------------------------
    -- クロック&リセット信号
    -------------------------------------------------------------------------------
        CLK         : --! @brief CLOCK :
                      --! クロック信号
                      in  std_logic; 
        RST         : --! @brief ASYNCRONOUSE RESET :
                      --! 非同期リセット信号.アクティブハイ.
                      in  std_logic;
        CLR         : --! @brief SYNCRONOUSE RESET :
                      --! 同期リセット信号.アクティブハイ.
                      in  std_logic;
    -------------------------------------------------------------------------------
    -- 入力側
    -------------------------------------------------------------------------------
        I_DATA      : --! @brief INPUT DATA  :
                      --! 入力データ信号.
                      in  std_logic_vector(DATA_BITS-1 downto 0);
        I_VAL       : --! @brief INPUT DATA VALID :
                      --! 入力データ有効信号.
                      in  std_logic;
        I_RDY       : --! @brief INPUT READY :
                      --! 入力可能信号.
                      --! キューが空いていて、入力データを受け付けることが可能で
                      --! あることを示す信号.
                      out std_logic;
    -------------------------------------------------------------------------------
    -- 出力側
    -------------------------------------------------------------------------------
        O_DATA      : --! @brief OUTPUT DATA :
                      --! 出力データ.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        O_VAL       : --! @brief OUTPUT DATA VALID :
                      --! キューレジスタに有効なデータが入っている事を示すフラグ.
                      --! * キューレジスタは1〜QUEUE_SIZEまであるが、対応する位置の
                      --!   フラグが'1'ならば有効なデータが入っている事を示す.
                      --! * この出力信号の範囲が1からではなく0から始まっている事に
                      --!   注意. これはQUEUE_SIZE=0の場合に対応するため.
                      --!   QUEUE_SIZE>0の場合は、O_VAL(0)はO_VAL(1)と同じ.
                      out std_logic_vector(QUEUE_SIZE  downto 0);
        Q_DATA      : --! @brief OUTPUT REGISTERD DATA :
                      --! レジスタ出力の出力データ.
                      --! 出力データ(O_DATA)をクロックで叩いたもの.
                      out std_logic_vector(DATA_BITS-1 downto 0);
        Q_VAL       : --! @brief OUTPUT REGISTERD DATA VALID :
                      --! キューレジスタに有効なデータが入っている事を示すフラグ.
                      --! O_VALをクロックで叩いたもの.
                      --! * キューレジスタは1〜QUEUE_SIZEまであるが、対応する位置の
                      --!   フラグが'1'ならば有効なデータが入っている事を示す.
                      --! * この出力信号の範囲が1からではなく0から始まっている事に
                      --!   注意. これはQUEUE_SIZE=0の場合に対応するため.
                      --!   QUEUE_SIZE>0の場合は、Q_VAL(0)はQ_VAL(1)と同じ.
                      out std_logic_vector(QUEUE_SIZE  downto 0);
        Q_RDY       : --! @brief OUTPUT READY :
                      --! 出力可能信号.
                      in  std_logic
    );
end QUEUE_REGISTER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of QUEUE_REGISTER is
begin
    -------------------------------------------------------------------------------
    --  QUEUE_SIZE=0の場合はなにもしない
    -------------------------------------------------------------------------------
    QUEUE_SIZE_EQ_0: if (QUEUE_SIZE = 0) generate
        O_DATA   <= I_DATA;
        Q_DATA   <= I_DATA;
        O_VAL(0) <= I_VAL;
        Q_VAL(0) <= I_VAL;
        I_RDY    <= Q_RDY;
    end generate;
    -------------------------------------------------------------------------------
    -- QUEUE_SIZE>0の場合
    -------------------------------------------------------------------------------
    QUEUE_SIZE_GT_0: if (QUEUE_SIZE > 0) generate
        subtype  QUEUE_DATA_TYPE   is std_logic_vector(DATA_BITS-1 downto 0);
        constant QUEUE_DATA_NULL    : std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
        type     QUEUE_DATA_VECTOR is array (natural range <>) of QUEUE_DATA_TYPE;
        constant FIRST_OF_QUEUE     : integer := 1;
        constant LAST_OF_QUEUE      : integer := QUEUE_SIZE;
        signal   next_queue_data    : QUEUE_DATA_VECTOR(LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   curr_queue_data    : QUEUE_DATA_VECTOR(LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   queue_data_load    : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   next_queue_valid   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
        signal   curr_queue_valid   : std_logic_vector (LAST_OF_QUEUE downto FIRST_OF_QUEUE);
    begin
        ---------------------------------------------------------------------------
        -- next_queue_valid : 次のクロックでのキューの状態を示すフラグ.
        -- queue_data_load  : 次のクロックでcurr_queue_dataにnext_queue_dataの値を
        --                    ロードすることを示すフラグ.
        ---------------------------------------------------------------------------
        process (I_VAL, Q_RDY, curr_queue_valid) begin
            for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                -------------------------------------------------------------------
                -- 自分のキューにデータが格納されている場合...
                -------------------------------------------------------------------
                if (curr_queue_valid(i) = '1') then
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後ならば、
                    -- Q_RDY='1'で自分のキューをクリアする.
                    ---------------------------------------------------------------
                    if (i = LAST_OF_QUEUE) then
                        if (Q_RDY = '1') then
                            next_queue_valid(i) <= '0';
                        else
                            next_queue_valid(i) <= '1';
                        end if;
                        queue_data_load(i) <= '0';
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後でなくて、
                    -- かつ後ろのキューにデータが入っているならば、
                    -- Q_RDY='1'で後ろのキューのデータを自分のキューに格納する.
                    ---------------------------------------------------------------
                    elsif (curr_queue_valid(i+1) = '1') then
                        next_queue_valid(i) <= '1';
                        if (Q_RDY = '1') then
                            queue_data_load(i) <= '1';
                        else
                            queue_data_load(i) <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されていて、
                    -- かつ自分がキューの最後でなくて、
                    -- かつ後ろのキューにデータが入っていないならば、
                    -- I_VAL='0' かつ Q_RDY='1'ならば自分のキューをクリアする. 
                    -- I_VAL='1' かつ Q_RDY='1'ならばI_DATAを自分のキューに格納する.
                    ---------------------------------------------------------------
                    else
                        if (I_VAL = '0' and Q_RDY = '1') then
                            next_queue_valid(i) <= '0';
                        else
                            next_queue_valid(i) <= '1';
                        end if;
                        if (LOWPOWER > 0 and I_VAL = '1' and Q_RDY = '1') or
                           (LOWPOWER = 0                 and Q_RDY = '1') then
                            queue_data_load(i)  <= '1';
                        else
                            queue_data_load(i)  <= '0';
                        end if;
                    end if;
                -------------------------------------------------------------------
                -- 自分のところにデータが格納されていない場合...
                -------------------------------------------------------------------
                else -- if (curr_queue_valid(i) = '0') then
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭ならば、
                    -- I_VAL='1'で自分のキューにデータを格納する.
                    ---------------------------------------------------------------
                    if    (i = FIRST_OF_QUEUE) then
                        if (I_VAL = '1') then
                            next_queue_valid(i) <= '1';
                            queue_data_load(i)  <= '1';
                        else
                            next_queue_valid(i) <= '0';
                            queue_data_load(i)  <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭なくて、
                    -- かつ前のキューにデータが格納されているならば、
                    -- I_VAL='1'かつQ_RDY='0'で自分のキューにデータを格納する.
                    ---------------------------------------------------------------
                    elsif (curr_queue_valid(i-1) = '1') then
                        if (I_VAL = '1' and Q_RDY = '0') then
                            next_queue_valid(i) <= '1';
                        else
                            next_queue_valid(i) <= '0';
                        end if;
                        if (LOWPOWER = 0) or
                           (LOWPOWER > 0 and I_VAL = '1' and Q_RDY = '0') then
                            queue_data_load(i)  <= '1';
                        else
                            queue_data_load(i)  <= '0';
                        end if;
                    ---------------------------------------------------------------
                    -- もし自分のキューにデータが格納されてなくて、
                    -- かつ自分がキューの先頭なくて、
                    -- かつ前のキューにデータが格納されていないならば、
                    -- キューは空のまま.
                    ---------------------------------------------------------------
                    else
                            next_queue_valid(i) <= '0';
                            queue_data_load(i)  <= '0';
                    end if;
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- next_queue_data  : 次のクロックでキューに格納されるデータ.
        ---------------------------------------------------------------------------
        process (I_DATA, queue_data_load, curr_queue_data, curr_queue_valid) begin
            for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                if (queue_data_load(i) = '1') then
                    if    (i = LAST_OF_QUEUE) then
                        next_queue_data(i) <= I_DATA;
                    elsif (curr_queue_valid(i+1) = '1') then
                        next_queue_data(i) <= curr_queue_data(i+1);
                    else
                        next_queue_data(i) <= I_DATA;
                    end if;
                else
                        next_queue_data(i) <= curr_queue_data(i);
                end if;
            end loop;
        end process;
        ---------------------------------------------------------------------------
        -- curr_queue_data  : 現在、キューに格納されているデータ.
        -- curr_queue_valid : 現在、キューにデータが格納されていることを示すフラグ.
        -- I_RDY            : キューにデータが格納することが出来ることを示すフラグ.
        ---------------------------------------------------------------------------
        process (CLK, RST) begin
            if     (RST = '1') then
                   curr_queue_data  <= (others => QUEUE_DATA_NULL);
                   curr_queue_valid <= (others => '0');
                   I_RDY            <= '0';
            elsif  (CLK'event and CLK = '1') then
               if (CLR = '1') then
                   curr_queue_data  <= (others => QUEUE_DATA_NULL);
                   curr_queue_valid <= (others => '0');
                   I_RDY            <= '0';
               else
                   curr_queue_data  <= next_queue_data;
                   curr_queue_valid <= next_queue_valid;
                   I_RDY            <= not next_queue_valid(LAST_OF_QUEUE);
               end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        -- 各種出力信号
        ---------------------------------------------------------------------------
        O_DATA                     <= next_queue_data (FIRST_OF_QUEUE);
        Q_DATA                     <= curr_queue_data (FIRST_OF_QUEUE);
        O_VAL(0)                   <= next_queue_valid(FIRST_OF_QUEUE);
        O_VAL(QUEUE_SIZE downto 1) <= next_queue_valid;
        Q_VAL(0)                   <= curr_queue_valid(FIRST_OF_QUEUE);
        Q_VAL(QUEUE_SIZE downto 1) <= curr_queue_valid;
    end generate;
end RTL;
