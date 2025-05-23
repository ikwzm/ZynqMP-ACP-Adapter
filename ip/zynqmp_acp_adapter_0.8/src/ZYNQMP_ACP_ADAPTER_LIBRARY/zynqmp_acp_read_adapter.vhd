-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_read_adapter.vhd
--!     @brief   ZynqMP ACP Read Adapter
--!     @version 0.8.2
--!     @date    2025/5/9
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2019-2025 Ichiro Kawazome
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
                              --! AXI_DATA_WIDTH shall be equal to ACP_DATA_WIDTH
                              integer range 128 to 128 := 128;
        AXI_ID_WIDTH        : --! @brief AXI ID WIDTH :
                              --! AXI_ID_WIDTH shall be less than or equal to ACP_ID_WIDTH
                              integer := 5;
        AXI_AUSER_WIDTH     : --! @brief AXI_ARUSER WIDTH :
                              integer range 1 to 128 := 2;
        AXI_AUSER_BIT0_POS  : --! @brief AXI_ARUSER BIT0 POSITION :
                              integer := 0;
        AXI_AUSER_BIT1_POS  : --! @brief AXI_ARUSER BIT1 POSITION :
                              integer := 1;
        ACP_ADDR_WIDTH      : --! @brief ACP ADDRESS WIDTH :
                              --! Currently on ZynqMP, ACP_WDATA bit width must be 40
                              integer range  13 to 128 := 40;
        ACP_DATA_WIDTH      : --! @brief ACP DATA WIDTH :
                              --! Currently on ZynqMP, ACP_RDATA bit width must be 128
                              integer range 128 to 128 := 128;
        ACP_ID_WIDTH        : --! @brief ACP ID WIDTH :
                              --! Currently on ZynqMP, ACP_AUSER bit width must be 5
                              integer := 5;
        ACP_AUSER_WIDTH     : --! @brief ACP AUSER WIDTH :
                              --! Currently on ZynqMP, ACP_AUSER bit width must be 2
                              integer range 2 to 128 := 2;
        ARCACHE_OVERLAY     : --! @brief ACP_ARCACHE OVERLAY MASK :
                              --!  0: ACP_ARCACHE[3:0] <= AXI_ARCACHE[3:0]
                              --!  1: ACP_ARCACHE[3:0] <= {AXI_ARCACHE[3:1], ARCACHE_VAL[0:0]}
                              --!  3: ACP_ARCACHE[3:0] <= {AXI_ARCACHE[3:2], ARCACHE_VAL[1:0]}
                              --!  7: ACP_ARCACHE[3:0] <= {AXI_ARCACHE[3:3], ARCACHE_VAL[2:0]}
                              --!  8: ACP_ARCACHE[3:0] <= {ARCACHE_VAL[3:3], AXI_ARCACHE[2:0]}
                              --! 12: ACP_ARCACHE[3:0] <= {ARCACHE_VAL[3:2], AXI_ARCACHE[1:0]}
                              --! 14: ACP_ARCACHE[3:0] <= {ARCACHE_VAL[3:1], AXI_ARCACHE[0:0]}
                              --! 15: ACP_ARCACHE[3:0] <= ARCACHE_VAL[3:0]
                              integer range 0 to 15 := 0;
        ARCACHE_VALUE       : --! @brief ACP_ARCACHE OVERLAY VALUE:
                              --!  0: ARCACHE_VAL[3:0] := "0000"
                              --!  7: ARCACHE_VAL[3:0] := "0111"
                              --!  8: ARCACHE_VAL[3:0] := "1000"
                              --!  9: ARCACHE_VAL[3:0] := "1001"
                              --! 10: ARCACHE_VAL[3:0] := "1010"
                              --! 11: ARCACHE_VAL[3:0] := "1011"
                              --! 12: ARCACHE_VAL[3:0] := "1100"
                              --! 13: ARCACHE_VAL[3:0] := "1101"
                              --! 14: ARCACHE_VAL[3:0] := "1110"
                              --! 15: ARCACHE_VAL[3:0] := "1111"
                              integer range 0 to 15 := 15;
        ARPROT_OVERLAY      : --! @brief ACP_ARPROT  OVERLAY MASK :
                              --!  0: ACP_ARPROT[2:0] <= AXI_ARPROT[2:0]
                              --!  1: ACP_ARPROT[2:0] <= {AXI_ARPROT[2:1], ARPROT_VAL[0:0]}
                              --!  3: ACP_ARPROT[2:0] <= {AXI_ARPROT[2:2], ARPROT_VAL[1:0]}
                              --!  7: ACP_ARPROT[2:0] <= AXI_ARPROT[2:0]
                              integer range 0 to 7  := 0;
        ARPROT_VALUE        : --! @brief ACP_ARPROT  OVERLAY VALUE:
                              --!  0: ARPROT_VAL[2:0] := "000"
                              --!  1: ARPROT_VAL[2:0] := "001"
                              --!  2: ARPROT_VAL[2:0] := "010"
                              --!  4: ARPROT_VAL[2:0] := "100"
                              --!  7: ARPROT_VAL[2:0] := "111"
                              integer range 0 to 7  := 2;
        ARSHARE_TYPE        : --! @brief ACP SHARE TYPE:
                              --! 0: ACP_ARUSER[1:0] <= Non-Sharable.
                              --! 1: ACP_ARUSER[1:0] <= Inner-Sharable.
                              --! 2: ACP_ARUSER[1:0] <= Outer-Sharable.
                              --! 3: Use 2 bit of AXI_ARUSER, 
                              --!    u[0] := AXI_ARUSER[AXI_AUSER_BIT0_POS]
                              --!    u[1] := AXI_ARUSER[AXI_AUSER_BIT1_POS]
                              --!    u[1:0]=00: ACP_ARUSER[1:0] <= Non-Sharable
                              --!    u[1:0]=01: ACP_ARUSER[1:0] <= Inner-Sharable
                              --!    u[1:0]=1x: ACP_ARUSER[1:0] <= Outer-Sharable
                              --! 4: Use 1 bit of AXI_ARUSER, 
                              --!    u[0] := AXI_ARUSER[AXI_AUSER_BIT0_POS]
                              --!    u[0]=0: ACP_ARUSER[1:0] <= Non-Sharable
                              --!    u[0]=1: ACP_ARUSER[1:0] <= Inner-Sharable
                              --! 5: Use 1 bit of AXI_ARUSER,
                              --!    u[0] := AXI_ARUSER[AXI_AUSER_BIT0_POS]
                              --!    u[0]=0: ACP_ARUSER[1:0] <= Non-Sharable
                              --!    u[0]=1: ACP_ARUSER[1:0] <= Outer-Sharable
                              --! 6: Use 1 bit of AXI_ARUSER,
                              --!    u[0] := AXI_ARUSER[AXI_AUSER_BIT0_POS]
                              --!    u[0]=0: ACP_ARUSER[1:0] <= Inner-Sharable
                              --!    u[0]=1: ACP_ARUSER[1:0] <= Outer-Sharable
                              integer range 0 to 6  := 0;
        MAX_BURST_LENGTH    : --! @brief ACP MAX BURST LENGTH :
                              integer range 4 to 4  := 4;
        RESP_QUEUE_SIZE     : --! @brief RESPONSE QUEUE SIZE :
                              integer range 1 to 8  := 2;
        DATA_QUEUE_SIZE     : --! @brief DATA QUEUE SIZE :
                              integer range 0 to 4  := 2;
        DATA_INTAKE_REGS    : --! @brief DATA INTAKE REGSITER :
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
        AXI_ARID            : in  std_logic_vector(AXI_ID_WIDTH    -1 downto 0) := (others => '0');
        AXI_ARADDR          : in  std_logic_vector(AXI_ADDR_WIDTH  -1 downto 0);
        AXI_ARUSER          : in  std_logic_vector(AXI_AUSER_WIDTH -1 downto 0) := (others => '0');
        AXI_ARLEN           : in  std_logic_vector(7 downto 0) := (others => '0');
        AXI_ARSIZE          : in  std_logic_vector(2 downto 0) := "100";
        AXI_ARBURST         : in  std_logic_vector(1 downto 0) := "01";
        AXI_ARLOCK          : in  std_logic_vector(0 downto 0) := "0";
        AXI_ARCACHE         : in  std_logic_vector(3 downto 0) := "1111";
        AXI_ARPROT          : in  std_logic_vector(2 downto 0) := "010";
        AXI_ARQOS           : in  std_logic_vector(3 downto 0) := "0000";
        AXI_ARREGION        : in  std_logic_vector(3 downto 0) := "0000";
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
        ACP_ARID            : out std_logic_vector(ACP_ID_WIDTH    -1 downto 0);
        ACP_ARADDR          : out std_logic_vector(ACP_ADDR_WIDTH  -1 downto 0);
        ACP_ARUSER          : out std_logic_vector(ACP_AUSER_WIDTH -1 downto 0);
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
        ACP_RID             : in  std_logic_vector(ACP_ID_WIDTH    -1 downto 0);
        ACP_RDATA           : in  std_logic_vector(ACP_DATA_WIDTH  -1 downto 0);
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
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.ZYNQMP_ACP_AxUSER;
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
    signal    acp_load          :  std_logic;
    signal    xfer_id           :  std_logic_vector(ACP_ARID   'range);
    signal    xfer_cache        :  std_logic_vector(ACP_ARCACHE'range);
    signal    xfer_prot         :  std_logic_vector(ACP_ARPROT 'range);
    signal    xfer_last         :  boolean;
    signal    xfer_len          :  unsigned( 2 downto 0);
    signal    remain_len        :  unsigned( 8 downto 0);
    signal    burst_len         :  unsigned( 7 downto 0);
    constant  byte_pos          :  unsigned( 3 downto 0) := (others => '0');
    signal    word_pos          :  unsigned(11 downto 4);
    signal    page_num          :  unsigned(ACP_ADDR_WIDTH-1 downto 12);
    signal    resp_queue_valid  :  boolean;
    signal    resp_queue_ready  :  boolean;
    signal    resp_another_id   :  boolean;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    signal    rdata_last        :  boolean;
    signal    rdata_valid       :  boolean;
    signal    rdata_ready       :  boolean;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  resize(SIGS: std_logic_vector; LEN: integer) return std_logic_vector is
        alias     sigs_in       :  std_logic_vector(SIGS'length-1 downto 0) is SIGS;
        variable  result        :  std_logic_vector(LEN        -1 downto 0);
    begin
        for i in result'range loop
            if (sigs_in'low <= i) and (i <= sigs_in'high) then
                result(i) := sigs_in(i);
            else
                result(i) := '0';
            end if;
        end loop;
        return result;
    end function;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    function  overlay_signals(
        signal    SIGS          :  std_logic_vector;
        constant  OVERLAY       :  integer;
        constant  VALUE         :  integer
    )             return           std_logic_vector
    is
        alias     sigs_in       :  std_logic_vector(SIGS'length-1 downto 0) is SIGS;
        variable  result        :  std_logic_vector(SIGS'length-1 downto 0);
        constant  overlay_mask  :  std_logic_vector(SIGS'length-1 downto 0)
                                := std_logic_vector(to_unsigned(OVERLAY, SIGS'length));
        constant  overlay_value :  std_logic_vector(SIGS'length-1 downto 0)
                                := std_logic_vector(to_unsigned(VALUE  , SIGS'length));
    begin
        for i in result'range loop
            if (overlay_mask(i) = '1') then
                result(i) := overlay_value(i);
            else
                result(i) := sigs_in(i);
            end if;
        end loop;
        return result;
    end function;
begin
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    reset <= '0' when (ARESETN = '1') else '1';
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset)
        variable  i_acp_addr       :  std_logic_vector(ACP_ADDR_WIDTH -1 downto  0);
        variable  next_word_pos    :  unsigned(word_pos'range);
        variable  next_remain_len  :  unsigned(remain_len'range);
    begin
        if (reset = '1') then
                curr_state <= IDLE_STATE;
                xfer_id    <= (others => '0');
                xfer_cache <= (others => '0');
                xfer_prot  <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                burst_len  <= (others => '0');
                remain_len <= (others => '0');
                xfer_len   <= to_unsigned(1,xfer_len'length);
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                curr_state <= IDLE_STATE;
                xfer_id    <= (others => '0');
                xfer_cache <= (others => '0');
                xfer_prot  <= (others => '0');
                page_num   <= (others => '0');
                word_pos   <= (others => '0');
                burst_len  <= (others => '0');
                remain_len <= (others => '0');
                xfer_len   <= to_unsigned(1,xfer_len'length);
            else
                next_word_pos   := word_pos;
                next_remain_len := remain_len;
                case curr_state is
                    when IDLE_STATE =>
                        if (AXI_ARVALID = '1') then
                            curr_state <= WAIT_STATE;
                            xfer_id    <= resize(AXI_ARID, xfer_id'length);
                            xfer_cache <= AXI_ARCACHE;
                            xfer_prot  <= AXI_ARPROT;
                            i_acp_addr := resize(AXI_ARADDR, i_acp_addr'length);
                            page_num        <= unsigned(i_acp_addr(page_num'range));
                            next_word_pos   := unsigned(i_acp_addr(word_pos'range));
                            next_remain_len := resize(unsigned(AXI_ARLEN),remain_len'length) + 1;
                        else
                            curr_state <= IDLE_STATE;
                        end if;
                    when WAIT_STATE =>
                        if (resp_queue_ready = TRUE ) and
                           (resp_another_id  = FALSE) then
                            curr_state <= ADDR_STATE;
                        else
                            curr_state <= WAIT_STATE;
                        end if;
                    when ADDR_STATE =>
                        if (ACP_ARREADY = '1') then
                            if (xfer_last) then
                                curr_state <= IDLE_STATE;
                            else
                                curr_state <= ADDR_STATE;
                            end if;
                            next_word_pos   := word_pos   + xfer_len;
                            next_remain_len := remain_len - xfer_len;
                        else
                            curr_state <= ADDR_STATE;
                        end if;
                    when others =>
                            curr_state <= IDLE_STATE;
                end case;
                if (next_word_pos(5 downto 4) = "00" and next_remain_len >= MAX_BURST_LENGTH) then
                    xfer_len  <= to_unsigned(MAX_BURST_LENGTH  , xfer_len'length );
                    burst_len <= to_unsigned(MAX_BURST_LENGTH-1, burst_len'length);
                else
                    xfer_len  <= to_unsigned(1  , xfer_len'length );
                    burst_len <= to_unsigned(1-1, burst_len'length);
                end if;
                word_pos   <= next_word_pos;
                remain_len <= next_remain_len;
            end if;
        end if;
    end process;
    AXI_ARREADY <= '1' when (curr_state = IDLE_STATE) else '0';
    acp_load    <= '1' when (curr_state = IDLE_STATE and AXI_ARVALID = '1') else '0';
    ACP_ARVALID <= '1' when (curr_state = ADDR_STATE) else '0';
    ACP_ARADDR  <= std_logic_vector(page_num) & std_logic_vector(word_pos) & std_logic_vector(byte_pos);
    ACP_ARLEN   <= std_logic_vector(burst_len);
    ACP_ARID    <= xfer_id;
    ACP_ARCACHE <= overlay_signals(xfer_cache, ARCACHE_OVERLAY, ARCACHE_VALUE);
    ACP_ARPROT  <= overlay_signals(xfer_prot , ARPROT_OVERLAY , ARPROT_VALUE );
    xfer_last   <= (remain_len <= xfer_len);
    resp_queue_valid  <= (curr_state = ADDR_STATE and ACP_ARREADY = '1');
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process(ACLK, reset) begin
        if (reset = '1') then
                ACP_ARSIZE   <= (others => '0');
                ACP_ARBURST  <= (others => '0');
                ACP_ARLOCK   <= (others => '0');
                ACP_ARQOS    <= (others => '0');
                ACP_ARREGION <= (others => '0');
        elsif (ACLK'event and ACLK = '1') then
            if (clear = '1') then
                ACP_ARSIZE   <= (others => '0');
                ACP_ARBURST  <= (others => '0');
                ACP_ARLOCK   <= (others => '0');
                ACP_ARQOS    <= (others => '0');
                ACP_ARREGION <= (others => '0');
            elsif (acp_load = '1') then
                ACP_ARSIZE   <= AXI_ARSIZE   ;
                ACP_ARBURST  <= AXI_ARBURST  ;
                ACP_ARLOCK   <= AXI_ARLOCK   ;
                ACP_ARQOS    <= AXI_ARQOS    ;
                ACP_ARREGION <= AXI_ARREGION ;
            end if;
        end if;
    end process;
    -------------------------------------------------------------------------------
    -- ACP ARUSER
    -------------------------------------------------------------------------------
    ACP_AUSER: ZYNQMP_ACP_AxUSER                       -- 
        generic map (                                  --
            ACP_SHARE_TYPE      => ARSHARE_TYPE      , --
            ACP_AUSER_WIDTH     => ACP_AUSER_WIDTH   , --
            AXI_AUSER_WIDTH     => AXI_AUSER_WIDTH   , --
            AXI_AUSER_BIT0_POS  => AXI_AUSER_BIT0_POS, --
            AXI_AUSER_BIT1_POS  => AXI_AUSER_BIT1_POS  -- 
        )                                              -- 
        port map (                                     -- 
            CLK             => ACLK                  , -- In  :
            RST             => reset                 , -- In  :
            CLR             => clear                 , -- In  :
            LOAD            => acp_load              , -- In  :
            AXI_AUSER       => AXI_ARUSER            , -- In  :
            ACP_AUSER       => ACP_ARUSER              -- Out :
        );                                             -- 
    -------------------------------------------------------------------------------
    -- Read Response Request Queue
    ---------------------------------------------------------------------------
    RESP: ZYNQMP_ACP_RESPONSE_QUEUE                -- 
        generic map (                              -- 
            AXI_ID_WIDTH    => ACP_ID_WIDTH      , -- 
            QUEUE_SIZE      => RESP_QUEUE_SIZE     -- 
        )                                          -- 
        port map (                                 -- 
            CLK             => ACLK              , -- In  :
            RST             => reset             , -- In  :
            CLR             => clear             , -- In  :
            I_ID            => xfer_id           , -- In  :
            I_LAST          => xfer_last         , -- In  :
            I_VALID         => resp_queue_valid  , -- In  :
            I_READY         => resp_queue_ready  , -- Out :
            I_ANOTHER_ID    => resp_another_id   , -- Out :
            Q_ID            => open              , -- Out :
            Q_LAST          => rdata_last        , -- Out :
            Q_VALID         => rdata_valid       , -- Out :
            Q_READY         => rdata_ready         -- In  :
        );                                         -- 
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DATA: block
        constant  RDATA_LO          :  integer := 0;
        constant  RDATA_HI          :  integer := RDATA_LO  + ACP_DATA_WIDTH - 1;
        constant  RRESP_LO          :  integer := RDATA_HI  + 1;
        constant  RRESP_HI          :  integer := RRESP_LO  + 2 - 1;
        constant  RLAST_POS         :  integer := RRESP_HI  + 1;
        constant  RID_LO            :  integer := RLAST_POS + 1;
        constant  RID_HI            :  integer := RID_LO    + ACP_ID_WIDTH   - 1;
        constant  WORD_BITS         :  integer := RID_HI    - RDATA_LO       + 1;
        signal    i_enable          :  std_logic;
        signal    i_valid           :  std_logic;
        signal    i_ready           :  std_logic;
        signal    i_id              :  std_logic_vector(ACP_ID_WIDTH  -1 downto 0);
        signal    i_data            :  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal    i_resp            :  std_logic_vector(1 downto 0);
        signal    i_last            :  std_logic;
        signal    i_done            :  std_logic;
        signal    o_valid           :  std_logic;
        signal    o_ready           :  std_logic;
        signal    o_id              :  std_logic_vector(ACP_ID_WIDTH  -1 downto 0);
        signal    o_data            :  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        signal    o_resp            :  std_logic_vector(1 downto 0);
        signal    o_last            :  std_logic;
    begin
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        o_data      <= i_data;
        o_resp      <= i_resp;
        o_id        <= i_id;
        o_last      <= '1' when (rdata_valid and rdata_last and i_last = '1') else '0';
        o_valid     <= '1' when (rdata_valid and i_valid = '1') else '0';
        i_ready     <= '1' when (rdata_valid and o_ready = '1') else '0';
        i_enable    <= '1';
        rdata_ready <= (i_valid = '1' and i_ready = '1' and i_last = '1');
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        INTAKE: if (DATA_INTAKE_REGS /= 0) generate
            signal    i_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_word    :  std_logic_vector(WORD_BITS-1 downto 0);
        begin 
            i_word(RDATA_HI downto RDATA_LO) <= ACP_RDATA;
            i_word(RRESP_HI downto RRESP_LO) <= ACP_RRESP;
            i_word(RID_HI   downto RID_LO  ) <= ACP_RID;
            i_word(RLAST_POS               ) <= ACP_RLAST;
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
            i_data  <= q_word(RDATA_HI downto RDATA_LO);
            i_resp  <= q_word(RRESP_HI downto RRESP_LO);
            i_id    <= q_word(RID_HI   downto RID_LO  );
            i_last  <= q_word(RLAST_POS);
        end generate;
        ---------------------------------------------------------------------------
        --
        ---------------------------------------------------------------------------
        INTAKE_NO_REGS: if (DATA_INTAKE_REGS = 0) generate
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
        OUTLET: block
            signal    i_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_word    :  std_logic_vector(WORD_BITS-1 downto 0);
            signal    q_valid   :  std_logic_vector(2 downto 0);
        begin 
            i_word(RDATA_HI downto RDATA_LO) <= o_data;
            i_word(RRESP_HI downto RRESP_LO) <= o_resp;
            i_word(RID_HI   downto RID_LO  ) <= o_id;
            i_word(RLAST_POS               ) <= o_last;
            QUEUE: QUEUE_REGISTER                    -- 
                generic map (                        -- 
                    QUEUE_SIZE  => DATA_QUEUE_SIZE , -- 
                    DATA_BITS   => WORD_BITS         -- 
                )                                    -- 
                port map (                           -- 
                    CLK         => ACLK            , -- In  :
                    RST         => reset           , -- In  :
                    CLR         => clear           , -- In  :
                    I_DATA      => i_word          , -- In  :
                    I_VAL       => o_valid         , -- In  :
                    I_RDY       => o_ready         , -- Out :
                    Q_DATA      => q_word          , -- Out :
                    Q_VAL       => q_valid         , -- Out :
                    Q_RDY       => AXI_RREADY        -- In  :
                );
            AXI_RVALID <= q_valid(0);
            AXI_RDATA  <=        q_word(RDATA_HI downto RDATA_LO);
            AXI_RRESP  <=        q_word(RRESP_HI downto RRESP_LO);
            AXI_RID    <= resize(q_word(RID_HI   downto RID_LO  ), AXI_ID_WIDTH);
            AXI_RLAST  <=        q_word(RLAST_POS               );
        end block;
    end block;
end RTL;
