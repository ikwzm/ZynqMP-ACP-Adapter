-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_read_adapter.vhd
--!     @brief   ZynqMP ACP Read Adapter
--!     @version 0.1.0
--!     @date    2019/11/2
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
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.ZYNQMP_ACP_RESPONSE_QUEUE;
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
    signal    xfer_id           :  std_logic_vector(AXI_ID_WIDTH-1 downto 0);
    signal    xfer_start        :  boolean;
    signal    xfer_last         :  boolean;
    signal    xfer_len          :  unsigned( 8 downto 0);
    signal    remain_len        :  unsigned( 8 downto 0);
    signal    burst_len         :  unsigned( 7 downto 0);
    constant  byte_pos          :  unsigned( 3 downto 0) := (others => '0');
    signal    word_pos          :  unsigned(11 downto 4);
    signal    page_num          :  unsigned(AXI_ADDR_WIDTH-1 downto 12);
    signal    resp_queue_ready  :  boolean;
    signal    resp_another_id   :  boolean;
    signal    resp_last         :  boolean;
    signal    resp_valid        :  boolean;
    signal    resp_ready        :  boolean;
    signal    addr_valid        :  std_logic;
    signal    addr_ready        :  std_logic;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    reset <= '0' when (ARESETN = '1') else '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset)
        variable u_word_pos : unsigned(word_pos'high+1 downto word_pos'low);
    begin
        if (reset = '1') then
                curr_state <= IDLE_STATE;
                xfer_id    <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                remain_len <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                curr_state <= IDLE_STATE;
                xfer_id    <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                remain_len <= (others => '0');
            else
                case curr_state is
                    when IDLE_STATE =>
                        if (AXI_ARVALID = '1') then
                            curr_state <= WAIT_STATE;
                            xfer_id    <= AXI_ARID;
                            remain_len <= RESIZE(unsigned(AXI_ARLEN), remain_len'length) + 1;
                            page_num   <= unsigned(AXI_ARADDR(page_num'range));
                            word_pos   <= unsigned(AXI_ARADDR(word_pos'range));
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when WAIT_STATE =>
                        if (resp_queue_ready = TRUE and resp_another_id = FALSE) then
                            curr_state <= ADDR_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when ADDR_STATE =>
                        if (addr_ready = '1' and xfer_last = TRUE ) then
                            curr_state <= IDLE_STATE;
                        else
                            curr_state <= ADDR_STATE;
                        end if;
                        if (addr_ready = '1') then
                            u_word_pos := unsigned'("0") & word_pos;
                            u_word_pos := u_word_pos + xfer_len;
                            word_pos   <= u_word_pos(word_pos'range);
                            remain_len <= remain_len - xfer_len;
                        end if;
                    when others =>
                            curr_state <= IDLE_STATE;
                end case;
            end if;
        end if;
    end process;
    AXI_ARREADY <= '1' when (curr_state = IDLE_STATE) else '0';
    addr_valid  <= '1' when (curr_state = ADDR_STATE) else '0';
    xfer_start  <= (addr_valid = '1' and addr_ready = '1');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process (word_pos, remain_len)
        variable length  :  unsigned(8 downto 0);
    begin
        if (word_pos(5 downto 4) = "00") and (remain_len(8 downto 2) /= "0000000") then
            length    := unsigned(remain_len(8 downto 2)) & unsigned'("00");
            xfer_len  <= length;
            xfer_last <= (remain_len(1 downto 0) = "00");        -- (remain_len <= length)
            burst_len <= RESIZE(length-1, burst_len'length);
        else
            xfer_len  <= unsigned'("000000001");
            xfer_last <= (remain_len(8 downto 1) = "00000000");  -- (remain_len <= 1)
            burst_len <= (others => '0');
        end if;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    AQ: block
        constant  QUEUE_SIZE    :  integer := 2;
        constant  RADDR_LO      :  integer := 0;
        constant  RADDR_HI      :  integer := RADDR_LO  + 12 - 1;
        constant  RLEN_LO       :  integer := RADDR_HI  +  1;
        constant  RLEN_HI       :  integer := RLEN_LO   +  8 - 1;
        constant  WORD_BITS     :  integer := RLEN_HI   - RADDR_LO + 1;
        signal    i_word        :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    q_word        :  std_logic_vector(WORD_BITS-1 downto 0);
        signal    q_valid       :  std_logic_vector(QUEUE_SIZE  downto 0);
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        i_word(RLEN_HI  downto RLEN_LO ) <= std_logic_vector(burst_len);
        i_word(RADDR_HI downto RADDR_LO) <= std_logic_vector(word_pos ) &
                                            std_logic_vector(byte_pos );
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        QUEUE: QUEUE_REGISTER                    -- 
            generic map (                        -- 
                QUEUE_SIZE  => QUEUE_SIZE      , -- 
                DATA_BITS   => WORD_BITS         -- 
            )                                    -- 
            port map (                           -- 
                CLK         => ACLK            , -- In  :
                RST         => reset           , -- In  :
                CLR         => clear           , -- In  :
                I_DATA      => i_word          , -- In  :
                I_VAL       => addr_valid      , -- In  :
                I_RDY       => addr_ready      , -- Out :
                Q_DATA      => q_word          , -- Out :
                Q_VAL       => q_valid         , -- Out :
                Q_RDY       => ACP_ARREADY       -- In  :
            );                                   -- 
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        ACP_ARVALID <= q_valid(0);
        ACP_ARADDR  <= std_logic_vector(page_num) & q_word(RADDR_HI downto RADDR_LO);
        ACP_ARLEN   <= q_word(RLEN_HI downto RLEN_LO);
    end block;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset) begin
        if (reset = '1') then
                ACP_ARSIZE   <= (others => '0');
                ACP_ARBURST  <= (others => '0');
                ACP_ARLOCK   <= (others => '0');
                ACP_ARCACHE  <= (others => '0');
                ACP_ARPROT   <= (others => '0');
                ACP_ARQOS    <= (others => '0');
                ACP_ARREGION <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                ACP_ARSIZE   <= (others => '0');
                ACP_ARBURST  <= (others => '0');
                ACP_ARLOCK   <= (others => '0');
                ACP_ARCACHE  <= (others => '0');
                ACP_ARPROT   <= (others => '0');
                ACP_ARQOS    <= (others => '0');
                ACP_ARREGION <= (others => '0');
            elsif (curr_state = IDLE_STATE and AXI_ARVALID = '1') then
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
    ACP_ARID <= xfer_id;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    RQ: ZYNQMP_ACP_RESPONSE_QUEUE                  -- 
        generic map (                              -- 
            AXI_ID_WIDTH    => AXI_ID_WIDTH      , -- 
            QUEUE_SIZE      => RESP_QUEUE_SIZE     -- 
        )                                          -- 
        port map (                                 -- 
            CLK             => ACLK              , -- In  :
            RST             => reset             , -- In  :
            CLR             => clear             , -- In  :
            I_ID            => xfer_id           , -- In  :
            I_LAST          => xfer_last         , -- In  :
            I_VALID         => xfer_start        , -- In  :
            I_READY         => resp_queue_ready  , -- Out :
            I_ANOTHER_ID    => resp_another_id   , -- Out :
            Q_ID            => open              , -- Out :
            Q_LAST          => resp_last         , -- Out :
            Q_VALID         => resp_valid        , -- Out :
            Q_READY         => resp_ready          -- In  :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DQ: block
        constant  IPORT_QUEUE   :  boolean := (DATA_LATENCY >= 2);
        constant  OPORT_QUEUE   :  boolean := (DATA_LATENCY >= 1);
        constant  RDATA_LO      :  integer := 0;
        constant  RDATA_HI      :  integer := RDATA_LO  + AXI_DATA_WIDTH - 1;
        constant  RRESP_LO      :  integer := RDATA_HI  + 1;
        constant  RRESP_HI      :  integer := RRESP_LO  + 2 - 1;
        constant  RLAST_POS     :  integer := RRESP_HI  + 1;
        constant  RID_LO        :  integer := RLAST_POS + 1;
        constant  RID_HI        :  integer := RID_LO    + AXI_ID_WIDTH   - 1;
        constant  WORD_BITS     :  integer := RID_HI    - RDATA_LO       + 1;
        signal    i_enable      :  std_logic;
        signal    i_valid       :  std_logic;
        signal    i_ready       :  std_logic;
        signal    i_id          :  std_logic_vector(AXI_ID_WIDTH  -1 downto 0);
        signal    i_data        :  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal    i_resp        :  std_logic_vector(1 downto 0);
        signal    i_last        :  std_logic;
        signal    o_valid       :  std_logic;
        signal    o_ready       :  std_logic;
        signal    o_id          :  std_logic_vector(AXI_ID_WIDTH  -1 downto 0);
        signal    o_data        :  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal    o_resp        :  std_logic_vector(1 downto 0);
        signal    o_last        :  std_logic;
        signal    burst_first   :  boolean;
        signal    tran_run      :  boolean;
        signal    tran_start    :  boolean;
        signal    tran_end      :  boolean;
        signal    tran_last     :  boolean;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        tran_start <= (tran_run = FALSE and resp_valid = TRUE);
        tran_end   <= (tran_run = TRUE  and o_valid = '1' and o_ready = '1' and o_last = '1');
        process(ACLK, reset) begin
            if (reset = '1') then
                    tran_run <= FALSE;
            elsif (ACLK'event and ACLK = '1') then
                if    (clear = '1') then
                    tran_run <= FALSE;
                elsif (tran_end   ) then
                    tran_run <= FALSE;
                elsif (tran_start ) then
                    tran_run <= TRUE;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process(ACLK, reset) begin
            if (reset = '1') then
                        burst_first <= TRUE;
            elsif (ACLK'event and ACLK = '1') then
                if (clear = '1') then
                        burst_first <= TRUE;
                elsif (tran_start) then
                        burst_first <= TRUE;
                elsif (i_valid = '1' and i_ready = '1') then
                    if (i_last = '1') then
                        burst_first <= TRUE;
                    else
                        burst_first <= FALSE;
                    end if;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        process(ACLK, reset) begin
            if (reset = '1') then
                    tran_last <= FALSE;
            elsif (ACLK'event and ACLK = '1') then
                if (clear = '1') then
                    tran_last <= FALSE;
                elsif (resp_valid and resp_ready) then
                    tran_last <= resp_last;
                end if;
            end if;
        end process;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        resp_ready <= (burst_first and i_valid = '1' and i_ready = '1');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        i_enable   <= '1' when (tran_start) or
                               (tran_run and not tran_end) else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_last  <= i_last when (tran_last) or 
                               (resp_valid and resp_ready and resp_last) else '0';
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_data  <= i_data;
        o_resp  <= i_resp;
        o_id    <= i_id;
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
