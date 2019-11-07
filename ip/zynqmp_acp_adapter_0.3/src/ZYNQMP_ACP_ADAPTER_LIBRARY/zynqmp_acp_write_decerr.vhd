-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_write_decerr.vhd
--!     @brief   ZynqMP ACP Write Decode Error
--!     @version 0.3.0
--!     @date    2019/11/6
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
entity  ZYNQMP_ACP_WRITE_DECERR is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        AXI_ADDR_WIDTH      : --! @brief AXI ADDRRESS WIDTH :
                              integer := 64;
        AXI_DATA_WIDTH      : --! @brief AXI DATA WIDTH :
                              integer := 128;
        AXI_ID_WIDTH        : --! @brief AXI ID WIDTH :
                              integer := 6
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock / Reset Signals.
    -------------------------------------------------------------------------------
        ACLK                : in  std_logic;
        ARESETn             : in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_AWID            : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_AWADDR          : in  std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_AWLEN           : in  std_logic_vector(7 downto 0);
        AXI_AWSIZE          : in  std_logic_vector(2 downto 0);
        AXI_AWBURST         : in  std_logic_vector(1 downto 0);
        AXI_AWLOCK          : in  std_logic_vector(0 downto 0);
        AXI_AWCACHE         : in  std_logic_vector(3 downto 0);
        AXI_AWPROT          : in  std_logic_vector(2 downto 0);
        AXI_AWQOS           : in  std_logic_vector(3 downto 0);
        AXI_AWREGION        : in  std_logic_vector(3 downto 0);
        AXI_AWVALID         : in  std_logic;
        AXI_AWREADY         : out std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_WDATA           : in  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        AXI_WSTRB           : in  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        AXI_WLAST           : in  std_logic;
        AXI_WVALID          : in  std_logic;
        AXI_WREADY          : out std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        AXI_BID             : out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_BRESP           : out std_logic_vector(1 downto 0);
        AXI_BVALID          : out std_logic;
        AXI_BREADY          : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP Write Address Channel Signals.
    -------------------------------------------------------------------------------
        ACP_AWID            : out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        ACP_AWADDR          : out std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        ACP_AWLEN           : out std_logic_vector(7 downto 0);
        ACP_AWSIZE          : out std_logic_vector(2 downto 0);
        ACP_AWBURST         : out std_logic_vector(1 downto 0);
        ACP_AWLOCK          : out std_logic_vector(0 downto 0);
        ACP_AWCACHE         : out std_logic_vector(3 downto 0);
        ACP_AWPROT          : out std_logic_vector(2 downto 0);
        ACP_AWQOS           : out std_logic_vector(3 downto 0);
        ACP_AWREGION        : out std_logic_vector(3 downto 0);
        ACP_AWVALID         : out std_logic;
        ACP_AWREADY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP Write Data Channel Signals.
    -------------------------------------------------------------------------------
        ACP_WDATA           : out std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        ACP_WSTRB           : out std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        ACP_WLAST           : out std_logic;
        ACP_WVALID          : out std_logic;
        ACP_WREADY          : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP Write Response Channel Signals.
    -------------------------------------------------------------------------------
        ACP_BID             : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        ACP_BRESP           : in  std_logic_vector(1 downto 0);
        ACP_BVALID          : in  std_logic;
        ACP_BREADY          : out std_logic
    );
end  ZYNQMP_ACP_WRITE_DECERR;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of ZYNQMP_ACP_WRITE_DECERR is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    reset         :  std_logic;
    constant  clear         :  std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE    is (IDLE_STATE, DATA_STATE, RESP_STATE);
    signal    curr_state    :  STATE_TYPE;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    reset <= '0' when (ARESETN = '1') else '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset) begin
        if (reset = '1') then
                curr_state <= IDLE_STATE;
                AXI_BID    <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                curr_state <= IDLE_STATE;
                AXI_BID    <= (others => '0');
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (AXI_AWVALID = '1') then
                            curr_state <= DATA_STATE;
                            AXI_BID    <= AXI_AWID;
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when DATA_STATE =>
                        if (AXI_WVALID = '1' and AXI_WLAST = '1') then
                            curr_state <= RESP_STATE;
                        else
                            curr_state <= DATA_STATE;
                        end if;
                    when RESP_STATE =>
                        if (AXI_BREADY = '1') then
                            curr_state <= IDLE_STATE;
                        else
                            curr_state <= RESP_STATE;
                        end if;
                    when others =>
                            curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    AXI_AWREADY  <= '1' when (curr_state = IDLE_STATE) else '0';
    AXI_WREADY   <= '1' when (curr_state = DATA_STATE) else '0';
    AXI_BVALID   <= '1' when (curr_state = RESP_STATE) else '0';
    AXI_BRESP    <= "11";
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ACP_AWID     <= (others => '0');
    ACP_AWADDR   <= (others => '0');
    ACP_AWLEN    <= (others => '0');
    ACP_AWSIZE   <= (others => '0');
    ACP_AWBURST  <= (others => '0');
    ACP_AWLOCK   <= (others => '0');
    ACP_AWCACHE  <= (others => '0');
    ACP_AWPROT   <= (others => '0');
    ACP_AWQOS    <= (others => '0');
    ACP_AWREGION <= (others => '0');
    ACP_AWVALID  <= '0';
    ACP_WDATA    <= (others => '0');
    ACP_WSTRB    <= (others => '0');
    ACP_WLAST    <= '0';
    ACP_WVALID   <= '0';
    ACP_BREADY   <= '0';
end RTL;
