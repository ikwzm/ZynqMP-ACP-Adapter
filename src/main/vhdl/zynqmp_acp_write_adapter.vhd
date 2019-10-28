-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_write_adapter.vhd
--!     @brief   ZynqMP ACP Write Adapter
--!     @version 0.1.0
--!     @date    2019/10/25
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
entity  ZYNQMP_ACP_WRITE_ADAPTER is
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
end  ZYNQMP_ACP_WRITE_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PipeWork;
use     PipeWork.Components.QUEUE_RECEIVER;
use     PipeWork.Components.QUEUE_REGISTER;
architecture RTL of ZYNQMP_ACP_WRITE_ADAPTER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    reset         :  std_logic;
    constant  clear         :  std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE    is (IDLE_STATE, CAlC_STATE, ADDR_STATE);
    signal    curr_state    :  STATE_TYPE;
    signal    xfer_id       :  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal    xfer_start    :  boolean;
    signal    xfer_ready    :  boolean;
    signal    xfer_first    :  boolean;
    signal    xfer_last     :  boolean;
    signal    xfer_len      :  unsigned( 8 downto 0);
    signal    remain_len    :  unsigned( 8 downto 0);
    signal    byte_pos      :  unsigned( 3 downto 0);
    signal    word_pos      :  unsigned(11 downto 4);
    signal    page_num      :  unsigned(AXI_ADDR_WIDTH-1 downto 12);
    signal    resp_last     :  boolean;
    signal    resp_valid    :  boolean;
    signal    resp_ready    :  boolean;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    component ZYNQMP_ACP_RESPONSE_QUEUE 
        generic (
            AXI_ID_WIDTH    :  integer := 6;
            QUEUE_SIZE      :  integer := 1
        );
        port(
            CLK             : in  std_logic;
            RST             : in  std_logic;
            CLR             : in  std_logic;
            I_ID            : in  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            I_LAST          : in  boolean;
            I_VALID         : in  boolean;
            I_READY         : out boolean;
            Q_ID            : out std_logic_vector(AXI_ID_WIDTH-1 downto 0);
            Q_LAST          : out boolean;
            Q_VALID         : out boolean;
            Q_READY         : in  boolean
        );
    end component;
begin
    reset <= '0' when (ARESETN = '1') else '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset)
        variable len        :  unsigned( 8 downto 0);
    begin
        if (reset = '1') then
                curr_state <= IDLE_STATE;
                xfer_first <= FALSE;
                xfer_last  <= FALSE;
                xfer_id    <= (others => '0');
                remain_len <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                byte_pos   <= (others => '0');
                xfer_len   <= (others => '0');
                ACP_AWLEN  <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                curr_state <= IDLE_STATE;
                xfer_first <= FALSE;
                xfer_last  <= FALSE;
                xfer_id    <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                byte_pos   <= (others => '0');
                xfer_len   <= (others => '0');
                remain_len <= (others => '0');
                ACP_AWLEN  <= (others => '0');
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (AXI_AWVALID = '1') then
                            curr_state <= CALC_STATE;
                            xfer_first <= TRUE;
                            xfer_id    <= AXI_AWID;
                            remain_len <= RESIZE(unsigned(AXI_AWLEN), remain_len'length) + 1;
                            page_num   <= unsigned(AXI_AWADDR(page_num'range));
                            word_pos   <= unsigned(AXI_AWADDR(word_pos'range));
                            byte_pos   <= unsigned(AXI_AWADDR(byte_pos'range));
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when CALC_STATE =>
                        if (xfer_ready) then
                            curr_state <= ADDR_STATE;
                        else
                            curr_state <= CALC_STATE;
                        end if;
                        if (word_pos(5 downto 4) = "00") and (byte_pos = 0) and (remain_len > 4) then
                            len := unsigned'("000000100");
                        else
                            len := unsigned'("000000001");
                        end if;
                        xfer_len  <= len;
                        xfer_last <= (remain_len <= len);
                        ACP_AWLEN <= std_logic_vector(RESIZE(len-1, ACP_AWLEN'length));
                    when ADDR_STATE =>
                        if    (ACP_AWREADY = '1' and xfer_last = TRUE ) then
                            curr_state <= IDLE_STATE;
                        elsif (ACP_AWREADY = '1' and xfer_last = FALSE) then
                            curr_state <= CALC_STATE;
                        else
                            curr_state <= ADDR_STATE;
                        end if;
                        if (ACP_AWREADY = '1') then
                            xfer_first <= FALSE;
                            remain_len <= remain_len - xfer_len;
                            word_pos   <= word_pos   + xfer_len;
                            byte_pos   <= (others => '0');
                        end if;
                    when others =>
                            curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    AXI_AWREADY <= '1' when (curr_state = IDLE_STATE) else '0';
    ACP_AWVALID <= '1' when (curr_state = ADDR_STATE) else '0';
    ACP_AWADDR  <= std_logic_vector(page_num) &
                   std_logic_vector(word_pos) &
                   std_logic_vector(byte_pos);
    ACP_AWID    <= xfer_id;
    xfer_start  <= (curr_state = ADDR_STATE and ACP_AWREADY = '1');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset) begin
        if (reset = '1') then
                ACP_AWSIZE   <= (others => '0');
                ACP_AWBURST  <= (others => '0');
                ACP_AWLOCK   <= (others => '0');
                ACP_AWCACHE  <= (others => '0');
                ACP_AWPROT   <= (others => '0');
                ACP_AWQOS    <= (others => '0');
                ACP_AWREGION <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                ACP_AWSIZE   <= (others => '0');
                ACP_AWBURST  <= (others => '0');
                ACP_AWLOCK   <= (others => '0');
                ACP_AWCACHE  <= (others => '0');
                ACP_AWPROT   <= (others => '0');
                ACP_AWQOS    <= (others => '0');
                ACP_AWREGION <= (others => '0');
            elsif (curr_state = IDLE_STATE and AXI_AWVALID = '1') then
                ACP_AWSIZE   <= AXI_AWSIZE   ;
                ACP_AWBURST  <= AXI_AWBURST  ;
                ACP_AWLOCK   <= AXI_AWLOCK   ;
                ACP_AWCACHE  <= AXI_AWCACHE  ;
                ACP_AWPROT   <= AXI_AWPROT   ;
                ACP_AWQOS    <= AXI_AWQOS    ;
                ACP_AWREGION <= AXI_AWREGION ;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DQ: block
        constant  IPORT_QUEUE   :  boolean := TRUE;
        constant  OPORT_QUEUE   :  boolean := TRUE;
        constant  WDATA_LO      :  integer := 0;
        constant  WDATA_HI      :  integer := WDATA_LO  + AXI_DATA_WIDTH   - 1;
        constant  WSTRB_LO      :  integer := WDATA_HI  + 1;
        constant  WSTRB_HI      :  integer := WSTRB_LO  + AXI_DATA_WIDTH/8 - 1;
        constant  WLAST_POS     :  integer := WSTRB_HI  + 1;
        constant  WORD_BITS     :  integer := WLAST_POS - WDATA_LO         + 1;
        constant  i_enable      :  std_logic := '1';
        signal    i_valid       :  std_logic;
        signal    i_ready       :  std_logic;
        signal    i_data        :  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        signal    i_strb        :  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        signal    i_last        :  std_logic;
        signal    o_valid       :  std_logic;
        signal    o_ready       :  std_logic;
        signal    o_data        :  std_logic_vector(AXI_DATA_WIDTH  -1 downto 0);
        signal    o_strb        :  std_logic_vector(AXI_DATA_WIDTH/8-1 downto 0);
        signal    o_last        :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_data  <= i_data;
        o_strb  <= i_strb;
        o_valid <= i_valid;
        i_ready <= o_ready;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        IPORT: if (IPORT_QUEUE = TRUE) generate
            signal    i_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_word    :  std_logic_vector(WORD_BITS-1 downto 0);
        begin 
            QUEUE: QUEUE_RECEIVER                -- 
                generic map (                    -- 
                    QUEUE_SIZE  => 2           , -- 
                    DATA_BITS   => WORD_BITS     -- 
                )                                -- 
                port map (                       -- 
                    CLK         => ACLK        , -- In  :
                    RST         => reset       , -- In  :
                    CLR         => clear       , -- In  :
                    I_ENABLE    => i_enable    , -- In  :
                    I_DATA      => i_word      , -- In  :
                    I_VAL       => AXI_WVALID  , -- In  :
                    I_RDY       => AXI_WREADY  , -- Out :
                    O_DATA      => q_word      , -- Out :
                    O_VAL       => i_valid     , -- Out :
                    O_RDY       => i_ready       -- In  :
                );
            i_word(WDATA_HI downto WDATA_LO) <= AXI_WDATA;
            i_word(WSTRB_HI downto WSTRB_LO) <= AXI_WSTRB;
            i_word(WLAST_POS               ) <= AXI_WLAST;
            i_data  <= q_word(WDATA_HI downto WDATA_LO);
            i_strb  <= q_word(WSTRB_HI downto WSTRB_LO);
            i_last  <= q_word(WLAST_POS);
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        IPORT_BUF: if (IPORT_QUEUE = FALSE) generate
            i_data  <= AXI_WDATA;
            i_strb  <= AXI_WSTRB;
            i_last  <= AXI_WLAST;
            i_valid <= AXI_WVALID;
            AXI_WREADY <= i_ready;
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        OPORT: if (OPORT_QUEUE = TRUE) generate
            signal    i_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_valid   :  std_logic_vector(2 downto 0);
        begin 
            QUEUE: QUEUE_REGISTER                -- 
                generic map (                    -- 
                    QUEUE_SIZE  => 2           , -- 
                    DATA_BITS   => WORD_BITS     -- 
                )                                -- 
                port map (                       -- 
                    CLK         => ACLK        , -- In  :
                    RST         => reset       , -- In  :
                    CLR         => clear       , -- In  :
                    I_DATA      => i_word      , -- In  :
                    I_VAL       => o_valid     , -- In  :
                    I_RDY       => o_ready     , -- Out :
                    Q_DATA      => q_word      , -- Out :
                    Q_VAL       => q_valid     , -- Out :
                    Q_RDY       => ACP_WREADY    -- In  :
                );
            i_word(WDATA_HI downto WDATA_LO) <= o_data;
            i_word(WSTRB_HI downto WSTRB_LO) <= o_strb;
            i_word(WLAST_POS               ) <= o_last;
            ACP_WVALID <= q_valid(0);
            ACP_WDATA  <= q_word(WDATA_HI downto WDATA_LO);
            ACP_WSTRB  <= q_word(WSTRB_HI downto WSTRB_LO);
            ACP_WLAST  <= q_word(WLAST_POS               );
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        OPORT_BUF: if (OPORT_QUEUE = FALSE) generate
            ACP_WDATA  <= o_data;
            ACP_WSTRB  <= o_strb;
            ACP_WLAST  <= o_last;
            ACP_WVALID <= o_valid;
            o_ready    <= ACP_WREADY;
        end generate;
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    RQ: ZYNQMP_ACP_RESPONSE_QUEUE              -- 
        generic map (                          -- 
            AXI_ID_WIDTH    => AXI_ID_WIDTH  , -- 
            QUEUE_SIZE      => 1               -- 
        )                                      -- 
        port map (                             -- 
            CLK             => ACLK          , -- In  :
            RST             => reset         , -- In  :
            CLR             => clear         , -- In  :
            I_ID            => xfer_id       , -- In  :
            I_LAST          => xfer_last     , -- In  :
            I_VALID         => xfer_start    , -- In  :
            I_READY         => xfer_ready    , -- Out :
            Q_ID            => open          , -- Out :
            Q_LAST          => resp_last     , -- Out :
            Q_VALID         => resp_valid    , -- Out :
            Q_READY         => resp_ready      -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    BQ: block
        signal    b_state       :  std_logic_vector(1 downto 0);
        constant  B_IDLE_STATE  :  std_logic_vector(1 downto 0) := "00";
        constant  B_IN_STATE    :  std_logic_vector(1 downto 0) := "01";
        constant  B_OUT_STATE   :  std_logic_vector(1 downto 0) := "10";
    begin
        ACP_BREADY <= b_state(0);
        AXI_BVALID <= b_state(1);
        resp_ready <= (b_state = B_IN_STATE and ACP_BVALID = '1');
        process(ACLK, reset) begin
            if (reset = '1') then
                    b_state   <= B_IDLE_STATE;
                    AXI_BRESP <= (others => '0');
                    AXI_BID   <= (others => '0');
            elsif (ACLK'event and ACLK = '1') then
                if (clear = '1') then
                    b_state   <= B_IDLE_STATE;
                    AXI_BRESP <= (others => '0');
                    AXI_BID   <= (others => '0');
                else
                    case b_state is
                        when B_IDLE_STATE =>
                            if (resp_valid) then
                                b_state <= B_IN_STATE;
                            else
                                b_state <= B_IDLE_STATE;
                            end if;
                        when B_IN_STATE =>
                            if (ACP_BVALID = '1') then
                                if (resp_last) then
                                    b_state   <= B_OUT_STATE;
                                    AXI_BRESP <= ACP_BRESP;
                                    AXI_BID   <= ACP_BID;
                                else
                                    b_state   <= B_IDLE_STATE;
                                end if;
                            else
                                    b_state   <= B_IN_STATE;
                            end if;
                        when B_OUT_STATE =>
                            if (AXI_BREADY = '1') then
                                b_state <= B_IDLE_STATE;
                            else
                                b_state <= B_OUT_STATE;
                            end if;
                        when others => 
                                b_state <= B_IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
    end block;
end RTL;
