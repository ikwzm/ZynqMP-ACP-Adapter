-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_test_bench.vhd
--!     @brief   ZynqMP ACP ADPATER TEST BENCH
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
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
package ZYNQMP_ACP_ADAPTER_TEST_BENCH_COMPONENTS is
component  ZYNQMP_ACP_ADAPTER_TEST_BENCH
    generic (
        NAME            : STRING  := string'("ZYNQMP_ACP_ADAPTER_TEST_BENCH");
        SCENARIO_FILE   : STRING  := string'("zynqmp_acp_adapter_test.snr");
        READ_ENABLE     : boolean := TRUE;
        WRITE_ENABLE    : boolean := TRUE;
        OVERLAY_CACHE   : integer := 0;
        OVERLAY_PROT    : integer := 0;
        FINISH_ABORT    : boolean := FALSE
    );
end component;
end package;
-----------------------------------------------------------------------------------
-- ZYNQMP_ACP_ADAPTER_TEST_BENCH
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ZYNQMP_ACP_ADAPTER_TEST_BENCH is
    generic (
        NAME            : STRING  := string'("ZYNQMP_ACP_ADAPTER_TEST_BENCH");
        SCENARIO_FILE   : STRING  := string'("zynqmp_acp_adapter_test.snr");
        READ_ENABLE     : boolean := TRUE;
        WRITE_ENABLE    : boolean := TRUE;
        OVERLAY_CACHE   : integer := 0;
        OVERLAY_PROT    : integer := 0;
        FINISH_ABORT    : boolean := FALSE
    );
end     ZYNQMP_ACP_ADAPTER_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
library ZYNQMP_ACP_ADAPTER_LIBRARY;
use     ZYNQMP_ACP_ADAPTER_LIBRARY.COMPONENTS.ZYNQMP_ACP_ADAPTER;
architecture MODEL of ZYNQMP_ACP_ADAPTER_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant CLK_PERIOD      : time    := 10 ns;
    constant DELAY           : time    := CLK_PERIOD*0.1;
    constant AXI_ADDR_WIDTH  : integer :=  32;
    constant AXI_DATA_WIDTH  : integer := 128;
    constant AXI_ID_WIDTH    : integer :=   4;
    constant AXI_AUSER_WIDTH : integer :=   4;
    constant ACP_WIDTH       : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => AXI_ID_WIDTH    ,
                                 AWADDR      => AXI_ADDR_WIDTH  ,
                                 ARADDR      => AXI_ADDR_WIDTH  ,
                                 AWUSER      => AXI_AUSER_WIDTH ,
                                 ARUSER      => AXI_AUSER_WIDTH ,
                                 ALEN        => AXI4_ALEN_WIDTH ,
                                 ALOCK       => AXI4_ALOCK_WIDTH,
                                 WDATA       => AXI_DATA_WIDTH  ,
                                 RDATA       => AXI_DATA_WIDTH  ,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant AXI_WIDTH       : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => AXI_ID_WIDTH    ,
                                 AWADDR      => AXI_ADDR_WIDTH  ,
                                 ARADDR      => AXI_ADDR_WIDTH  ,
                                 AWUSER      => AXI_AUSER_WIDTH ,
                                 ARUSER      => AXI_AUSER_WIDTH ,
                                 ALEN        => AXI4_ALEN_WIDTH ,
                                 ALOCK       => AXI4_ALOCK_WIDTH,
                                 WDATA       => AXI_DATA_WIDTH  ,
                                 RDATA       => AXI_DATA_WIDTH  ,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    function ENABLE_TO_INTEGER(ENABLE: boolean) return integer is
    begin
        if (ENABLE) then return 1;
        else             return 0;
        end if;
    end function;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    ------------------------------------------------------------------------------
    -- AXI リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   AXI_ARADDR      : std_logic_vector(AXI_WIDTH.ARADDR -1 downto 0);
    signal   AXI_ARLEN       : std_logic_vector(AXI_WIDTH.ALEN   -1 downto 0);
    signal   AXI_ARSIZE      : AXI4_ASIZE_TYPE;
    signal   AXI_ARBURST     : AXI4_ABURST_TYPE;
    signal   AXI_ARLOCK      : std_logic_vector(AXI_WIDTH.ALOCK  -1 downto 0);
    signal   AXI_ARCACHE     : AXI4_ACACHE_TYPE;
    signal   AXI_ARPROT      : AXI4_APROT_TYPE;
    signal   AXI_ARQOS       : AXI4_AQOS_TYPE;
    signal   AXI_ARREGION    : AXI4_AREGION_TYPE;
    signal   AXI_ARUSER      : std_logic_vector(AXI_WIDTH.ARUSER -1 downto 0);
    signal   AXI_ARID        : std_logic_vector(AXI_WIDTH.ID     -1 downto 0);
    signal   AXI_ARVALID     : std_logic;
    signal   AXI_ARREADY     : std_logic;
    -------------------------------------------------------------------------------
    -- AXI リードデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   AXI_RVALID      : std_logic;
    signal   AXI_RLAST       : std_logic;
    signal   AXI_RDATA       : std_logic_vector(AXI_WIDTH.RDATA  -1 downto 0);
    signal   AXI_RRESP       : AXI4_RESP_TYPE;
    constant AXI_RUSER       : std_logic_vector(AXI_WIDTH.RUSER  -1 downto 0) := (others => '0');
    signal   AXI_RID         : std_logic_vector(AXI_WIDTH.ID     -1 downto 0);
    signal   AXI_RREADY      : std_logic;
    -------------------------------------------------------------------------------
    -- AXI ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   AXI_AWADDR      : std_logic_vector(AXI_WIDTH.AWADDR -1 downto 0);
    signal   AXI_AWLEN       : std_logic_vector(AXI_WIDTH.ALEN   -1 downto 0);
    signal   AXI_AWSIZE      : AXI4_ASIZE_TYPE;
    signal   AXI_AWBURST     : AXI4_ABURST_TYPE;
    signal   AXI_AWLOCK      : std_logic_vector(AXI_WIDTH.ALOCK  -1 downto 0);
    signal   AXI_AWCACHE     : AXI4_ACACHE_TYPE;
    signal   AXI_AWPROT      : AXI4_APROT_TYPE;
    signal   AXI_AWQOS       : AXI4_AQOS_TYPE;
    signal   AXI_AWREGION    : AXI4_AREGION_TYPE;
    signal   AXI_AWUSER      : std_logic_vector(AXI_WIDTH.AWUSER -1 downto 0);
    signal   AXI_AWID        : std_logic_vector(AXI_WIDTH.ID     -1 downto 0);
    signal   AXI_AWVALID     : std_logic;
    signal   AXI_AWREADY     : std_logic;
    -------------------------------------------------------------------------------
    -- AXI ライトデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   AXI_WLAST       : std_logic;
    signal   AXI_WDATA       : std_logic_vector(AXI_WIDTH.WDATA  -1 downto 0);
    signal   AXI_WSTRB       : std_logic_vector(AXI_WIDTH.WDATA/8-1 downto 0);
    signal   AXI_WUSER       : std_logic_vector(AXI_WIDTH.WUSER  -1 downto 0);
    signal   AXI_WID         : std_logic_vector(AXI_WIDTH.ID     -1 downto 0);
    signal   AXI_WVALID      : std_logic;
    signal   AXI_WREADY      : std_logic;
    -------------------------------------------------------------------------------
    -- AXI ライト応答チャネルシグナル.
    -------------------------------------------------------------------------------
    signal   AXI_BRESP       : AXI4_RESP_TYPE;
    constant AXI_BUSER       : std_logic_vector(AXI_WIDTH.BUSER  -1 downto 0) := (others => '0');
    signal   AXI_BID         : std_logic_vector(AXI_WIDTH.ID     -1 downto 0);
    signal   AXI_BVALID      : std_logic;
    signal   AXI_BREADY      : std_logic;
    ------------------------------------------------------------------------------
    -- ACP リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   ACP_ARADDR      : std_logic_vector(ACP_WIDTH.ARADDR -1 downto 0);
    signal   ACP_ARLEN       : std_logic_vector(ACP_WIDTH.ALEN   -1 downto 0);
    signal   ACP_ARSIZE      : AXI4_ASIZE_TYPE;
    signal   ACP_ARBURST     : AXI4_ABURST_TYPE;
    signal   ACP_ARLOCK      : std_logic_vector(ACP_WIDTH.ALOCK  -1 downto 0);
    signal   ACP_ARCACHE     : AXI4_ACACHE_TYPE;
    signal   ACP_ARPROT      : AXI4_APROT_TYPE;
    signal   ACP_ARQOS       : AXI4_AQOS_TYPE;
    signal   ACP_ARREGION    : AXI4_AREGION_TYPE;
    constant ACP_ARUSER      : std_logic_vector(ACP_WIDTH.ARUSER -1 downto 0) := (others => '0');
    signal   ACP_ARID        : std_logic_vector(ACP_WIDTH.ID     -1 downto 0);
    signal   ACP_ARVALID     : std_logic;
    signal   ACP_ARREADY     : std_logic;
    -------------------------------------------------------------------------------
    -- ACP リードデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   ACP_RVALID      : std_logic;
    signal   ACP_RLAST       : std_logic;
    signal   ACP_RDATA       : std_logic_vector(ACP_WIDTH.RDATA  -1 downto 0);
    signal   ACP_RRESP       : AXI4_RESP_TYPE;
    signal   ACP_RUSER       : std_logic_vector(ACP_WIDTH.RUSER  -1 downto 0);
    signal   ACP_RID         : std_logic_vector(ACP_WIDTH.ID     -1 downto 0);
    signal   ACP_RREADY      : std_logic;
    -------------------------------------------------------------------------------
    -- ACP ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   ACP_AWADDR      : std_logic_vector(ACP_WIDTH.AWADDR -1 downto 0);
    signal   ACP_AWLEN       : std_logic_vector(ACP_WIDTH.ALEN   -1 downto 0);
    signal   ACP_AWSIZE      : AXI4_ASIZE_TYPE;
    signal   ACP_AWBURST     : AXI4_ABURST_TYPE;
    signal   ACP_AWLOCK      : std_logic_vector(ACP_WIDTH.ALOCK  -1 downto 0);
    signal   ACP_AWCACHE     : AXI4_ACACHE_TYPE;
    signal   ACP_AWPROT      : AXI4_APROT_TYPE;
    signal   ACP_AWQOS       : AXI4_AQOS_TYPE;
    signal   ACP_AWREGION    : AXI4_AREGION_TYPE;
    constant ACP_AWUSER      : std_logic_vector(ACP_WIDTH.AWUSER -1 downto 0) := (others => '0');
    signal   ACP_AWID        : std_logic_vector(ACP_WIDTH.ID     -1 downto 0);
    signal   ACP_AWVALID     : std_logic;
    signal   ACP_AWREADY     : std_logic;
    -------------------------------------------------------------------------------
    -- ACP ライトデータチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   ACP_WLAST       : std_logic;
    signal   ACP_WDATA       : std_logic_vector(ACP_WIDTH.WDATA  -1 downto 0);
    signal   ACP_WSTRB       : std_logic_vector(ACP_WIDTH.WDATA/8-1 downto 0);
    constant ACP_WUSER       : std_logic_vector(ACP_WIDTH.WUSER  -1 downto 0) := (others => '0');
    constant ACP_WID         : std_logic_vector(ACP_WIDTH.ID     -1 downto 0) := (others => '0');
    signal   ACP_WVALID      : std_logic;
    signal   ACP_WREADY      : std_logic;
    -------------------------------------------------------------------------------
    -- ACP ライト応答チャネルシグナル.
    -------------------------------------------------------------------------------
    signal   ACP_BRESP       : AXI4_RESP_TYPE;
    signal   ACP_BUSER       : std_logic_vector(ACP_WIDTH.BUSER  -1 downto 0);
    signal   ACP_BID         : std_logic_vector(ACP_WIDTH.ID     -1 downto 0);
    signal   ACP_BVALID      : std_logic;
    signal   ACP_BREADY      : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal   AXI_GPI         : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   AXI_GPO         : std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal   ACP_GPI         : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   ACP_GPO         : std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   ACP_REPORT      : REPORT_STATUS_TYPE;
    signal   AXI_REPORT      : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   ACP_FINISH      : std_logic;
    signal   AXI_FINISH      : std_logic;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "N",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    AXI: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "AXI"           ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => AXI_WIDTH       ,
            SYNC_PLUG_NUM   => 2               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => AXI_ARADDR      , -- I/O : 
            ARLEN           => AXI_ARLEN       , -- I/O : 
            ARSIZE          => AXI_ARSIZE      , -- I/O : 
            ARBURST         => AXI_ARBURST     , -- I/O : 
            ARLOCK          => AXI_ARLOCK      , -- I/O : 
            ARCACHE         => AXI_ARCACHE     , -- I/O : 
            ARPROT          => AXI_ARPROT      , -- I/O : 
            ARQOS           => AXI_ARQOS       , -- I/O : 
            ARREGION        => AXI_ARREGION    , -- I/O : 
            ARUSER          => AXI_ARUSER      , -- I/O : 
            ARID            => AXI_ARID        , -- I/O : 
            ARVALID         => AXI_ARVALID     , -- I/O : 
            ARREADY         => AXI_ARREADY     , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => AXI_RLAST       , -- In  :    
            RDATA           => AXI_RDATA       , -- In  :    
            RRESP           => AXI_RRESP       , -- In  :    
            RUSER           => AXI_RUSER       , -- In  :    
            RID             => AXI_RID         , -- In  :    
            RVALID          => AXI_RVALID      , -- In  :    
            RREADY          => AXI_RREADY      , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => AXI_AWADDR      , -- I/O : 
            AWLEN           => AXI_AWLEN       , -- I/O : 
            AWSIZE          => AXI_AWSIZE      , -- I/O : 
            AWBURST         => AXI_AWBURST     , -- I/O : 
            AWLOCK          => AXI_AWLOCK      , -- I/O : 
            AWCACHE         => AXI_AWCACHE     , -- I/O : 
            AWPROT          => AXI_AWPROT      , -- I/O : 
            AWQOS           => AXI_AWQOS       , -- I/O : 
            AWREGION        => AXI_AWREGION    , -- I/O : 
            AWUSER          => AXI_AWUSER      , -- I/O : 
            AWID            => AXI_AWID        , -- I/O : 
            AWVALID         => AXI_AWVALID     , -- I/O : 
            AWREADY         => AXI_AWREADY     , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => AXI_WLAST       , -- I/O : 
            WDATA           => AXI_WDATA       , -- I/O : 
            WSTRB           => AXI_WSTRB       , -- I/O : 
            WUSER           => AXI_WUSER       , -- I/O : 
            WID             => AXI_WID         , -- I/O : 
            WVALID          => AXI_WVALID      , -- I/O : 
            WREADY          => AXI_WREADY      , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => AXI_BRESP       , -- In  :    
            BUSER           => AXI_BUSER       , -- In  :    
            BID             => AXI_BID         , -- In  :    
            BVALID          => AXI_BVALID      , -- In  :    
            BREADY          => AXI_BREADY      , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => AXI_GPI         , -- In  :
            GPO             => AXI_GPO         , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => AXI_REPORT      , -- Out :
            FINISH          => AXI_FINISH        -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    ACP: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "ACP"           ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => ACP_WIDTH       ,
            SYNC_PLUG_NUM   => 3               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => ACP_ARADDR      , -- In  : 
            ARLEN           => ACP_ARLEN       , -- In  : 
            ARSIZE          => ACP_ARSIZE      , -- In  : 
            ARBURST         => ACP_ARBURST     , -- In  : 
            ARLOCK          => ACP_ARLOCK      , -- In  : 
            ARCACHE         => ACP_ARCACHE     , -- In  : 
            ARPROT          => ACP_ARPROT      , -- In  : 
            ARQOS           => ACP_ARQOS       , -- In  : 
            ARREGION        => ACP_ARREGION    , -- In  : 
            ARUSER          => ACP_ARUSER      , -- In  : 
            ARID            => ACP_ARID        , -- In  : 
            ARVALID         => ACP_ARVALID     , -- In  : 
            ARREADY         => ACP_ARREADY     , -- I/O :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => ACP_RLAST       , -- I/O :    
            RDATA           => ACP_RDATA       , -- I/O :    
            RRESP           => ACP_RRESP       , -- I/O :    
            RUSER           => ACP_RUSER       , -- I/O :    
            RID             => ACP_RID         , -- I/O :    
            RVALID          => ACP_RVALID      , -- I/O :    
            RREADY          => ACP_RREADY      , -- In  : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => ACP_AWADDR      , -- In  : 
            AWLEN           => ACP_AWLEN       , -- In  : 
            AWSIZE          => ACP_AWSIZE      , -- In  : 
            AWBURST         => ACP_AWBURST     , -- In  : 
            AWLOCK          => ACP_AWLOCK      , -- In  : 
            AWCACHE         => ACP_AWCACHE     , -- In  : 
            AWPROT          => ACP_AWPROT      , -- In  : 
            AWQOS           => ACP_AWQOS       , -- In  : 
            AWREGION        => ACP_AWREGION    , -- In  : 
            AWUSER          => ACP_AWUSER      , -- In  : 
            AWID            => ACP_AWID        , -- In  : 
            AWVALID         => ACP_AWVALID     , -- In  : 
            AWREADY         => ACP_AWREADY     , -- I/O :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => ACP_WLAST       , -- In  : 
            WDATA           => ACP_WDATA       , -- In  : 
            WSTRB           => ACP_WSTRB       , -- In  : 
            WUSER           => ACP_WUSER       , -- In  : 
            WID             => ACP_WID         , -- In  : 
            WVALID          => ACP_WVALID      , -- In  : 
            WREADY          => ACP_WREADY      , -- I/O :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => ACP_BRESP       , -- I/O :    
            BUSER           => ACP_BUSER       , -- I/O :    
            BID             => ACP_BID         , -- I/O :    
            BVALID          => ACP_BVALID      , -- I/O :    
            BREADY          => ACP_BREADY      , -- In  : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => ACP_GPI         , -- In  :
            GPO             => ACP_GPO         , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => ACP_REPORT      , -- Out :
            FINISH          => ACP_FINISH        -- Out :
        );
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    DUT: ZYNQMP_ACP_ADAPTER
        generic map (
            AXI_ID_WIDTH        => AXI_ID_WIDTH        ,
            AXI_ADDR_WIDTH      => AXI_ADDR_WIDTH      ,
            AXI_DATA_WIDTH      => AXI_DATA_WIDTH      ,
            ARCACHE_OVERLAY     => OVERLAY_CACHE       ,
            ARPROT_OVERLAY      => OVERLAY_PROT        ,
            AWCACHE_OVERLAY     => OVERLAY_CACHE       ,
            AWPROT_OVERLAY      => OVERLAY_PROT        ,
            READ_ENABLE         => ENABLE_TO_INTEGER(READ_ENABLE  ),
            WRITE_ENABLE        => ENABLE_TO_INTEGER(WRITE_ENABLE )
        )
        port map(
        --------------------------------------------------------------------------
        -- Clock / Reset Signals.
        --------------------------------------------------------------------------
            ACLK                => ACLK                , -- In  :
            ARESETn             => ARESETn             , -- In  :
        --------------------------------------------------------------------------
        -- AXI Interface Signals.
        --------------------------------------------------------------------------
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
            AXI_WDATA           => AXI_WDATA           , -- In  :
            AXI_WSTRB           => AXI_WSTRB           , -- In  :
            AXI_WLAST           => AXI_WLAST           , -- In  :
            AXI_WVALID          => AXI_WVALID          , -- In  :
            AXI_WREADY          => AXI_WREADY          , -- Out :
            AXI_BID             => AXI_BID             , -- Out :
            AXI_BRESP           => AXI_BRESP           , -- Out :
            AXI_BVALID          => AXI_BVALID          , -- Out :
            AXI_BREADY          => AXI_BREADY          , -- In  :
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
            AXI_RID             => AXI_RID             , -- Out :
            AXI_RDATA           => AXI_RDATA           , -- Out :
            AXI_RRESP           => AXI_RRESP           , -- Out :
            AXI_RLAST           => AXI_RLAST           , -- Out :
            AXI_RVALID          => AXI_RVALID          , -- Out :
            AXI_RREADY          => AXI_RREADY          , -- In  :
        --------------------------------------------------------------------------
        -- ACP Interface Signals.
        --------------------------------------------------------------------------
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
            ACP_WDATA           => ACP_WDATA           , -- Out :
            ACP_WSTRB           => ACP_WSTRB           , -- Out :
            ACP_WLAST           => ACP_WLAST           , -- Out :
            ACP_WVALID          => ACP_WVALID          , -- Out :
            ACP_WREADY          => ACP_WREADY          , -- In  :
            ACP_BID             => ACP_BID             , -- In  :
            ACP_BRESP           => ACP_BRESP           , -- In  :
            ACP_BVALID          => ACP_BVALID          , -- In  :
            ACP_BREADY          => ACP_BREADY          , -- Out :
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
            ACP_RID             => ACP_RID             , -- In  :
            ACP_RDATA           => ACP_RDATA           , -- In  :
            ACP_RRESP           => ACP_RRESP           , -- In  :
            ACP_RLAST           => ACP_RLAST           , -- In  :
            ACP_RVALID          => ACP_RVALID          , -- In  :
            ACP_RREADY          => ACP_RREADY            -- Out :
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        ACLK <= '0';
        MAIN_LOOP : loop
            wait for CLK_PERIOD/2;
            ACLK <= '1';
            wait for CLK_PERIOD/2;
            ACLK <= '0';
            exit when (AXI_FINISH = '1');
        end loop;
        ACLK <= '0';
        wait;
    end process;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    ARESETn <= '1' when (RESET = '0') else '0';
    AXI_GPI   <= AXI_GPO;
    ACP_GPI   <= AXI_GPO;
    -------------------------------------------------------------------------------
    --
    -------------------------------------------------------------------------------
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (AXI_FINISH'event and AXI_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                            WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ AXI SIDE ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,AXI_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,AXI_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,AXI_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                     WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ ACP SIDE ]");                                    WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,ACP_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,ACP_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,ACP_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                     WRITELINE(OUTPUT,L);
        assert (AXI_REPORT.error_count    = 0 and
                ACP_REPORT.error_count    = 0)
            report "Simulation complete(error)." severity FAILURE;
        assert (AXI_REPORT.mismatch_count = 0 and
                ACP_REPORT.mismatch_count = 0)
            report "Simulation complete(mismatch)." severity FAILURE;
        if (FINISH_ABORT) then
            assert FALSE report "Simulation complete(success)." severity FAILURE;
        else
            assert FALSE report "Simulation complete(success)." severity NOTE;
        end if;
        wait;
    end process;
    
 -- SYNC_PRINT_0: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(0)")) port map (SYNC(0));
 -- SYNC_PRINT_1: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(1)")) port map (SYNC(1));
end MODEL;
-----------------------------------------------------------------------------------
-- ZYNQMP_ACP_ADAPTER_READ_TEST
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ZYNQMP_ACP_ADAPTER_READ_TEST is
    generic (
        NAME            : STRING  := string'("ZYNQMP_ACP_ADAPTER_READ_TEST");
        SCENARIO_FILE   : STRING  := string'("zynqmp_acp_adapter_read_test.snr");
        FINISH_ABORT    : boolean := FALSE
    );
end     ZYNQMP_ACP_ADAPTER_READ_TEST;
use     WORK.ZYNQMP_ACP_ADAPTER_TEST_BENCH_COMPONENTS.ZYNQMP_ACP_ADAPTER_TEST_BENCH;
architecture MODEL of ZYNQMP_ACP_ADAPTER_READ_TEST is
begin
    TB: ZYNQMP_ACP_ADAPTER_TEST_BENCH generic map (
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE ,
        READ_ENABLE     => TRUE          ,
        WRITE_ENABLE    => FALSE         ,
        FINISH_ABORT    => FINISH_ABORT
        );
end MODEL;
-----------------------------------------------------------------------------------
-- ZYNQMP_ACP_ADAPTER_WRITE_TEST
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
entity  ZYNQMP_ACP_ADAPTER_WRITE_TEST is
    generic (
        NAME            : STRING  := string'("ZYNQMP_ACP_ADAPTER_WRITE_TEST");
        SCENARIO_FILE   : STRING  := string'("zynqmp_acp_adapter_write_test.snr");
        FINISH_ABORT    : boolean := FALSE
    );
end     ZYNQMP_ACP_ADAPTER_WRITE_TEST;
use     WORK.ZYNQMP_ACP_ADAPTER_TEST_BENCH_COMPONENTS.ZYNQMP_ACP_ADAPTER_TEST_BENCH;
architecture MODEL of ZYNQMP_ACP_ADAPTER_WRITE_TEST is
begin
    TB: ZYNQMP_ACP_ADAPTER_TEST_BENCH generic map (
        NAME            => NAME          , 
        SCENARIO_FILE   => SCENARIO_FILE ,
        READ_ENABLE     => FALSE         ,
        WRITE_ENABLE    => TRUE          ,
        FINISH_ABORT    => FINISH_ABORT
    );
end MODEL;
