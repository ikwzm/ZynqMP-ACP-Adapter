-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_adapter.vhd
--!     @brief   ZynqMP ACP Adapter
--!     @version 0.4.0
--!     @date    2019/11/10
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
entity  ZYNQMP_ACP_ADAPTER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        READ_ENABLE         : --! @brief ZYNQMP ACP READ ADAPTER ENABLE :
                              integer range 0 to 1 := 1;
        WRITE_ENABLE        : --! @brief ZYNQMP ACP WRITE ADAPTER ENABLE :
                              integer range 0 to 1 := 1;
        AXI_ADDR_WIDTH      : --! @brief AXI ADDRRESS WIDTH :
                              integer := 64;
        AXI_DATA_WIDTH      : --! @brief AXI DATA WIDTH :
                              integer range 128 to 128 := 128;
        AXI_ID_WIDTH        : --! @brief AXI ID WIDTH :
                              integer := 6;
        RRESP_QUEUE_SIZE    : --! @brief READ  RESPONSE QUEUE SIZE :
                              integer range 1 to 8  := 2;
        RDATA_QUEUE_SIZE    : --! @brief READ  DATA QUEUE SIZE :
                              integer range 1 to 4  := 2;
        RDATA_INTAKE_REGS   : --! @brief READ  DATA INTAKE REGISTER :
                              integer range 0 to 1  := 0;
        WRESP_QUEUE_SIZE    : --! @brief WRITE RESPONSE QUEUE SIZE :
                              integer range 1 to 8  := 2;
        WDATA_QUEUE_SIZE    : --! @brief WRITE DATA QUEUE SIZE :
                              integer range 4 to 32 := 16;
        WDATA_OUTLET_REGS   : --! @brief DATA OUTLET REGSITER :
                              integer range 0 to 8  := 5;
        WDATA_INTAKE_REGS   : --! @brief DATA INTAKE REGSITER :
                              integer range 0 to 1  := 0
    );
    port(
    -------------------------------------------------------------------------------
    -- Clock / Reset Signals.
    -------------------------------------------------------------------------------
        ACLK                : in  std_logic;
        ARESETn             : in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        AXI_ARID            : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_ARADDR          : in  std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_ARLEN           : in  std_logic_vector(7 downto 0);
        AXI_ARSIZE          : in  std_logic_vector(2 downto 0);
        AXI_ARBURST         : in  std_logic_vector(1 downto 0);
        AXI_ARLOCK          : in  std_logic_vector(0 downto 0);
        AXI_ARCACHE         : in  std_logic_vector(3 downto 0);
        AXI_ARPROT          : in  std_logic_vector(2 downto 0);
        AXI_ARQOS           : in  std_logic_vector(3 downto 0);
        AXI_ARREGION        : in  std_logic_vector(3 downto 0);
        AXI_ARVALID         : in  std_logic;
        AXI_ARREADY         : out std_logic;
    -------------------------------------------------------------------------------
    -- AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        AXI_RID             : out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        AXI_RDATA           : out std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        AXI_RRESP           : out std_logic_vector(1 downto 0);
        AXI_RLAST           : out std_logic;
        AXI_RVALID          : out std_logic;
        AXI_RREADY          : in  std_logic;
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
    -- ZynqMP ACP Read Address Channel Signals.
    -------------------------------------------------------------------------------
        ACP_ARID            : out std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        ACP_ARADDR          : out std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        ACP_ARLEN           : out std_logic_vector(7 downto 0);
        ACP_ARSIZE          : out std_logic_vector(2 downto 0);
        ACP_ARBURST         : out std_logic_vector(1 downto 0);
        ACP_ARLOCK          : out std_logic_vector(0 downto 0);
        ACP_ARCACHE         : out std_logic_vector(3 downto 0);
        ACP_ARPROT          : out std_logic_vector(2 downto 0);
        ACP_ARQOS           : out std_logic_vector(3 downto 0);
        ACP_ARREGION        : out std_logic_vector(3 downto 0);
        ACP_ARVALID         : out std_logic;
        ACP_ARREADY         : in  std_logic;
    -------------------------------------------------------------------------------
    -- ZynqMP ACP AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        ACP_RID             : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0);
        ACP_RDATA           : in  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        ACP_RRESP           : in  std_logic_vector(1 downto 0);
        ACP_RLAST           : in  std_logic;
        ACP_RVALID          : in  std_logic;
        ACP_RREADY          : out std_logic;
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
end  ZYNQMP_ACP_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library ZYNQMP_ACP_ADAPTER_LIBRARY;
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.ZYNQMP_ACP_READ_ADAPTER;
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.ZYNQMP_ACP_WRITE_ADAPTER;
architecture RTL of ZYNQMP_ACP_ADAPTER is
begin
    -------------------------------------------------------------------------------
    -- ZYNQMP_ACP_READ_ADAPTER 
    -------------------------------------------------------------------------------
    R: if (READ_ENABLE /= 0) generate                        -- 
        ADAPTER: ZYNQMP_ACP_READ_ADAPTER                     -- 
            generic map (                                    -- 
                AXI_ADDR_WIDTH      => AXI_ADDR_WIDTH      , -- 
                AXI_DATA_WIDTH      => AXI_DATA_WIDTH      , -- 
                AXI_ID_WIDTH        => AXI_ID_WIDTH        , --
                RESP_QUEUE_SIZE     => RRESP_QUEUE_SIZE    , --
                DATA_QUEUE_SIZE     => RDATA_QUEUE_SIZE    , --
                DATA_INTAKE_REGS    => RDATA_INTAKE_REGS     -- 
            )                                                -- 
            port map(                                        -- 
            ----------------------------------------------------------------------
            -- Clock / Reset Signals.
            ----------------------------------------------------------------------
                ACLK                => ACLK                , -- In  :
                ARESETn             => ARESETn             , -- In  :
            ----------------------------------------------------------------------
            -- AXI4 Read Address Channel Signals.
            ----------------------------------------------------------------------
                AXI_ARID            => AXI_ARID            , -- In  :
                AXI_ARADDR          => AXI_ARADDR          , -- In  :
                AXI_ARLEN           => AXI_ARLEN           , -- In  :
                AXI_ARSIZE          => AXI_ARSIZE          , -- In  :
                AXI_ARBURST         => AXI_ARBURST         , -- In  :
                AXI_ARLOCK          => AXI_ARLOCK          , -- In  :
                AXI_ARCACHE         => AXI_ARCACHE         , -- In  :
                AXI_ARPROT          => AXI_ARPROT          , -- In  :
                AXI_ARQOS           => AXI_ARQOS           , -- In  :
                AXI_ARREGION        => AXI_ARREGION        , -- In  :
                AXI_ARVALID         => AXI_ARVALID         , -- In  :
                AXI_ARREADY         => AXI_ARREADY         , -- Out :
            ----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
                AXI_RID             => AXI_RID             , -- Out :
                AXI_RDATA           => AXI_RDATA           , -- Out :
                AXI_RRESP           => AXI_RRESP           , -- Out :
                AXI_RLAST           => AXI_RLAST           , -- Out :
                AXI_RVALID          => AXI_RVALID          , -- Out :
                AXI_RREADY          => AXI_RREADY          , -- In  :
            ----------------------------------------------------------------------
            -- ACP Read Address Channel Signals.
            ----------------------------------------------------------------------
                ACP_ARID            => ACP_ARID            , -- Out :
                ACP_ARADDR          => ACP_ARADDR          , -- Out :
                ACP_ARLEN           => ACP_ARLEN           , -- Out :
                ACP_ARSIZE          => ACP_ARSIZE          , -- Out :
                ACP_ARBURST         => ACP_ARBURST         , -- Out :
                ACP_ARLOCK          => ACP_ARLOCK          , -- Out :
                ACP_ARCACHE         => ACP_ARCACHE         , -- Out :
                ACP_ARPROT          => ACP_ARPROT          , -- Out :
                ACP_ARQOS           => ACP_ARQOS           , -- Out :
                ACP_ARREGION        => ACP_ARREGION        , -- Out :
                ACP_ARVALID         => ACP_ARVALID         , -- Out :
                ACP_ARREADY         => ACP_ARREADY         , -- In  :
            ----------------------------------------------------------------------
            -- ZynqMP ACP Read Data Channel Signals.
            ----------------------------------------------------------------------
                ACP_RID             => ACP_RID             , -- In  :
                ACP_RDATA           => ACP_RDATA           , -- In  :
                ACP_RRESP           => ACP_RRESP           , -- In  :
                ACP_RLAST           => ACP_RLAST           , -- In  :
                ACP_RVALID          => ACP_RVALID          , -- In  :
                ACP_RREADY          => ACP_RREADY            -- Out :
            );
    end generate;
    -------------------------------------------------------------------------------
    -- READ  DECERR
    -------------------------------------------------------------------------------
    R_DECERR: if (READ_ENABLE = 0) generate
        type      STATE_TYPE    is (IDLE_STATE, RESP_STATE);
        signal    curr_state    :  STATE_TYPE;
        signal    reset         :  std_logic;
        constant  clear         :  std_logic := '0';
    begin
        reset <= '0' when (ARESETN = '1') else '1';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process(ACLK, reset) begin
            if (reset = '1') then
                    curr_state <= IDLE_STATE;
                    AXI_RID    <= (others => '0');
            elsif (ACLK'event and ACLK = '1') then
                if (clear = '1') then
                    curr_state <= IDLE_STATE;
                    AXI_RID    <= (others => '0');
                else
                    case curr_state is
                        when IDLE_STATE =>
                            if (AXI_ARVALID = '1') then
                                curr_state <= RESP_STATE;
                                AXI_RID    <= AXI_ARID;
                            else
                                curr_state <= IDLE_STATE;
                            end if;
                        when RESP_STATE =>
                            if (AXI_RREADY = '1') then
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
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        AXI_ARREADY  <= '1' when (curr_state = IDLE_STATE) else '0';
        AXI_RVALID   <= '1' when (curr_state = RESP_STATE) else '0';
        AXI_RLAST    <= '1';
        AXI_RRESP    <= "11";
        AXI_RDATA    <= (others => '0');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ACP_ARID     <= (others => '0');
        ACP_ARADDR   <= (others => '0');
        ACP_ARLEN    <= (others => '0');
        ACP_ARSIZE   <= (others => '0');
        ACP_ARBURST  <= (others => '0');
        ACP_ARLOCK   <= (others => '0');
        ACP_ARCACHE  <= (others => '0');
        ACP_ARPROT   <= (others => '0');
        ACP_ARQOS    <= (others => '0');
        ACP_ARREGION <= (others => '0');
        ACP_ARVALID  <= '0';
        ACP_RREADY   <= '1';
    end generate;
    -------------------------------------------------------------------------------
    -- ZYNQMP_ACP_WRITE_ADAPTER
    -------------------------------------------------------------------------------
    W: if (WRITE_ENABLE /= 0) generate
        ADAPTER: ZYNQMP_ACP_WRITE_ADAPTER                    -- 
            generic map (                                    -- 
                AXI_ADDR_WIDTH      => AXI_ADDR_WIDTH      , -- 
                AXI_DATA_WIDTH      => AXI_DATA_WIDTH      , -- 
                AXI_ID_WIDTH        => AXI_ID_WIDTH        , -- 
                RESP_QUEUE_SIZE     => WRESP_QUEUE_SIZE    , -- 
                DATA_QUEUE_SIZE     => WDATA_QUEUE_SIZE    , -- 
                DATA_OUTLET_REGS    => WDATA_OUTLET_REGS   , -- 
                DATA_INTAKE_REGS    => WDATA_INTAKE_REGS     -- 
            )                                                -- 
            port map(                                        -- 
            -----------------------------------------------------------------------
            -- Clock / Reset Signals.
            -----------------------------------------------------------------------
                ACLK                => ACLK                , -- In  :
                ARESETn             => ARESETn             , -- In  :
            -----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            -----------------------------------------------------------------------
                AXI_AWID            => AXI_AWID            , -- In  :
                AXI_AWADDR          => AXI_AWADDR          , -- In  :
                AXI_AWLEN           => AXI_AWLEN           , -- In  :
                AXI_AWSIZE          => AXI_AWSIZE          , -- In  :
                AXI_AWBURST         => AXI_AWBURST         , -- In  :
                AXI_AWLOCK          => AXI_AWLOCK          , -- In  :
                AXI_AWCACHE         => AXI_AWCACHE         , -- In  :
                AXI_AWPROT          => AXI_AWPROT          , -- In  :
                AXI_AWQOS           => AXI_AWQOS           , -- In  :
                AXI_AWREGION        => AXI_AWREGION        , -- In  :
                AXI_AWVALID         => AXI_AWVALID         , -- In  :
                AXI_AWREADY         => AXI_AWREADY         , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            -----------------------------------------------------------------------
                AXI_WDATA           => AXI_WDATA           , -- In  :
                AXI_WSTRB           => AXI_WSTRB           , -- In  :
                AXI_WLAST           => AXI_WLAST           , -- In  :
                AXI_WVALID          => AXI_WVALID          , -- In  :
                AXI_WREADY          => AXI_WREADY          , -- Out :
            -----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            -----------------------------------------------------------------------
                AXI_BID             => AXI_BID             , -- Out :
                AXI_BRESP           => AXI_BRESP           , -- Out :
                AXI_BVALID          => AXI_BVALID          , -- Out :
                AXI_BREADY          => AXI_BREADY          , -- In  :
            -----------------------------------------------------------------------
            -- ZynqMP ACP  Write Address Channel Signals.
            -----------------------------------------------------------------------
                ACP_AWID            => ACP_AWID            , -- Out :
                ACP_AWADDR          => ACP_AWADDR          , -- Out :
                ACP_AWLEN           => ACP_AWLEN           , -- Out :
                ACP_AWSIZE          => ACP_AWSIZE          , -- Out :
                ACP_AWBURST         => ACP_AWBURST         , -- Out :
                ACP_AWLOCK          => ACP_AWLOCK          , -- Out :
                ACP_AWCACHE         => ACP_AWCACHE         , -- Out :
                ACP_AWPROT          => ACP_AWPROT          , -- Out :
                ACP_AWQOS           => ACP_AWQOS           , -- Out :
                ACP_AWREGION        => ACP_AWREGION        , -- Out :
                ACP_AWVALID         => ACP_AWVALID         , -- Out :
                ACP_AWREADY         => ACP_AWREADY         , -- In  :
            -----------------------------------------------------------------------
            -- ZynqMP ACP Write Data Channel Signals.
            -----------------------------------------------------------------------
                ACP_WDATA           => ACP_WDATA           , -- Out :
                ACP_WSTRB           => ACP_WSTRB           , -- Out :
                ACP_WLAST           => ACP_WLAST           , -- Out :
                ACP_WVALID          => ACP_WVALID          , -- Out :
                ACP_WREADY          => ACP_WREADY          , -- In  :
            -----------------------------------------------------------------------
            -- ZynqMP ACP Write Response Channel Signals.
            -----------------------------------------------------------------------
                ACP_BID             => ACP_BID             , -- In  :
                ACP_BRESP           => ACP_BRESP           , -- In  :
                ACP_BVALID          => ACP_BVALID          , -- In  :
                ACP_BREADY          => ACP_BREADY            -- Out :
           );
    end generate;
    -------------------------------------------------------------------------------
    -- ZYNQMP_ACP_WRITE_DECERR
    -------------------------------------------------------------------------------
    W_DECERR: if (WRITE_ENABLE = 0) generate
        type      STATE_TYPE    is (IDLE_STATE, DATA_STATE, RESP_STATE);
        signal    curr_state    :  STATE_TYPE;
        signal    reset         :  std_logic;
        constant  clear         :  std_logic := '0';
    begin 
        reset <= '0' when (ARESETN = '1') else '1';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        AXI_AWREADY  <= '1' when (curr_state = IDLE_STATE) else '0';
        AXI_WREADY   <= '1' when (curr_state = DATA_STATE) else '0';
        AXI_BVALID   <= '1' when (curr_state = RESP_STATE) else '0';
        AXI_BRESP    <= "11";
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
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
    end generate;
end RTL;
