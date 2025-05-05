-----------------------------------------------------------------------------------
--!     @file    zynqmp_acp_axuser.vhd
--!     @brief   ZynqMP ACP AxUser Signals
--!     @version 0.7.0
--!     @date    2025/5/4
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
entity  ZYNQMP_ACP_AxUSER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        ACP_SHARE_TYPE      : --! @brief ACP SHARE TYPE:
                              --! 0: Not Use AXI_AUSER, ACP_AxUSER <= Non-Sharable.
                              --! 1: Not Use AXI_AUSER, ACP_AxUSER <= Inner-Sharable.
                              --! 2: Not Use AXI_AUSER, ACP_AxUSER <= Outer-Sharable.
                              --! 3: Use 2 bit of AXI_AUSER, 
                              --!    u[0] := AXI_AUSER[AXI_AUSER_BIT0_POS]
                              --!    u[1] := AXI_AUSER[AXI_AUSER_BIT1_POS]
                              --!    u[1:0]=00: ACP_AxUSER <= Non-Sharable
                              --!    u[1:0]=01: ACP_AxUSER <= Inner-Sharable
                              --!    u[1:0]=1x: ACP_AxUSER <= Outer-Sharable
                              --! 4: Use 1 bit of AXI_AUSER, 
                              --!    u[0] := AXI_AUSER[AXI_AUSER_BIT0_POS]
                              --!    u[0]=0: ACP_AxUSER <= Non-Sharable
                              --!    u[0]=1: ACP_AxUSER <= Inner-Sharable
                              --! 5: Use 1 bit of AXI_AUSER,
                              --!    u[0] := AXI_AUSER[AXI_AUSER_BIT0_POS]
                              --!    u[0]=0: ACP_AxUSER <= Non-Sharable
                              --!    u[0]=1: ACP_AxUSER <= Outer-Sharable
                              --! 6: Use 1 bit of AXI_AUSER,
                              --!    u[0] := AXI_AUSER[AXI_AUSER_BIT0_POS]
                              --!    u[0]=0: ACP_AxUSER <= Inner-Sharable
                              --!    u[0]=1: ACP_AxUSER <= Outer-Sharable
                              integer range 0 to 6  := 0;
        AXI_AUSER_WIDTH     : --! @brief AXI AUSER WIDTH :
                              integer := 2;
        AXI_AUSER_BIT0_POS  : --! @brief AXI AUSER BIT0 POSITION :
                              integer := 0;
        AXI_AUSER_BIT1_POS  : --! @brief AXI AUSER BIT1 POSITION :
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
    -- LOAD Signal.
    -------------------------------------------------------------------------------
        LOAD                : in  std_logic;
    -------------------------------------------------------------------------------
    -- AXI AxUser Signal.
    -------------------------------------------------------------------------------
        AXI_AUSER           : in  std_logic_vector(AXI_AUSER_WIDTH -1 downto 0);
    -------------------------------------------------------------------------------
    -- ACP AxUser Signal.
    -------------------------------------------------------------------------------
        ACP_AUSER           : out std_logic_vector(1 downto 0)
    );
end ZYNQMP_ACP_AxUSER;
-----------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of ZYNQMP_ACP_AxUSER is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    constant  ACP_NON_SHARE     :  std_logic_vector(1 downto 0) := "00";
    constant  ACP_INNER_SHARE   :  std_logic_vector(1 downto 0) := "01";
    constant  ACP_OUTER_SHARE   :  std_logic_vector(1 downto 0) := "10";
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ACP_SHARE_TYPE_IS_NON_SHARE  : if ACP_SHARE_TYPE  = 0 generate
        ACP_AUSER <= ACP_NON_SHARE;
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ACP_SHARE_TYPE_IS_INNER_SHARE: if ACP_SHARE_TYPE  = 1 generate
        ACP_AUSER <= ACP_INNER_SHARE;
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ACP_SHARE_TYPE_IS_OUTER_SHARE: if ACP_SHARE_TYPE  = 2 generate
        ACP_AUSER <= ACP_OUTER_SHARE;
    end generate;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    ACP_SHARE_TYPE_IS_USER_AUSER : if ACP_SHARE_TYPE >= 3 generate
        process(CLK, RST)
            variable  u : std_logic_vector(1 downto 0);
        begin
            if (RST = '1') then
                    ACP_AUSER <= ACP_NON_SHARE;
            elsif (CLK'event and CLK = '1') then
                if (CLR = '1') then
                    ACP_AUSER <= ACP_NON_SHARE;
                elsif (LOAD = '1') then
                    if (AXI_AUSER_BIT0_POS >= AXI_AUSER'low ) and
                       (AXI_AUSER_BIT0_POS <= AXI_AUSER'high) then
                        u(0) := AXI_AUSER(AXI_AUSER_BIT0_POS);
                    else
                        u(0) := '0';
                    end if;
                    if (AXI_AUSER_BIT1_POS >= AXI_AUSER'low ) and
                       (AXI_AUSER_BIT1_POS <= AXI_AUSER'high) then
                        u(1) := AXI_AUSER(AXI_AUSER_BIT1_POS);
                    else
                        u(1) := '0';
                    end if;
                    case ACP_SHARE_TYPE is
                        when 3 =>
                            if    (u(1) = '1') then
                                ACP_AUSER <= ACP_OUTER_SHARE;
                            elsif (u(0) = '1') then
                                ACP_AUSER <= ACP_INNER_SHARE;
                            else
                                ACP_AUSER <= ACP_NON_SHARE;
                            end if;
                        when 4 =>
                            if (u(0) = '1') then
                                ACP_AUSER <= ACP_INNER_SHARE;
                            else
                                ACP_AUSER <= ACP_NON_SHARE;
                            end if;
                        when 5 =>
                            if (u(0) = '1') then
                                ACP_AUSER <= ACP_OUTER_SHARE;
                            else
                                ACP_AUSER <= ACP_NON_SHARE;
                            end if;
                        when 6 =>
                            if (u(0) = '1') then
                                ACP_AUSER <= ACP_OUTER_SHARE;
                            else
                                ACP_AUSER <= ACP_INNER_SHARE;
                            end if;
                        when others =>
                                ACP_AUSER <= ACP_NON_SHARE;
                    end case;
                end if;
            end if;
        end process;
    end generate;
end RTL;    
