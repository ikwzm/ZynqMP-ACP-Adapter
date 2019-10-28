-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_response_queue.vhd
--!     @brief   ZynqMP ACP Response Queue
--!     @version 0.1.0
--!     @date    2019/10/28
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
    signal    intake_valid  :  boolean;
    signal    intake_ready  :  boolean;
    signal    intake_last   :  boolean;
    signal    intake_id     :  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    outlet_valid  :  boolean;
    signal    outlet_ready  :  boolean;
    signal    outlet_last   :  boolean;
    signal    outlet_empty  :  boolean;
    signal    outlet_flush  :  boolean;
    signal    outlet_id     :  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal    outlet_count  :  integer range 0 to COUNT_MAX;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    intake_valid <= I_VALID;
    intake_last  <= I_LAST;
    intake_id    <= I_ID;
    I_READY      <= intake_ready;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    intake_ready <= (outlet_flush = FALSE) or
                    (outlet_last  = TRUE and outlet_valid = TRUE and outlet_ready = TRUE);
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(CLK, RST)
        variable  next_count :  integer range 0 to COUNT_MAX;
        variable  next_flush :  boolean;
        variable  next_empty :  boolean;
    begin
        if (RST = '1') then
                outlet_valid <= FALSE;
                outlet_empty <= TRUE;
                outlet_flush <= FALSE;
                outlet_last  <= FALSE;
                outlet_count <= 0;
                outlet_id    <= (others => '0');
        elsif (CLK'event and CLK = '1') then
            if (CLR = '1') then
                outlet_valid <= FALSE;
                outlet_empty <= FALSE;
                outlet_flush <= TRUE;
                outlet_last  <= FALSE;
                outlet_count <=  0 ;
                outlet_id    <= (others => '0');
            else
                next_count   := outlet_count;
                next_flush   := outlet_flush;
                next_empty   := outlet_empty;
                if (intake_valid and intake_ready) then
                    if (outlet_flush or outlet_empty) then
                        next_count := 1;
                        outlet_id  <= intake_id;
                    else
                        next_count := next_count + 1;
                    end if;
                    next_empty := (outlet_flush = TRUE);
                    next_flush := (intake_last  = TRUE);
                end if;
                if (outlet_valid and outlet_ready) then
                    next_count := next_count - 1;
                end if;
                outlet_count <= next_count;
                outlet_flush <= next_flush;
                outlet_empty <= next_empty;
                outlet_last  <= (next_count = 1 and next_flush);
                outlet_valid <= (next_count > 0);
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    Q_ID    <= outlet_id;
    Q_VALID <= outlet_valid;
    Q_LAST  <= outlet_last;
    outlet_ready <= Q_READY;
end RTL;
