-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_response_queue.vhd
--!     @brief   ZynqMP ACP Response Queue
--!     @version 0.5.1
--!     @date    2021/1/11
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019-2021 Ichiro Kawazome
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
--! @brief 
-----------------------------------------------------------------------------------
entity  ZYNQMP_ACP_RESPONSE_QUEUE is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        AXI_ID_WIDTH        : --! @brief AXI ID WIDTH :
                              integer := 6;
        QUEUE_SIZE          : --! @brief QUEU SIZE :
                              integer := 1
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock / Reset Signals.
    -------------------------------------------------------------------------------
        CLK                 : in  std_logic;
        RST                 : in  std_logic;
        CLR                 : in  std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
        I_ID                : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        I_LAST              : in  boolean;
        I_VALID             : in  boolean;
        I_READY             : out boolean;
        I_ANOTHER_ID        : out boolean;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
        Q_ID                : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
        Q_LAST              : out boolean;
        Q_VALID             : out boolean;
        Q_READY             : in  boolean
    );
end ZYNQMP_ACP_RESPONSE_QUEUE;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of ZYNQMP_ACP_RESPONSE_QUEUE is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    constant  COUNT_MAX     :  integer := 4096/16;  -- (4Kbyte / 128bit)
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE    is record
              count         :  integer range 0 to COUNT_MAX;
              id            :  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
              flush         :  boolean;
              valid         :  boolean;
    end record;
    type      STATE_VECTOR  is array (integer range <>) of STATE_TYPE;
    constant  NULL_STATE    :  STATE_TYPE := (
                                   count => 0,
                                   id    => (others => '0'),
                                   flush => FALSE,
                                   valid => FALSE
                               );
    constant  TOP_OF_QUEUE  :  integer := 0;
    constant  END_OF_QUEUE  :  integer := QUEUE_SIZE-1;
    signal    curr_queue    :  STATE_VECTOR(TOP_OF_QUEUE to END_OF_QUEUE);
    signal    next_queue    :  STATE_VECTOR(TOP_OF_QUEUE to END_OF_QUEUE);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    intake_ready  :  boolean;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    outlet_valid  :  boolean;
    signal    outlet_ready  :  boolean;
    signal    outlet_last   :  boolean;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (curr_queue, I_VALID, I_LAST, I_ID, intake_ready, outlet_valid, outlet_ready, outlet_last)
        variable  temp_queue    :  STATE_VECTOR(TOP_OF_QUEUE to END_OF_QUEUE);
        variable  i_enable      :  boolean;
    begin
        if (outlet_valid and outlet_ready) then
            if (outlet_last) then
                for i in TOP_OF_QUEUE to END_OF_QUEUE loop
                    if (i = END_OF_QUEUE) then
                        temp_queue(i) := NULL_STATE;
                    else
                        temp_queue(i) := curr_queue(i+1);
                    end if;
                end loop;
            else
                for i in TOP_OF_QUEUE to END_OF_QUEUE loop
                    temp_queue(i) := curr_queue(i);
                    if (i = TOP_OF_QUEUE) then
                        temp_queue(i).count := curr_queue(i).count - 1;
                    end if;
                end loop;
            end if;
        else
            temp_queue := curr_queue;
        end if;
        for i in TOP_OF_QUEUE to END_OF_QUEUE loop
            if (i = TOP_OF_QUEUE) then
                i_enable := (temp_queue(i).flush = FALSE);
            else
                i_enable := (temp_queue(i).flush = FALSE and temp_queue(i-1).flush = TRUE);
            end if;
            if (i_enable and I_VALID and intake_ready) then
                if (temp_queue(i).valid = FALSE) then
                    next_queue(i).count <= 1;
                    next_queue(i).id    <= I_ID;
                    next_queue(i).flush <= (I_LAST = TRUE);
                    next_queue(i).valid <= TRUE;
                else
                    next_queue(i).count <= temp_queue(i).count + 1;
                    next_queue(i).id    <= temp_queue(i).id;
                    next_queue(i).flush <= (I_LAST = TRUE);
                    next_queue(i).valid <= TRUE;
                end if;
            else
                    next_queue(i).count <= temp_queue(i).count;
                    next_queue(i).id    <= temp_queue(i).id;
                    next_queue(i).flush <= temp_queue(i).flush;
                    next_queue(i).valid <= temp_queue(i).valid;
            end if;
        end loop;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (curr_queue, I_ID)
        variable  another_id_queued :  boolean;
    begin
        another_id_queued := FALSE;
        for i in TOP_OF_QUEUE to END_OF_QUEUE loop
            if (curr_queue(i).valid and curr_queue(i).id /= I_ID) then
                another_id_queued := another_id_queued or TRUE;
            end if;
        end loop;
        I_ANOTHER_ID <= another_id_queued;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    I_READY <= intake_ready;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(CLK, RST)
    begin
        if (RST = '1') then
                curr_queue   <= (others => NULL_STATE);
                intake_ready <= FALSE;
                outlet_valid <= FALSE;
                outlet_last  <= FALSE;
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                curr_queue   <= (others => NULL_STATE);
                intake_ready <= FALSE;
                outlet_valid <= FALSE;
                outlet_last  <= FALSE;
            else
                curr_queue   <= next_queue;
                intake_ready <= ((next_queue(END_OF_QUEUE).flush = FALSE));
                outlet_valid <= ((next_queue(TOP_OF_QUEUE).count > 0    ) and
                                 (next_queue(TOP_OF_QUEUE).valid = TRUE ));
                outlet_last  <= ((next_queue(TOP_OF_QUEUE).count = 1) and
                                 (next_queue(TOP_OF_QUEUE).flush = TRUE ));
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Q_ID    <= curr_queue(TOP_OF_QUEUE).id;
    Q_VALID <= outlet_valid;
    Q_LAST  <= outlet_last;
    outlet_ready <= Q_READY;
end RTL;
