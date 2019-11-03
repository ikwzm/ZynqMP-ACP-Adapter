-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_read_adapter.vhd
--!     @brief   ZynqMP ACP Read Adapter
--!     @version 0.2.0
--!     @date    2019/11/3
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
entity  ZYNQMP_ACP_READ_ADAPTER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        AXI_ADDR_WIDTH      : --! @brief AXI ADDRRESS WIDTH :
                              integer := 64;
        AXI_DATA_WIDTH      : --! @brief AXI DATA WIDTH :
                              integer range 128 to 128 := 128;
        AXI_ID_WIDTH        : --! @brief AXI ID WIDTH :
                              integer := 6;
        RESP_QUEUE_SIZE     : --! @brief RESPONSE_QUEUE_SIZE :
                              integer range 1 to 4  := 2;
        DATA_LATENCY        : --! @brief RDATA LATENCY :
                              integer := 2
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
        ACP_RREADY          : out std_logic
    );
end  ZYNQMP_ACP_READ_ADAPTER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library ZYNQMP_ACP_ADAPTER_LIBRARY;
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.QUEUE_RECEIVER;
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.QUEUE_REGISTER;
architecture RTL of ZYNQMP_ACP_READ_ADAPTER is
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    reset             :  std_logic;
    constant  clear             :  std_logic := '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      STATE_TYPE        is (IDLE_STATE, WAIT_STATE, ADDR_STATE);
    signal    curr_state        :  STATE_TYPE;
    signal    skip_len          :  std_logic_vector( 1 downto 0);
    signal    xfer_len          :  std_logic_vector( 7 downto 0);
    signal    burst_len         :  std_logic_vector( 7 downto 0);
    signal    addr_lo           :  std_logic_vector(11 downto 0);
    signal    addr_hi           :  std_logic_vector(AXI_ADDR_WIDTH-1 downto 12);
    signal    resp_valid        :  std_logic;
    signal    resp_ready        :  std_logic;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    type      RDATA_STATE_TYPE is (RDATA_IDLE_STATE,
                                   RDATA_SKIP_STATE,
                                   RDATA_XFER_STATE,
                                   RDATA_POST_STATE,
                                   RDATA_ERR_STATE
                                   );
    signal    rdata_state       :  RDATA_STATE_TYPE;
    signal    rdata_valid       :  std_logic;
    signal    rdata_ready       :  std_logic;
    signal    rdata_skip_len    :  std_logic_vector( 1 downto 0);
    signal    rdata_xfer_len    :  std_logic_vector( 7 downto 0);
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
                addr_hi    <= (others => '0');
                addr_lo    <= (others => '0');
                burst_len  <= (others => '0');
                xfer_len   <= (others => '0');
                skip_len   <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                curr_state <= IDLE_STATE;
                addr_hi    <= (others => '0');
                addr_lo    <= (others => '0');
                burst_len  <= (others => '0');
                xfer_len   <= (others => '0');
                skip_len   <= (others => '0');
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (AXI_ARVALID = '1') then
                            if (resp_ready = '1') then
                                curr_state <= ADDR_STATE;
                            else
                                curr_state <= WAIT_STATE;
                            end if;
                        else
                                curr_state <= IDLE_STATE;
                        end if;
                        if (AXI_ARVALID = '1') then
                            addr_hi <= AXI_ARADDR(addr_hi'range);
                            if (unsigned(AXI_ARLEN) = 0) then
                                addr_lo( 3 downto 0) <= (3 downto 0 => '0');
                                addr_lo(11 downto 4) <= AXI_ARADDR(11 downto 4);
                                skip_len   <= (others => '0');
                                xfer_len   <= AXI_ARLEN;
                                burst_len  <= AXI_ARLEN;
                            else
                                addr_lo( 5 downto 0) <= (5 downto 0 => '0');
                                addr_lo(11 downto 6) <= AXI_ARADDR(11 downto 6);
                                skip_len   <= AXI_ARADDR(5 downto 4);
                                xfer_len   <= AXI_ARLEN;
                                burst_len  <= std_logic_vector(
                                    unsigned(AXI_ARLEN) +
                                    unsigned(AXI_ARADDR(5 downto 4))) or "00000011";
                            end if;
                        end if;
                    when WAIT_STATE =>
                        if (resp_ready = '1') then
                            curr_state <= ADDR_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when ADDR_STATE =>
                        if (ACP_ARREADY = '1') then
                            curr_state <= IDLE_STATE;
                        else
                            curr_state <= ADDR_STATE;
                        end if;
                    when others =>
                            curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    AXI_ARREADY <= '1' when (curr_state = IDLE_STATE) else '0';
    ACP_ARVALID <= '1' when (curr_state = ADDR_STATE) else '0';
    ACP_ARADDR  <= addr_hi & addr_lo;
    ACP_ARLEN   <= burst_len;
    resp_valid  <= '1' when (curr_state = ADDR_STATE and ACP_ARREADY = '1') else '0';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset) begin
        if (reset = '1') then
                ACP_ARID     <= (others => '0');
                ACP_ARSIZE   <= (others => '0');
                ACP_ARBURST  <= (others => '0');
                ACP_ARLOCK   <= (others => '0');
                ACP_ARCACHE  <= (others => '0');
                ACP_ARPROT   <= (others => '0');
                ACP_ARQOS    <= (others => '0');
                ACP_ARREGION <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                ACP_ARID     <= (others => '0');
                ACP_ARSIZE   <= (others => '0');
                ACP_ARBURST  <= (others => '0');
                ACP_ARLOCK   <= (others => '0');
                ACP_ARCACHE  <= (others => '0');
                ACP_ARPROT   <= (others => '0');
                ACP_ARQOS    <= (others => '0');
                ACP_ARREGION <= (others => '0');
            elsif (curr_state = IDLE_STATE and AXI_ARVALID = '1') then
                ACP_ARID     <= AXI_ARID     ;
                ACP_ARSIZE   <= AXI_ARSIZE   ;
                ACP_ARBURST  <= AXI_ARBURST  ;
                ACP_ARLOCK   <= AXI_ARLOCK   ;
                ACP_ARCACHE  <= AXI_ARCACHE  ;
                ACP_ARPROT   <= AXI_ARPROT   ;
                ACP_ARQOS    <= AXI_ARQOS    ;
                ACP_ARREGION <= AXI_ARREGION ;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    RESP: block
        constant  XFER_LEN_LO   :  integer := 0;
        constant  XFER_LEN_HI   :  integer := XFER_LEN_LO + xfer_len'length - 1;
        constant  SKIP_LEN_LO   :  integer := XFER_LEN_HI + 1;
        constant  SKIP_LEN_HI   :  integer := SKIP_LEN_LO + skip_len'length   - 1;
        constant  WORD_BITS     :  integer := SKIP_LEN_HI + 1;
        signal    i_word        :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    q_word        :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    q_valid       :  std_logic_vector(RESP_QUEUE_SIZE downto 0);
    begin
        QUEUE: QUEUE_REGISTER                    -- 
            generic map (                        -- 
                QUEUE_SIZE  => RESP_QUEUE_SIZE , -- 
                DATA_BITS   => WORD_BITS         -- 
            )                                    -- 
            port map (                           -- 
                CLK         => ACLK            , -- In  :
                RST         => reset           , -- In  :
                CLR         => clear           , -- In  :
                I_DATA      => i_word          , -- In  :
                I_VAL       => resp_valid      , -- In  :
                I_RDY       => resp_ready      , -- Out :
                Q_DATA      => q_word          , -- Out :
                Q_VAL       => q_valid         , -- Out :
                Q_RDY       => rdata_ready       -- In  :
            );
        i_word(XFER_LEN_HI downto XFER_LEN_LO) <= xfer_len;
        i_word(SKIP_LEN_HI downto SKIP_LEN_LO) <= skip_len;
        rdata_valid    <= q_valid(0);
        rdata_xfer_len <= q_word(XFER_LEN_HI downto XFER_LEN_LO);
        rdata_skip_len <= q_word(SKIP_LEN_HI downto SKIP_LEN_LO);
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DQ: block
        constant  IPORT_QUEUE       :  boolean := (DATA_LATENCY >= 2);
        constant  OPORT_QUEUE       :  boolean := (DATA_LATENCY >= 1);
        constant  RDATA_LO          :  integer := 0;
        constant  RDATA_HI          :  integer := RDATA_LO  + AXI_DATA_WIDTH - 1;
        constant  RRESP_LO          :  integer := RDATA_HI  + 1;
        constant  RRESP_HI          :  integer := RRESP_LO  + 2 - 1;
        constant  RLAST_POS         :  integer := RRESP_HI  + 1;
        constant  RID_LO            :  integer := RLAST_POS + 1;
        constant  RID_HI            :  integer := RID_LO    + AXI_ID_WIDTH   - 1;
        constant  WORD_BITS         :  integer := RID_HI    - RDATA_LO       + 1;
        signal    i_enable          :  std_logic;
        signal    i_valid           :  std_logic;
        signal    i_ready           :  std_logic;
        signal    i_id              :  std_logic_vector(AXI_ID_WIDTH  -1 downto 0);
        signal    i_data            :  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal    i_resp            :  std_logic_vector(1 downto 0);
        signal    i_last            :  std_logic;
        signal    i_done            :  std_logic;
        signal    o_valid           :  std_logic;
        signal    o_ready           :  std_logic;
        signal    o_id              :  std_logic_vector(AXI_ID_WIDTH  -1 downto 0);
        signal    o_data            :  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal    o_resp            :  std_logic_vector(1 downto 0);
        signal    o_last            :  std_logic;
        signal    skip_count        :  unsigned(1 downto 0);
        signal    xfer_count        :  unsigned(7 downto 0);
        signal    err_id            :  std_logic_vector(AXI_ID_WIDTH  -1 downto 0);
        signal    err_resp          :  std_logic_vector(1 downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process(ACLK, reset) begin
            if (reset = '1') then
                    rdata_state <= RDATA_IDLE_STATE;
                    skip_count  <= (others => '0');
                    xfer_count  <= (others => '0');
                    err_id      <= (others => '0');
                    err_resp    <= (others => '0');
            elsif (ACLK'event and ACLK = '1') then
                if (clear = '1') then
                    rdata_state <= RDATA_IDLE_STATE;
                    skip_count  <= (others => '0');
                    xfer_count  <= (others => '0');
                    err_id      <= (others => '0');
                    err_resp    <= (others => '0');
                else
                    case rdata_state is
                        when RDATA_IDLE_STATE =>
                            if (rdata_valid = '1') then
                                if (unsigned(rdata_skip_len) = 0) then
                                    rdata_state <= RDATA_XFER_STATE;
                                else
                                    rdata_state <= RDATA_SKIP_STATE;
                                end if;
                                skip_count <= unsigned(rdata_skip_len);
                                xfer_count <= unsigned(rdata_xfer_len);
                            else
                                rdata_state <= RDATA_IDLE_STATE;
                            end if;
                        when RDATA_SKIP_STATE =>
                            if (i_valid = '1' and i_ready = '1') then
                                if    (i_last = '1') then
                                    rdata_state <= RDATA_ERR_STATE;
                                    err_id      <= i_id;
                                    err_resp    <= i_resp;
                                elsif (skip_count <= 1) then
                                    rdata_state <= RDATA_XFER_STATE;
                                else
                                    rdata_state <= RDATA_SKIP_STATE;
                                end if;
                                skip_count  <= skip_count - 1;
                            else
                                rdata_state <= RDATA_SKIP_STATE;
                            end if;
                        when RDATA_XFER_STATE =>
                            if (i_valid = '1' and i_ready = '1') then
                                if (i_last = '1') then
                                    rdata_state <= RDATA_IDLE_STATE;
                                elsif (xfer_count = 0) then
                                    rdata_state <= RDATA_POST_STATE;
                                else
                                    rdata_state <= RDATA_XFER_STATE;
                                    xfer_count  <= xfer_count - 1;
                                end if;
                            else
                                rdata_state <= RDATA_XFER_STATE;
                            end if;
                        when RDATA_POST_STATE =>
                            if (i_valid = '1' and i_ready = '1' and i_last = '1') then
                                rdata_state <= RDATA_IDLE_STATE;
                            else
                                rdata_state <= RDATA_POST_STATE;
                            end if;
                        when RDATA_ERR_STATE =>
                            if (o_valid = '1' and o_ready = '1') then
                                rdata_state <= RDATA_IDLE_STATE;
                            else
                                rdata_state <= RDATA_POST_STATE;
                            end if;
                        when others =>
                                rdata_state <= RDATA_IDLE_STATE;
                    end case;
                end if;
            end if;
        end process;
        rdata_ready <= '1' when (rdata_state = RDATA_IDLE_STATE) else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_data   <= i_data;
        o_resp   <= err_resp when (rdata_state = RDATA_ERR_STATE) else i_resp;
        o_id     <= err_id   when (rdata_state = RDATA_ERR_STATE) else i_id;
        o_last   <= '1' when (rdata_state = RDATA_XFER_STATE and i_last = '1') or
                             (rdata_state = RDATA_XFER_STATE and to_01(xfer_count) = 0) or
                             (rdata_state = RDATA_ERR_STATE) else '0';
        o_valid  <= '1' when (rdata_state = RDATA_XFER_STATE and i_valid = '1') or
                             (rdata_state = RDATA_ERR_STATE ) else '0';
        i_ready  <= '1' when (rdata_state = RDATA_XFER_STATE and o_ready = '1') or
                             (rdata_state = RDATA_SKIP_STATE) or
                             (rdata_state = RDATA_POST_STATE) else '0';
        i_done   <= '1' when (i_valid = '1' and i_ready = '1' and i_last = '1') else '0';
        i_enable <= '1' when (rdata_state = RDATA_IDLE_STATE and rdata_valid = '1') or
                             (rdata_state = RDATA_SKIP_STATE and i_done = '0') or
                             (rdata_state = RDATA_XFER_STATE and i_done = '0') or
                             (rdata_state = RDATA_POST_STATE and i_done = '0') else '0';
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
                    I_VAL       => ACP_RVALID  , -- In  :
                    I_RDY       => ACP_RREADY  , -- Out :
                    O_DATA      => q_word      , -- Out :
                    O_VAL       => i_valid     , -- Out :
                    O_RDY       => i_ready       -- In  :
                );
            i_word(RDATA_HI downto RDATA_LO) <= ACP_RDATA;
            i_word(RRESP_HI downto RRESP_LO) <= ACP_RRESP;
            i_word(RID_HI   downto RID_LO  ) <= ACP_RID;
            i_word(RLAST_POS               ) <= ACP_RLAST;
            i_data  <= q_word(RDATA_HI downto RDATA_LO);
            i_resp  <= q_word(RRESP_HI downto RRESP_LO);
            i_id    <= q_word(RID_HI   downto RID_LO  );
            i_last  <= q_word(RLAST_POS);
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        IPORT_BUF: if (IPORT_QUEUE = FALSE) generate
            i_data  <= ACP_RDATA;
            i_resp  <= ACP_RRESP;
            i_id    <= ACP_RID;
            i_last  <= ACP_RLAST;
            i_valid <= ACP_RVALID;
            ACP_RREADY <= i_ready;
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
                    Q_RDY       => AXI_RREADY    -- In  :
                );
            i_word(RDATA_HI downto RDATA_LO) <= o_data;
            i_word(RRESP_HI downto RRESP_LO) <= o_resp;
            i_word(RID_HI   downto RID_LO  ) <= o_id;
            i_word(RLAST_POS               ) <= o_last;
            AXI_RVALID <= q_valid(0);
            AXI_RDATA  <= q_word(RDATA_HI downto RDATA_LO);
            AXI_RRESP  <= q_word(RRESP_HI downto RRESP_LO);
            AXI_RID    <= q_word(RID_HI   downto RID_LO  );
            AXI_RLAST  <= q_word(RLAST_POS               );
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        OPORT_BUF: if (OPORT_QUEUE = FALSE) generate
            AXI_RDATA  <= o_data;
            AXI_RRESP  <= o_resp;
            AXI_RID    <= o_id;
            AXI_RLAST  <= o_last;
            AXI_RVALID <= o_valid;
            o_ready    <= AXI_RREADY;
        end generate;
    end block;
end RTL;
