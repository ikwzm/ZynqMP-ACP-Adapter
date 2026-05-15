-----------------------------------------------------------------------------------
--!     @file    queue_receiver.vhd
--!     @brief   QUEUE RECEIVER MODULE :
--!              入力側がフリップフロップ入力の比較的浅いキュー.
--!     @version 1.5.3
--!     @date    2014/1/25
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2014 Ichiro Kawazome
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
--! @brief   QUEUE RECEIVER
--!          入力側がフリップフロップ入力の比較的浅いキュー.
--!        * 出力側がコンビネーション出力になっている.
--!        * フリップフロップを使っているのでキューの段数が大きいと
--!          それなりに回路規模が大きくなることに注意.
-----------------------------------------------------------------------------------
entity  QUEUE_RECEIVER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数
    -------------------------------------------------------------------------------
    generic (
        QUEUE_SIZE  : --! @brief QUEUE SIZE :
                      --! キューの大きさをワード数で指定する.
                      --! 構造上、キューの大きさは２以上でなければならない.
                      integer range 2 to 256 := 2;
        DATA_BITS   : --! @brief DATA BITS :
                      --! データ(I_DATA/O_DATA/Q_DATA)のビット幅を指定する.
                      integer :=  32
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
        I_ENABLE    : --! @brief INPUT ENABLE :
                      --! 入力許可信号.
                      in  std_logic;
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
                      out std_logic;
        O_RDY       : --! @brief OUTPUT READY :
                      --! 出力可能信号.
                      in  std_logic
    );
end QUEUE_RECEIVER;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
architecture RTL of QUEUE_RECEIVER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    subtype  QUEUE_DATA_TYPE    is std_logic_vector(DATA_BITS-1 downto 0);
    constant QUEUE_DATA_NULL    :  std_logic_vector(DATA_BITS-1 downto 0) := (others => '0');
    type     QUEUE_DATA_VECTOR  is array (natural range <>) of QUEUE_DATA_TYPE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant INTAKE_OF_QUEUE    :  integer := 0;
    constant FIRST_OF_QUEUE     :  integer := 1;
    constant LAST_OF_QUEUE      :  integer := QUEUE_SIZE;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   regs_queue_data    :  QUEUE_DATA_VECTOR(FIRST_OF_QUEUE  to LAST_OF_QUEUE);
    signal   regs_queue_valid   :  std_logic_vector (FIRST_OF_QUEUE  to LAST_OF_QUEUE);
    signal   regs_queue_load    :  std_logic_vector (FIRST_OF_QUEUE  to LAST_OF_QUEUE);
    signal   next_queue_valid   :  std_logic_vector (FIRST_OF_QUEUE  to LAST_OF_QUEUE);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   curr_queue_data    :  QUEUE_DATA_VECTOR(INTAKE_OF_QUEUE to LAST_OF_QUEUE);
    signal   curr_queue_valid   :  std_logic_vector (INTAKE_OF_QUEUE to LAST_OF_QUEUE);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   outlet_data        :  QUEUE_DATA_TYPE;
    signal   outlet_select      :  std_logic_vector (INTAKE_OF_QUEUE to LAST_OF_QUEUE);
    signal   outlet_valid       :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal   intake_data        :  QUEUE_DATA_TYPE;
    signal   intake_valid       :  std_logic;
    signal   intake_ready       :  std_logic;
    signal   dup_i_rdy          :  std_logic;
    signal   next_intake_ready  :  std_logic;
begin
    -------------------------------------------------------------------------------
    -- 入力側の入力信号はすべて一度レジスタで受ける.
    -- 入力側の出力信号はレジスタで叩いてから出力する.
    -------------------------------------------------------------------------------
    INTAKE: block
    begin
        process (CLK, RST) begin
            if (RST = '1') then
                    intake_data  <= QUEUE_DATA_NULL;
                    intake_valid <= '0';
                    I_RDY        <= '0';
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    intake_data  <= QUEUE_DATA_NULL;
                    intake_valid <= '0';
                    I_RDY        <= '0';
                else
                    intake_data  <= I_DATA;
                    intake_valid <= I_VAL;
                    I_RDY        <= next_intake_ready;
                end if;
            end if;
        end process;
    end block;
    -------------------------------------------------------------------------------
    -- 出力した I_RDY を再度レジスタで叩いて入力側にフィードバックする.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                intake_ready <= '0';
                dup_i_rdy    <= '0';
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                intake_ready <= '0';
                dup_i_rdy    <= '0';
            else
                intake_ready <= dup_i_rdy;
                dup_i_rdy    <= next_intake_ready;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- 後々のために、レジスタに格納されているDATA/VALIDと入力されたDATA/VALIDを
    -- 組み合わせておく.
    -------------------------------------------------------------------------------
    curr_queue_data (INTAKE_OF_QUEUE) <= intake_data;
    curr_queue_valid(INTAKE_OF_QUEUE) <= intake_valid and intake_ready;
    curr_queue_data (FIRST_OF_QUEUE to LAST_OF_QUEUE) <= regs_queue_data (FIRST_OF_QUEUE to LAST_OF_QUEUE);
    curr_queue_valid(FIRST_OF_QUEUE to LAST_OF_QUEUE) <= regs_queue_valid(FIRST_OF_QUEUE to LAST_OF_QUEUE);
    -------------------------------------------------------------------------------
    -- outlet_valid  : 出力すべきDATAがある事を示す信号.
    -- outlet_select : 出力すべきDATAの位置を one_hot で表現した信号.
    -------------------------------------------------------------------------------
    process (curr_queue_valid)
        constant VALID_ALL_0 :  std_logic_vector(INTAKE_OF_QUEUE to LAST_OF_QUEUE) := (others => '0');
    begin
        for i in outlet_select'range loop
            if    (i = LAST_OF_QUEUE) then
                if (curr_queue_valid(i) = '1') then
                    outlet_select(i) <= '1';
                else
                    outlet_select(i) <= '0';
                end if;
            else
                if (curr_queue_valid(i) = '1' and curr_queue_valid(i+1) = '0') then
                    outlet_select(i) <= '1';
                else
                    outlet_select(i) <= '0';
                end if;
            end if;
        end loop;
        if (curr_queue_valid /= VALID_ALL_0) then
            outlet_valid <= '1';
        else
            outlet_valid <= '0';
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- next_queue_valid : 次のクロックでの regs_queue_valid 信号の値.
    -- regs_queue_load  : 次のクロックで regs_queue_data を前段からロードするか否か
    --                    を示す信号.
    -------------------------------------------------------------------------------
    process (curr_queue_valid, outlet_select, outlet_valid, O_RDY)
        variable  after_outlet_valid  :  std_logic_vector(INTAKE_OF_QUEUE to LAST_OF_QUEUE);
    begin 
        if (outlet_valid = '1' and O_RDY = '1') then
            after_outlet_valid := curr_queue_valid and not outlet_select;
        else
            after_outlet_valid := curr_queue_valid;
        end if;
        for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
            if (curr_queue_valid(INTAKE_OF_QUEUE) = '1') then
                if (after_outlet_valid(i-1) = '1') then
                    next_queue_valid(i) <= '1';
                    regs_queue_load(i)  <= '1';
                else
                    next_queue_valid(i) <= '0';
                    regs_queue_load(i)  <= '0';
                end if;
            else
                if (after_outlet_valid(i) = '1') then
                    next_queue_valid(i) <= '1';
                    regs_queue_load(i)  <= '0';
                else
                    next_queue_valid(i) <= '0';
                    regs_queue_load(i)  <= '0';
                end if;
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- 次のクロックでの I_RDY の値を生成する.
    -------------------------------------------------------------------------------
    next_intake_ready <= '1' when (next_queue_valid(LAST_OF_QUEUE-1) = '0' and I_ENABLE = '1') else '0';
    -------------------------------------------------------------------------------
    -- DATA/VALID 情報をレジスタに保存する.
    -------------------------------------------------------------------------------
    process (CLK, RST) begin
        if (RST = '1') then
                regs_queue_valid <= (others => '0');
                regs_queue_data  <= (others => QUEUE_DATA_NULL);
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                regs_queue_valid <= (others => '0');
                regs_queue_data  <= (others => QUEUE_DATA_NULL);
            else
                regs_queue_valid <= next_queue_valid;
                for i in FIRST_OF_QUEUE to LAST_OF_QUEUE loop
                    if (regs_queue_load(i) = '1') then
                        regs_queue_data(i) <= curr_queue_data(i-1);
                    end if;
                end loop;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- curr_queue_data から outlet_select で指定された位置のデータを選択する.
    -------------------------------------------------------------------------------
    process (curr_queue_data, outlet_select)
        variable  bit_vec : std_logic_vector(curr_queue_data'range);
        function  or_reduce(Arg : std_logic_vector) return std_logic is
            variable result : std_logic;
        begin
            result := '0';
            for i in Arg'range loop
                result := result or Arg(i);
            end loop;
            return result;
        end function;
    begin
        for bit_pos in QUEUE_DATA_TYPE'range loop
            for queue_num in curr_queue_data'range loop
                bit_vec(queue_num) := curr_queue_data(queue_num)(bit_pos);
            end loop;
            outlet_data(bit_pos) <= or_reduce(bit_vec and outlet_select);
        end loop;
    end process;
    -------------------------------------------------------------------------------
    -- O_DATA/O_VAL の出力
    -------------------------------------------------------------------------------
    O_DATA <= outlet_data;
    O_VAL  <= outlet_valid;
end RTL;
